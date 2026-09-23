import 'package:drift/drift.dart';

import 'media_database.dart';
import 'media_platform.dart';

class MediaRepository {
  MediaRepository(this._database, this._platform);

  final MediaDatabase _database;
  final MediaPlatform _platform;

  Stream<List<MediaItem>> watchItems() => _database.watchAll();

  Future<MediaPermissionStatus> permissionStatus() => _platform.permissionStatus();

  Future<MediaPermissionStatus> requestPermissions({Iterable<MediaKind>? kinds}) =>
      _platform.requestPermissions(kinds: kinds);

  Future<MediaPermissionStatus> scan({bool incremental = false}) async {
    final previous = incremental
        ? (await _database.getAll()).map((item) => item.modifiedAt).whereType<DateTime>()
        : const <DateTime>[];
    final modifiedAfter = previous.isEmpty
        ? null
        : previous.reduce((a, b) => a.isAfter(b) ? a : b);
    final rows = await _platform.scan(modifiedAfter: modifiedAfter);
    final now = DateTime.now();
    final entries = rows
        .map(
          (row) => MediaItemsCompanion.insert(
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
            scannedAt: now,
          ),
        )
        .toList();
    if (incremental) {
      await _database.upsertAll(entries);
    } else {
      await _database.replaceAll(entries);
    }
    return (await _platform.permissionStatus());
  }

  Future<List<String>> formats() async {
    final rows = await _database.getAll();
    return rows
        .map((item) => item.mimeType?.split('/').last.toUpperCase())
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }
}
