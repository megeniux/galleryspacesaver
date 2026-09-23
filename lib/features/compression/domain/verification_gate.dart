import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../../media/data/media_database.dart';
import 'codec_strategy.dart';

class VerificationResult {
  const VerificationResult({required this.passed, this.reason});
  final bool passed;
  final String? reason;
}

class VerificationGate {
  const VerificationGate._();

  static Future<VerificationResult> verify({
    required MediaItem input,
    required File output,
    required MediaFormat format,
  }) async {
    if (!await output.exists()) return const VerificationResult(passed: false, reason: 'The encoder produced no output.');
    final outputBytes = await output.length();
    if (outputBytes >= input.size) return const VerificationResult(passed: false, reason: 'The compressed output is not smaller.');
    if (format.mediaType == 'image') return _verifyImage(input, output);
    return _verifyPlayable(input, output);
  }

  static Future<VerificationResult> _verifyImage(MediaItem input, File output) async {
    try {
      final bytes = await output.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final validDimensions = image.width > 0 && image.height > 0;
      final inputAspect = input.width != null && input.height != null && input.height! > 0 ? input.width! / input.height! : null;
      final outputAspect = image.height > 0 ? image.width / image.height : null;
      image.dispose();
      codec.dispose();
      final directAspectMatches = inputAspect == null || outputAspect == null || (inputAspect - outputAspect).abs() <= .03;
      final rotatedAspectMatches = inputAspect == null || outputAspect == null || (inputAspect - (1 / outputAspect)).abs() <= .03;
      final aspectMatches = directAspectMatches || rotatedAspectMatches;
      return validDimensions && aspectMatches
          ? const VerificationResult(passed: true)
          : const VerificationResult(passed: false, reason: 'The output image dimensions or aspect ratio changed unexpectedly.');
    } catch (_) {
      // A decode failure means the file cannot safely enter the result set.
      return const VerificationResult(passed: false, reason: 'The compressed image could not be decoded.');
    }
  }

  static Future<VerificationResult> _verifyPlayable(MediaItem input, File output) async {
    try {
      final session = await FFprobeKit.getMediaInformation(output.path, 10000);
      final info = session.getMediaInformation();
      if (!ReturnCode.isSuccess(await session.getReturnCode()) || info == null) {
        return const VerificationResult(passed: false, reason: 'The output could not be opened by the media probe.');
      }
      final duration = double.tryParse(info.getDuration() ?? '');
      if (input.durationMs != null && duration != null && duration > 0) {
        final expected = input.durationMs! / 1000;
        if ((duration - expected).abs() > (expected * .03).clamp(1, double.infinity)) {
          return const VerificationResult(passed: false, reason: 'The output duration changed unexpectedly.');
        }
      }
      var videoWidth = 0;
      var videoHeight = 0;
      for (final stream in info.getStreams()) {
        if (stream.getType() == 'video') {
          videoWidth = stream.getWidth() ?? 0;
          videoHeight = stream.getHeight() ?? 0;
          break;
        }
      }
      if (input.width != null && input.height != null && input.height! > 0 && videoWidth > 0 && videoHeight > 0) {
        final inputAspect = input.width! / input.height!;
        final outputAspect = videoWidth / videoHeight;
        if ((inputAspect - outputAspect).abs() > .03) {
          return const VerificationResult(passed: false, reason: 'The output video dimensions changed unexpectedly.');
        }
      }
      return const VerificationResult(passed: true);
    } catch (_) {
      // Probe errors are treated as failed verification, never as permission to replace.
      return const VerificationResult(passed: false, reason: 'The output could not be verified.');
    }
  }
}
