import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../media/data/media_database.dart';
import '../media/data/media_platform.dart';
import '../../core/utils/formatters.dart';

class ReplaceOriginalService {
  ReplaceOriginalService(
    this._database,
    this._platform, {
    Future<Directory> Function()? temporaryDirectory,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final MediaDatabase _database;
  final MediaPlatform _platform;
  final Future<Directory> Function() _temporaryDirectory;

  Future<ReplacementResult> replace({
    required CompressionJob job,
    required bool keepInRecycleBin,
  }) async {
    final outputPath = job.outputPath;
    if (outputPath == null || !await File(outputPath).exists()) {
      return const ReplacementResult.failed(
        'The verified compressed output is missing.',
      );
    }
    if (await File(outputPath).length() >= job.originalSize) {
      return const ReplacementResult.failed(
        'The output is no longer smaller than the original.',
      );
    }
    final source = _sourceForMedia(job.inputPath, job.inputUri);
    final now = DateTime.now();
    final originalInfo = source.startsWith('content://')
        ? await _platform.mediaInfo(uri: source, type: job.mediaType)
        : null;
    if (source.startsWith('content://') &&
        (originalInfo == null || originalInfo.size != job.originalSize)) {
      return const ReplacementResult.failed(
        'The gallery item changed after compression. Scan again and compress the current original.',
      );
    }
    File? backup;
    var replacementStarted = false;
    try {
      final backupFile = await _createBackup(job, source);
      backup = backupFile;
      if (source.startsWith('content://')) {
        if (!await _platform.mediaUriMatchesFile(
          sourcePath: backupFile.path,
          uri: source,
        )) {
          throw StateError(
            'The recovery copy does not match the gallery original.',
          );
        }
        final consent = await _platform.requestMediaStoreConsent(
          uri: source,
          action: 'write',
        );
        if (!consent) {
          await _deleteQuietly(backupFile);
          return const ReplacementResult.failed(
            'Android permission was declined. The original file was not changed.',
          );
        }
        replacementStarted = true;
        await _platform.writeCachedFileToUri(
          sourcePath: outputPath,
          uri: source,
        );
        await _platform.rescanMedia(source);
        if (!await _platform.mediaUriMatchesFile(
          sourcePath: outputPath,
          uri: source,
        )) {
          throw StateError(
            'Android did not persist the compressed bytes to the selected gallery item.',
          );
        }
        final replacedInfo = await _platform.mediaInfo(
          uri: source,
          type: job.mediaType,
        );
        final compressedSize = await File(outputPath).length();
        if (replacedInfo == null) {
          throw StateError(
            'Android could not read the replaced gallery item.',
          );
        }
        if (originalInfo?.mimeType != null &&
            replacedInfo.mimeType != originalInfo!.mimeType) {
          throw StateError(
            'The gallery item format changed during replacement.',
          );
        }
        await _refreshMediaCache(
          source,
          _withVerifiedSize(replacedInfo, compressedSize),
        );
      } else {
        replacementStarted = true;
        await _replaceFile(source, outputPath, backupFile);
        if (!await _filesMatch(File(outputPath), File(source))) {
          throw StateError(
            'The compressed bytes were not installed at the original path.',
          );
        }
        await _platform.rescanMedia(source);
      }
      if (keepInRecycleBin) {
        await _database.insertRecycleBinEntry(
          RecycleBinEntriesCompanion.insert(
            originalPath: job.inputPath,
            originalUri: job.inputUri,
            backupPath: backupFile.path,
            displayName: job.displayName,
            size: job.originalSize,
            createdAt: now,
            expiresAt: now.add(const Duration(days: 30)),
          ),
        );
        await _enforceCap();
      } else {
        await _deleteQuietly(backupFile);
      }
      await _deleteQuietly(File(outputPath));
      await _database.updateJob(
        job.id,
        CompressionJobsCompanion(
          outputPath: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return ReplacementResult.success(source);
    } catch (error) {
      final restored =
          !replacementStarted ||
          (backup != null && await _restore(source, backup, job.mediaType));
      if (backup != null) {
        if (!replacementStarted || (!keepInRecycleBin && restored)) {
          await _deleteQuietly(backup);
        } else {
          await _recordRecycleBackup(job, backup, now);
        }
      }
      final reason = _friendlyFileError(error);
      return ReplacementResult.failed(
        restored
            ? 'Replacement failed. The original file is unchanged or was restored. $reason'
            : backup == null
            ? 'Replacement failed before an original backup could be created. $reason'
            : 'Replacement failed and automatic restore could not finish. Your original backup remains in app storage. $reason',
      );
    }
  }

  Future<RecycleBinResult> restore(RecycleBinEntry entry) async {
    final backup = File(entry.backupPath);
    if (!await backup.exists()) {
      return const RecycleBinResult.failed(
        'The recycle-bin backup is missing.',
      );
    }
    // Older entries stored a filesystem path in originalPath even when Android
    // requires the MediaStore URI to write back to the item.
    final source = _sourceForMedia(entry.originalPath, entry.originalUri);
    try {
      if (source.startsWith('content://')) {
        final consent = await _platform.requestMediaStoreConsent(
          uri: source,
          action: 'write',
        );
        if (!consent) {
          return const RecycleBinResult.failed(
            'MediaStore write permission was not granted.',
          );
        }
        await _platform.writeCachedFileToUri(
          sourcePath: backup.path,
          uri: source,
        );
        if (!await _platform.mediaUriMatchesFile(
          sourcePath: backup.path,
          uri: source,
        )) {
          return const RecycleBinResult.failed(
            'Android did not restore the backup bytes. The backup remains in the recycle bin.',
          );
        }
        final restoredInfo = await _platform.mediaInfo(
          uri: source,
          type: _mediaTypeFromUri(source),
        );
        if (restoredInfo == null) {
          return const RecycleBinResult.failed(
            'Android could not read the restored item. The backup remains in the recycle bin.',
          );
        }
        await _refreshMediaCache(
          source,
          _withVerifiedSize(restoredInfo, await backup.length()),
        );
      } else {
        await backup.copy(source);
        if (!await _filesMatch(backup, File(source))) {
          return const RecycleBinResult.failed(
            'The restored file does not match its backup. The backup remains in the recycle bin.',
          );
        }
      }
      await _platform.rescanMedia(source);
      await _deleteQuietly(backup);
      await _database.deleteRecycleBinEntry(entry.id);
      return const RecycleBinResult.success();
    } catch (error) {
      return RecycleBinResult.failed(
        'Could not restore the original. The backup remains in the recycle bin. ${_friendlyFileError(error)}',
      );
    }
  }

  /// Re-indexes original backups left behind by older replacement failures.
  /// A marker records the newest examined filename timestamp so duplicate
  /// retries are not re-added after a user restores the selected backup.
  Future<void> recoverOrphanedBackups() async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/rigel_recycle_bin',
    );
    if (!await root.exists()) return;
    final marker = File('${root.path}/recovery_scan.marker');
    final scannedThrough =
        int.tryParse(
          await marker.exists() ? await marker.readAsString() : '',
        ) ??
        0;
    final entries = await _database.getAllRecycleBin();
    final knownBackups = entries.map((entry) => entry.backupPath).toSet();
    final knownSources = entries.map((entry) => entry.originalUri).toSet();
    final jobs = (await _database.getJobs()).where((job) {
      if (job.status != 'done' || !job.inputUri.startsWith('content://')) {
        return false;
      }
      try {
        return (jsonDecode(job.settingsJson)
                as Map<String, dynamic>)['keepRecycleBin'] ==
            true;
      } catch (_) {
        // Invalid historical settings cannot establish that a backup belongs
        // to a replacement, so leave that file untouched and unindexed.
        return false;
      }
    }).toList();
    final candidatesByName = <String, List<CompressionJob>>{};
    for (final job in jobs) {
      final safeName = _safeBackupName(job.displayName);
      candidatesByName.putIfAbsent(safeName, () => <CompressionJob>[]).add(job);
    }

    final newestByJob = <int, ({File file, DateTime createdAt, int stamp})>{};
    var newestSeen = scannedThrough;
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! File || entity.path == marker.path) continue;
      final basename = entity.uri.pathSegments.last;
      final match = RegExp(r'^(\d+)_').firstMatch(basename);
      final stamp = int.tryParse(match?.group(1) ?? '');
      if (stamp == null) continue;
      if (stamp > newestSeen) newestSeen = stamp;
      if (stamp <= scannedThrough || knownBackups.contains(entity.path)) {
        continue;
      }
      final suffix = basename.substring(match!.end);
      final candidates = candidatesByName[suffix];
      if (candidates == null || candidates.length != 1) continue;
      final job = candidates.single;
      if (knownSources.contains(job.inputUri) ||
          await entity.length() != job.originalSize) {
        continue;
      }
      final existing = newestByJob[job.id];
      if (existing == null || stamp > existing.stamp) {
        newestByJob[job.id] = (
          file: entity,
          createdAt: DateTime.fromMicrosecondsSinceEpoch(stamp),
          stamp: stamp,
        );
      }
    }

    for (final job in jobs) {
      final recovered = newestByJob[job.id];
      if (recovered == null || knownSources.contains(job.inputUri)) continue;
      await _database.insertRecycleBinEntry(
        RecycleBinEntriesCompanion.insert(
          originalPath: job.inputPath,
          originalUri: job.inputUri,
          backupPath: recovered.file.path,
          displayName: job.displayName,
          size: job.originalSize,
          createdAt: recovered.createdAt,
          expiresAt: recovered.createdAt.add(const Duration(days: 30)),
        ),
      );
      knownSources.add(job.inputUri);
    }
    if (newestSeen > scannedThrough) {
      await marker.writeAsString('$newestSeen', flush: true);
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
    final root = Directory(
      '${(await _temporaryDirectory()).path}/rigel_recycle_bin',
    );
    await root.create(recursive: true);
    final safeName = _safeBackupName(job.displayName);
    final backup = File(
      '${root.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName',
    );
    if (source.startsWith('content://')) {
      await _platform.copyToCache(source: source, targetPath: backup.path);
    } else {
      await File(source).copy(backup.path);
    }
    return backup;
  }

  Future<void> _refreshMediaCache(String uri, MediaRow row) async {
    final values = MediaItemsCompanion(
      path: Value(row.path),
      size: Value(row.size),
      modifiedAt: Value(row.modifiedAt),
      width: Value(row.width),
      height: Value(row.height),
      durationMs: Value(row.durationMs),
      mimeType: Value(row.mimeType),
      displayName: Value(row.displayName),
      scannedAt: Value(DateTime.now()),
    );
    final updated = await _database.updateMediaItemByUri(uri, values);
    if (!updated) {
      await _database.upsertAll(<MediaItemsCompanion>[
        MediaItemsCompanion.insert(
          path: row.path,
          uri: row.uri,
          mediaType: row.type.name,
          size: row.size,
          modifiedAt: Value(row.modifiedAt),
          width: Value(row.width),
          height: Value(row.height),
          durationMs: Value(row.durationMs),
          mimeType: Value(row.mimeType),
          displayName: row.displayName,
          scannedAt: DateTime.now(),
        ),
      ]);
    }
  }

  MediaRow _withVerifiedSize(MediaRow row, int size) => MediaRow(
    path: row.path,
    uri: row.uri,
    type: row.type,
    size: size,
    modifiedAt: row.modifiedAt,
    width: row.width,
    height: row.height,
    durationMs: row.durationMs,
    mimeType: row.mimeType,
    displayName: row.displayName,
  );

  Future<void> _recordRecycleBackup(
    CompressionJob job,
    File backup,
    DateTime createdAt,
  ) async {
    await _database.insertRecycleBinEntry(
      RecycleBinEntriesCompanion.insert(
        originalPath: job.inputPath,
        originalUri: job.inputUri,
        backupPath: backup.path,
        displayName: job.displayName,
        size: job.originalSize,
        createdAt: createdAt,
        expiresAt: createdAt.add(const Duration(days: 30)),
      ),
    );
    await _enforceCap();
  }

  Future<bool> _filesMatch(File expected, File actual) async {
    if (!await expected.exists() ||
        !await actual.exists() ||
        await expected.length() != await actual.length()) {
      return false;
    }
    final expectedHandle = await expected.open();
    final actualHandle = await actual.open();
    try {
      while (true) {
        final expectedBytes = await expectedHandle.read(64 * 1024);
        final actualBytes = await actualHandle.read(64 * 1024);
        if (expectedBytes.length != actualBytes.length) return false;
        if (expectedBytes.isEmpty) return true;
        for (var index = 0; index < expectedBytes.length; index++) {
          if (expectedBytes[index] != actualBytes[index]) return false;
        }
      }
    } finally {
      await expectedHandle.close();
      await actualHandle.close();
    }
  }

  Future<void> _replaceFile(String source, String output, File backup) async {
    final original = File(source);
    if (!await original.exists()) {
      throw StateError('Original file disappeared before replacement.');
    }
    final extension = fileExtension(source);
    if (extension.isNotEmpty && extension != fileExtension(output)) {
      throw StateError(
        'Format-preserving replacement requires matching extensions.',
      );
    }
    final staged = File(
      '$source.rigel_replace_${DateTime.now().microsecondsSinceEpoch}',
    );
    await File(output).copy(staged.path);
    try {
      await original.delete();
      await staged.rename(source);
    } catch (_) {
      await _restoreFile(source, backup);
      rethrow;
    }
  }

  Future<bool> _restore(String source, File backup, String mediaType) async {
    try {
      if (source.startsWith('content://')) {
        final consent = await _platform.requestMediaStoreConsent(
          uri: source,
          action: 'write',
        );
        if (!consent) return false;
        await _platform.writeCachedFileToUri(
          sourcePath: backup.path,
          uri: source,
        );
        if (!await _platform.mediaUriMatchesFile(
          sourcePath: backup.path,
          uri: source,
        )) {
          return false;
        }
        final restoredInfo = await _platform.mediaInfo(
          uri: source,
          type: mediaType,
        );
        if (restoredInfo == null) {
          return false;
        }
        await _refreshMediaCache(
          source,
          _withVerifiedSize(restoredInfo, await backup.length()),
        );
      } else {
        await _restoreFile(source, backup);
        if (!await _filesMatch(backup, File(source))) return false;
      }
      await _platform.rescanMedia(source);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _restoreFile(String source, File backup) async {
    final original = File(source);
    final staged = File(
      '$source.rigel_restore_${DateTime.now().microsecondsSinceEpoch}',
    );
    await backup.copy(staged.path);
    try {
      if (await original.exists()) await original.delete();
      await staged.rename(source);
    } catch (_) {
      await _deleteQuietly(staged);
      rethrow;
    }
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

  String _sourceForMedia(String path, String uri) =>
      uri.startsWith('content://') ? uri : path;

  String _mediaTypeFromUri(String uri) {
    if (uri.contains('/audio/')) return 'audio';
    if (uri.contains('/video/')) return 'video';
    return 'image';
  }

  String _safeBackupName(String name) =>
      name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  String _friendlyFileError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('pathaccessexception') ||
        message.contains('operation not permitted') ||
        message.contains('eacces')) {
      return 'Android blocked direct access to this gallery file. Retry and approve the Android access prompt.';
    }
    if (message.contains('permission') || message.contains('denied')) {
      return 'Android did not grant access to this gallery file. Retry and approve the access prompt.';
    }
    return 'Check that the file is still available, then try again.';
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
