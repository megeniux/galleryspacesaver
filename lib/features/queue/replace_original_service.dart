import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../media/data/media_database.dart';
import '../media/data/media_platform.dart';
import '../../core/utils/formatters.dart';

class ReplaceOriginalService {
  ReplaceOriginalService(this._database, this._platform);
  final MediaDatabase _database;
  final MediaPlatform _platform;

  Future<ReplacementResult> replace({required CompressionJob job, required bool keepInRecycleBin}) async {
    final outputPath = job.outputPath;
    if (outputPath == null || !await File(outputPath).exists()) {
      return const ReplacementResult.failed('The verified compressed output is missing.');
    }
    if (await File(outputPath).length() >= job.originalSize) {
      return const ReplacementResult.failed('The output is no longer smaller than the original.');
    }
    final source = job.inputPath.startsWith('content://') ? job.inputUri : job.inputPath;
    final backup = await _createBackup(job, source);
    final now = DateTime.now();
    try {
      if (source.startsWith('content://')) {
        final consent = await _platform.requestMediaStoreConsent(uri: source, action: 'write');
        if (!consent) return const ReplacementResult.failed('MediaStore write permission was not granted.');
        await _platform.writeCachedFileToUri(sourcePath: outputPath, uri: source);
        await _platform.rescanMedia(source);
      } else {
        await _replaceFile(source, outputPath, backup);
        await _platform.rescanMedia(source);
      }
      if (keepInRecycleBin) {
        await _database.insertRecycleBinEntry(
          RecycleBinEntriesCompanion.insert(
            originalPath: job.inputPath,
            originalUri: job.inputUri,
            backupPath: backup.path,
            displayName: job.displayName,
            size: job.originalSize,
            createdAt: now,
            expiresAt: now.add(const Duration(days: 30)),
          ),
        );
        await _enforceCap();
      } else {
        await _deleteQuietly(backup);
      }
      await _deleteQuietly(File(outputPath));
      await _database.updateJob(job.id, CompressionJobsCompanion(outputPath: const Value(null), updatedAt: Value(DateTime.now())));
      return ReplacementResult.success(source);
    } catch (error) {
      await _restore(source, backup);
      return ReplacementResult.failed('Original was restored after replacement failed: $error');
    }
  }

  Future<RecycleBinResult> restore(RecycleBinEntry entry) async {
    final backup = File(entry.backupPath);
    if (!await backup.exists()) return const RecycleBinResult.failed('The recycle-bin backup is missing.');
    final source = entry.originalPath.startsWith('content://') ? entry.originalUri : entry.originalPath;
    try {
      if (source.startsWith('content://')) {
        final consent = await _platform.requestMediaStoreConsent(uri: source, action: 'write');
        if (!consent) return const RecycleBinResult.failed('MediaStore write permission was not granted.');
        await _platform.writeCachedFileToUri(sourcePath: backup.path, uri: source);
      } else {
        await backup.copy(source);
      }
      await _platform.rescanMedia(source);
      await _deleteQuietly(backup);
      await _database.deleteRecycleBinEntry(entry.id);
      return const RecycleBinResult.success();
    } catch (error) {
      return RecycleBinResult.failed('Could not restore the original: $error');
    }
  }

  Future<void> purgeExpired() async {
    for (final entry in await _database.getExpiredRecycleBin(DateTime.now())) {
      await _deleteQuietly(File(entry.backupPath));
      await _database.deleteRecycleBinEntry(entry.id);
    }
  }

  Future<void> empty() async {
    for (final entry in await _database.getAllRecycleBin()) {
      await _deleteQuietly(File(entry.backupPath));
      await _database.deleteRecycleBinEntry(entry.id);
    }
  }

  Future<File> _createBackup(CompressionJob job, String source) async {
    final root = Directory('${(await getTemporaryDirectory()).path}/rigel_recycle_bin');
    await root.create(recursive: true);
    final safeName = job.displayName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final backup = File('${root.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName');
    if (source.startsWith('content://')) {
      await _platform.copyToCache(source: source, targetPath: backup.path);
    } else {
      await File(source).copy(backup.path);
    }
    return backup;
  }

  Future<void> _replaceFile(String source, String output, File backup) async {
    final original = File(source);
    if (!await original.exists()) throw StateError('Original file disappeared before replacement.');
    final extension = fileExtension(source);
    if (extension.isNotEmpty && extension != fileExtension(output)) {
      throw StateError('Format-preserving replacement requires matching extensions.');
    }
    final staged = File('$source.rigel_replace_${DateTime.now().microsecondsSinceEpoch}');
    await File(output).copy(staged.path);
    try {
      await original.delete();
      await staged.rename(source);
    } catch (_) {
      await _restoreFile(source, backup);
      rethrow;
    }
  }

  Future<void> _restore(String source, File backup) async {
    try {
      if (source.startsWith('content://')) {
        final consent = await _platform.requestMediaStoreConsent(uri: source, action: 'write');
        if (consent) await _platform.writeCachedFileToUri(sourcePath: backup.path, uri: source);
      } else {
        await _restoreFile(source, backup);
      }
    } catch (_) {
      // The original backup remains in the recycle-bin cache for manual recovery.
    }
  }

  Future<void> _restoreFile(String source, File backup) async {
    final original = File(source);
    if (!await original.exists()) await backup.copy(source);
  }

  Future<void> _enforceCap() async {
    const cap = 2 * 1024 * 1024 * 1024;
    var total = 0;
    for (final entry in await _database.getAllRecycleBin()) {
      total += entry.size;
      if (total > cap) {
        await _deleteQuietly(File(entry.backupPath));
        await _database.deleteRecycleBinEntry(entry.id);
      }
    }
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Cache cleanup is best effort; the database entry still exposes the failure.
    }
  }
}

class ReplacementResult {
  const ReplacementResult._(this.succeeded, this.message, this.path);
  const ReplacementResult.success(String path) : this._(true, null, path);
  const ReplacementResult.failed(String message) : this._(false, message, null);
  final bool succeeded;
  final String? message;
  final String? path;
}

class RecycleBinResult {
  const RecycleBinResult._(this.succeeded, this.message);
  const RecycleBinResult.success() : this._(true, null);
  const RecycleBinResult.failed(String message) : this._(false, message);
  final bool succeeded;
  final String? message;
}
