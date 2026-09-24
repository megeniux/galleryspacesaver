import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/log.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import 'package:path_provider/path_provider.dart';

import '../../media/data/media_database.dart';
import '../../media/data/media_platform.dart';
import '../../media/selection_controller.dart';
import 'codec_strategy.dart';
import 'video_scale_filter.dart';
import 'verification_gate.dart';

typedef CompressionProgress = void Function(double progress);

class CompressionRequest {
  const CompressionRequest({
    required this.item,
    this.settings = const CompressionSettings(),
    this.onProgress,
  });
  final MediaItem item;
  final CompressionSettings settings;
  final CompressionProgress? onProgress;
}

class CompressionResult {
  const CompressionResult({
    required this.status,
    this.outputPath,
    this.outputBytes,
    this.reason,
    this.format,
  });
  final CompressionStatus status;
  final String? outputPath;
  final int? outputBytes;
  final String? reason;
  final MediaFormat? format;
}

enum CompressionStatus { completed, skipped, failed }

class CompressionEngine {
  CompressionEngine({MediaPlatform? platform})
    : _platform = platform ?? const MediaPlatform();

  final MediaPlatform _platform;
  int? _activeSessionId;

  Future<void> cancel() async {
    final sessionId = _activeSessionId;
    if (sessionId != null) await FFmpegKit.cancel(sessionId);
  }

  Future<CompressionResult> compress(CompressionRequest request) async {
    Directory? stagingDirectory;
    try {
      stagingDirectory = await _createStagingDirectory();
      final source = await _resolveSource(request.item, stagingDirectory);
      final detected = await CodecStrategy.detectFile(
        source,
        fallbackMime: request.item.mimeType,
      );
      if (detected == null) {
        return const CompressionResult(
          status: CompressionStatus.skipped,
          reason: 'The file format is not supported.',
        );
      }
      final outputRoot = Directory(
        '${(await getTemporaryDirectory()).path}/rigel_outputs',
      );
      await outputRoot.create(recursive: true);
      final output = File(
        '${outputRoot.path}/output_${DateTime.now().microsecondsSinceEpoch}.${detected.format.extension}',
      );
      final outputPath = detected.path == CodecPath.nativeImage
          ? await _compressNativeImage(request, source, output, detected.format)
          : await _compressWithFfmpeg(request, source, output, detected.format);
      request.onProgress?.call(.85);
      final verification = await VerificationGate.verify(
        input: request.item,
        output: File(outputPath),
        format: detected.format,
      );
      if (!verification.passed) {
        await _deleteQuietly(File(outputPath));
        return CompressionResult(
          status: CompressionStatus.skipped,
          reason: verification.reason,
          format: detected.format,
        );
      }
      request.onProgress?.call(1);
      return CompressionResult(
        status: CompressionStatus.completed,
        outputPath: outputPath,
        outputBytes: await File(outputPath).length(),
        format: detected.format,
      );
    } catch (error) {
      return CompressionResult(
        status: CompressionStatus.failed,
        reason: 'Compression failed: $error',
      );
    } finally {
      if (stagingDirectory != null) await _deleteQuietly(stagingDirectory);
    }
  }

  Future<File> _resolveSource(MediaItem item, Directory directory) async {
    final source = item.path.startsWith('content://') ? item.uri : item.path;
    if (!source.startsWith('content://')) return File(source);
    final staged = await _platform.copyToCache(
      source: source,
      targetPath:
          '${directory.path}/input_${item.id}.${item.mimeType?.split('/').last ?? 'bin'}',
    );
    return File(staged);
  }

  Future<String> _compressNativeImage(
    CompressionRequest request,
    File source,
    File output,
    MediaFormat format,
  ) {
    return _platform.compressImage(
      source: source.path,
      outputPath: output.path,
      mimeType: format.mimeType,
      quality: request.settings.imageQuality,
      maxDimension: request.settings.imageMaxDimension,
    );
  }

  Future<String> _compressWithFfmpeg(
    CompressionRequest request,
    File source,
    File output,
    MediaFormat format,
  ) async {
    final codecs = format.mediaType == 'video'
        ? const ['h264_mediacodec', 'libx264']
        : const <String?>[null];
    Object? lastError;
    for (final codec in codecs) {
      try {
        final args = _arguments(
          request,
          source.path,
          output.path,
          format,
          videoCodec: codec,
        );
        await _runFfmpeg(args, request);
        if (await output.exists()) return output.path;
        lastError = StateError('FFmpeg produced no output.');
      } catch (error) {
        lastError = error;
        await _deleteQuietly(output);
      }
    }
    throw lastError ?? StateError('No compatible media encoder was available.');
  }

  Future<void> _runFfmpeg(List<String> args, CompressionRequest request) async {
    final done = Completer<void>();
    var log = '';
    final session = await FFmpegKit.executeWithArgumentsAsync(
      args,
      (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          if (!done.isCompleted) done.complete();
        } else if (!done.isCompleted) {
          // The completion callback can run before the final log callbacks.
          // Read the session output so the queue shows the actual encoder error.
          final sessionLog = (await session.getAllLogsAsString(5000) ?? '')
              .trim();
          final details = [
            log.trim(),
            sessionLog,
          ].where((value) => value.isNotEmpty).join('\n');
          final lines = details
              .split(RegExp(r'\r?\n'))
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();
          final diagnosticLines = lines
              .where(
                (line) => RegExp(
                  r'error|invalid|failed|no such|not found|unable|could not|unsupported|encoder|decoder',
                  caseSensitive: false,
                ).hasMatch(line),
              )
              .toList();
          final summary = (diagnosticLines.isNotEmpty ? diagnosticLines : lines)
              .take(3)
              .join(' ');
          done.completeError(
            StateError(
              'FFmpeg returned ${returnCode?.getValue() ?? 'an error'}${summary.isEmpty ? '' : ': $summary'}',
            ),
          );
        }
      },
      (Log entry) {
        // Keep only the tail so a native encoder failure remains useful in the queue UI.
        log += entry.getMessage();
        if (log.length > 2400) log = log.substring(log.length - 2400);
      },
      (Statistics statistics) {
        final duration = request.item.durationMs;
        if (duration != null && duration > 0) {
          request.onProgress?.call(
            (statistics.getTime() / duration).clamp(0, .8).toDouble(),
          );
        }
      },
    );
    _activeSessionId = session.getSessionId();
    try {
      await done.future;
    } finally {
      _activeSessionId = null;
    }
  }

  List<String> _arguments(
    CompressionRequest request,
    String input,
    String output,
    MediaFormat format, {
    String? videoCodec,
  }) {
    final metadata = request.settings.stripMetadata
        ? const ['-map_metadata', '-1']
        : const <String>[];
    if (format.mediaType == 'video') {
      final selectedVideoCodec =
          videoCodec ??
          (format == MediaFormat.webm
              ? 'libvpx-vp9'
              : format == MediaFormat.avi
              ? 'mpeg4'
              : 'libx264');
      final audioCodec = format == MediaFormat.webm ? 'libopus' : 'aac';
      final maxDimension = request.settings.videoMaxDimension;
      final crf = switch (request.settings.preset) {
        CompressionPreset.light => '24',
        CompressionPreset.aggressive => '32',
        _ => '28',
      };
      return [
        '-y',
        '-i',
        input,
        '-map',
        '0:v:0',
        '-map',
        '0:a?',
        '-c:v',
        selectedVideoCodec,
        if (selectedVideoCodec == 'h264_mediacodec') ...[
          '-b:v',
          '${request.settings.videoBitrateKbps}k',
        ] else ...[
          '-crf',
          crf,
          '-preset',
          'veryfast',
        ],
        '-vf',
        videoScaleFilter(maxDimension),
        '-r',
        '${request.settings.videoFpsCap}',
        '-c:a',
        audioCodec,
        '-b:a',
        '${request.settings.audioBitrateKbps}k',
        ...metadata,
        output,
      ];
    }
    if (format.mediaType == 'audio') {
      final codec = switch (format) {
        MediaFormat.mp3 => 'libmp3lame',
        MediaFormat.flac => 'flac',
        MediaFormat.wav => 'pcm_s16le',
        MediaFormat.opus || MediaFormat.ogg => 'libopus',
        _ => 'aac',
      };
      return [
        '-y',
        '-i',
        input,
        '-vn',
        '-c:a',
        codec,
        '-b:a',
        '${request.settings.audioBitrateKbps}k',
        ...metadata,
        output,
      ];
    }
    if (format == MediaFormat.gif) {
      final scale =
          'scale=${request.settings.imageMaxDimension}:${request.settings.imageMaxDimension}:force_original_aspect_ratio=decrease';
      return [
        '-y',
        '-i',
        input,
        '-filter_complex',
        '[0:v]fps=15,$scale,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=sierra2_4a',
        '-loop',
        '0',
        ...metadata,
        output,
      ];
    }
    if (format == MediaFormat.png) {
      return [
        '-y',
        '-i',
        input,
        '-vf',
        'format=pal8',
        '-compression_level',
        '100',
        ...metadata,
        output,
      ];
    }
    return ['-y', '-i', input, '-q:v', '5', ...metadata, output];
  }

  Future<Directory> _createStagingDirectory() async {
    final root = await getTemporaryDirectory();
    final directory = Directory(
      '${root.path}/rigel_compression_${DateTime.now().microsecondsSinceEpoch}',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<void> _deleteQuietly(FileSystemEntity entity) async {
    try {
      if (await entity.exists()) await entity.delete(recursive: true);
    } on FileSystemException {
      // Cache cleanup is best effort and must not hide the compression result.
    }
  }
}
