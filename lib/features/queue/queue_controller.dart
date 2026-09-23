import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../compression/compression_providers.dart';
import '../compression/domain/compression_engine.dart';
import '../media/data/media_database.dart';
import '../media/data/media_platform.dart';
import '../media/media_providers.dart';
import '../media/selection_controller.dart';
import 'failure_taxonomy.dart';
import 'processing_guards.dart';

enum QueueRunStatus { idle, running, paused }

class QueueState {
  const QueueState({this.status = QueueRunStatus.idle, this.notice, this.startedAt});
  final QueueRunStatus status;
  final String? notice;
  final DateTime? startedAt;

  QueueState copyWith({QueueRunStatus? status, String? notice, DateTime? startedAt, bool clearNotice = false}) {
    return QueueState(status: status ?? this.status, notice: clearNotice ? null : notice ?? this.notice, startedAt: startedAt ?? this.startedAt);
  }
}

class QueueController extends StateNotifier<QueueState> {
  QueueController(this._database, this._engine, this._platform)
      : _guards = ProcessingGuards(_platform),
        super(const QueueState());

  final MediaDatabase _database;
  final CompressionEngine _engine;
  final MediaPlatform _platform;
  final ProcessingGuards _guards;
  Future<void>? _runFuture;
  Completer<void>? _resumeSignal;
  bool _cancelRequested = false;

  Future<void> enqueue(Iterable<MediaItem> items, CompressionSettings settings) async {
    final now = DateTime.now();
    for (final item in items) {
      await _database.insertJob(
        CompressionJobsCompanion.insert(
          mediaItemId: Value(item.id),
          inputPath: item.path,
          inputUri: item.uri,
          displayName: item.displayName,
          mediaType: item.mediaType,
          originalSize: item.size,
          status: 'queued',
          settingsJson: jsonEncode(_settingsToJson(settings)),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> start() async {
    if (_runFuture != null) return _runFuture!;
    _cancelRequested = false;
    final startedAt = DateTime.now();
    final sessionId = await _database.insertSavingsSession(SavingsSessionsCompanion.insert(startedAt: startedAt));
    state = state.copyWith(status: QueueRunStatus.running, startedAt: startedAt, clearNotice: true);
    final future = _run(sessionId, startedAt);
    _runFuture = future;
    try {
      await future;
    } finally {
      _runFuture = null;
    }
  }

  void pause() {
    if (state.status != QueueRunStatus.running) return;
    state = state.copyWith(status: QueueRunStatus.paused, notice: 'Paused after the current file finishes.');
  }

  void resume() {
    if (state.status != QueueRunStatus.paused) return;
    state = state.copyWith(status: QueueRunStatus.running, clearNotice: true);
    _resumeSignal?.complete();
    _resumeSignal = null;
  }

  Future<void> cancel() async {
    _cancelRequested = true;
    _resumeSignal?.complete();
    _resumeSignal = null;
    await _engine.cancel();
  }

  Future<void> _run(int sessionId, DateTime startedAt) async {
    await _database.resetActiveJobs();
    await _platform.startProcessingService();
    try {
      while (!_cancelRequested) {
        if (state.status == QueueRunStatus.paused) {
          _resumeSignal = Completer<void>();
          await _resumeSignal!.future;
          if (_cancelRequested) break;
        }
        final job = await _database.nextQueuedJob(DateTime.now());
        if (job == null) break;
        final guard = await _guards.check(upcomingBytes: job.originalSize);
        if (!guard.isAllowed) {
          state = state.copyWith(status: QueueRunStatus.paused, notice: guard.message);
          if (!await _waitForGuard(job.originalSize)) break;
        }
        await _runJob(job);
      }
    } finally {
      await _platform.stopProcessingService();
      await _recordSession(sessionId, startedAt);
      if (mounted) state = state.copyWith(status: QueueRunStatus.idle);
    }
  }

  Future<void> _recordSession(int sessionId, DateTime startedAt) async {
    final jobs = await _database.getJobsUpdatedAfter(startedAt);
    final finished = jobs.where((job) => {'done', 'skipped', 'failed', 'cancelled'}.contains(job.status)).toList();
    final bytesFreed = finished.fold<int>(0, (sum, job) => sum + ((job.outputSize ?? 0) < job.originalSize ? job.originalSize - (job.outputSize ?? 0) : 0));
    await _database.updateSavingsSession(
      sessionId,
      SavingsSessionsCompanion(
        completedAt: Value(DateTime.now()),
        filesProcessed: Value(finished.length),
        bytesFreed: Value(bytesFreed),
        skippedCount: Value(finished.where((job) => job.status == 'skipped').length),
        failedCount: Value(finished.where((job) => job.status == 'failed').length),
      ),
    );
  }

  Future<void> _runJob(CompressionJob job) async {
    final attempt = job.attempts + 1;
    await _database.updateJob(job.id, CompressionJobsCompanion(
      status: const Value('running'),
      attempts: Value(attempt),
      progress: const Value(0),
      errorCode: const Value(null),
      errorMessage: const Value(null),
      updatedAt: Value(DateTime.now()),
    ));
    final item = await _itemFromJob(job);
    final settings = _settingsFromJson(job.settingsJson);
    final result = await _engine.compress(CompressionRequest(
      item: item,
      settings: settings,
      onProgress: (progress) async {
        await _database.updateJob(job.id, CompressionJobsCompanion(
          status: Value(progress >= .8 ? 'verifying' : 'running'),
          progress: Value(progress),
          updatedAt: Value(DateTime.now()),
        ));
      },
    ));
    if (_cancelRequested) {
      await _database.updateJob(job.id, CompressionJobsCompanion(status: const Value('cancelled'), updatedAt: Value(DateTime.now())));
      return;
    }
    if (result.status == CompressionStatus.completed) {
      await _database.updateJob(job.id, CompressionJobsCompanion(
        status: const Value('done'),
        progress: const Value(1),
        outputPath: Value(result.outputPath),
        outputSize: Value(result.outputBytes),
        updatedAt: Value(DateTime.now()),
      ));
      return;
    }
    if (result.status == CompressionStatus.skipped) {
      await _database.updateJob(job.id, CompressionJobsCompanion(
        status: const Value('skipped'),
        errorCode: Value(classifyFailure(result.reason).name),
        errorMessage: Value(result.reason),
        updatedAt: Value(DateTime.now()),
      ));
      return;
    }
    final code = classifyFailure(result.reason);
    if (attempt < 3 && code != FailureCode.cancelled) {
      await _database.updateJob(job.id, CompressionJobsCompanion(
        status: const Value('queued'),
        errorCode: Value(code.name),
        errorMessage: Value(result.reason),
        nextAttemptAt: Value(DateTime.now().add(Duration(seconds: 1 << (attempt - 1)))),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await _database.updateJob(job.id, CompressionJobsCompanion(
        status: const Value('failed'),
        errorCode: Value(code.name),
        errorMessage: Value(result.reason),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  Future<bool> _waitForGuard(int upcomingBytes) async {
    while (!_cancelRequested) {
      await Future<void>.delayed(const Duration(seconds: 10));
      final result = await _guards.check(upcomingBytes: upcomingBytes);
      if (result.isAllowed) {
        state = state.copyWith(status: QueueRunStatus.running, clearNotice: true);
        return true;
      }
      if (mounted) state = state.copyWith(status: QueueRunStatus.paused, notice: result.message);
    }
    return false;
  }

  Future<MediaItem> _itemFromJob(CompressionJob job) async {
    final cached = job.mediaItemId == null ? null : await _database.getMediaItem(job.mediaItemId!);
    if (cached != null) return cached;
    return MediaItem(
    id: job.mediaItemId ?? job.id,
    path: job.inputPath,
    uri: job.inputUri,
    mediaType: job.mediaType,
    size: job.originalSize,
    displayName: job.displayName,
    scannedAt: job.createdAt,
    );
  }

  CompressionSettings _settingsFromJson(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return CompressionSettings(
      preset: CompressionPreset.values.byName(json['preset'] as String? ?? CompressionPreset.balanced.name),
      imageQuality: json['imageQuality'] as int? ?? 78,
      imageMaxDimension: json['imageMaxDimension'] as int? ?? 2048,
      videoBitrateKbps: json['videoBitrateKbps'] as int? ?? 2500,
      videoMaxDimension: json['videoMaxDimension'] as int? ?? 1080,
      videoFpsCap: json['videoFpsCap'] as int? ?? 30,
      audioBitrateKbps: json['audioBitrateKbps'] as int? ?? 128,
      replaceOriginal: json['replaceOriginal'] as bool? ?? false,
      stripMetadata: json['stripMetadata'] as bool? ?? false,
      keepRecycleBin: json['keepRecycleBin'] as bool? ?? false,
    );
  }
}

Map<String, Object> _settingsToJson(CompressionSettings settings) => {
  'preset': settings.preset.name,
  'imageQuality': settings.imageQuality,
  'imageMaxDimension': settings.imageMaxDimension,
  'videoBitrateKbps': settings.videoBitrateKbps,
  'videoMaxDimension': settings.videoMaxDimension,
  'videoFpsCap': settings.videoFpsCap,
  'audioBitrateKbps': settings.audioBitrateKbps,
  'replaceOriginal': settings.replaceOriginal,
  'stripMetadata': settings.stripMetadata,
  'keepRecycleBin': settings.keepRecycleBin,
};

final queueControllerProvider = StateNotifierProvider<QueueController, QueueState>((ref) {
  return QueueController(
    ref.watch(mediaDatabaseProvider),
    ref.watch(compressionEngineProvider),
    ref.watch(mediaPlatformProvider),
  );
});

final queueJobsProvider = StreamProvider<List<CompressionJob>>((ref) {
  return ref.watch(mediaDatabaseProvider).watchJobs();
});
