import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'media_database.g.dart';

class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get uri => text()();
  TextColumn get mediaType => text()();
  IntColumn get size => integer()();
  DateTimeColumn get modifiedAt => dateTime().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get displayName => text()();
  DateTimeColumn get scannedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {uri},
  ];

}

class CompressionJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mediaItemId => integer().nullable()();
  TextColumn get inputPath => text()();
  TextColumn get inputUri => text()();
  TextColumn get displayName => text()();
  TextColumn get mediaType => text()();
  IntColumn get originalSize => integer()();
  TextColumn get status => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get outputPath => text().nullable()();
  IntColumn get outputSize => integer().nullable()();
  TextColumn get settingsJson => text()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class RecycleBinEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get originalPath => text()();
  TextColumn get originalUri => text()();
  TextColumn get backupPath => text()();
  TextColumn get displayName => text()();
  IntColumn get size => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
}

class SavingsSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get filesProcessed => integer().withDefault(const Constant(0))();
  IntColumn get bytesFreed => integer().withDefault(const Constant(0))();
  IntColumn get skippedCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [MediaItems, CompressionJobs, RecycleBinEntries, SavingsSessions])
class MediaDatabase extends _$MediaDatabase {
  MediaDatabase() : super(driftDatabase(name: 'gallery_sweeper'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) await m.createTable(compressionJobs);
      if (from < 3) await m.addColumn(compressionJobs, compressionJobs.outputSize);
      if (from < 4) await m.createTable(recycleBinEntries);
      if (from < 5) await m.createTable(savingsSessions);
    },
  );

  Stream<List<MediaItem>> watchAll() {
    return (select(mediaItems)
          ..orderBy([
            (table) => OrderingTerm.desc(table.size),
            (table) => OrderingTerm.asc(table.displayName),
          ]))
        .watch();
  }

  Future<List<MediaItem>> getAll() => select(mediaItems).get();

  Future<MediaItem?> getMediaItem(int id) {
    return (select(mediaItems)..where((item) => item.id.equals(id))).getSingleOrNull();
  }

  Stream<List<CompressionJob>> watchJobs() {
    return (select(compressionJobs)..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).watch();
  }

  Future<List<CompressionJob>> getJobs() => (select(compressionJobs)..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();

  Future<CompressionJob?> nextQueuedJob(DateTime now) async {
    final query = select(compressionJobs)
      ..where((job) => job.status.equals('queued') & (job.nextAttemptAt.isNull() | job.nextAttemptAt.isSmallerOrEqualValue(now)))
      ..orderBy([(job) => OrderingTerm.asc(job.createdAt)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<int> insertJob(CompressionJobsCompanion entry) => into(compressionJobs).insert(entry);

  Future<bool> updateJob(int id, CompressionJobsCompanion entry) {
    return (update(compressionJobs)..where((job) => job.id.equals(id))).write(entry).then((count) => count > 0);
  }

  Future<void> resetActiveJobs() async {
    await (update(compressionJobs)..where((job) => job.status.isIn(['running', 'verifying']))).write(
      CompressionJobsCompanion(
        status: const Value('queued'),
        progress: const Value(0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<RecycleBinEntry>> watchRecycleBin() {
    return (select(recycleBinEntries)..orderBy([(entry) => OrderingTerm.desc(entry.createdAt)])).watch();
  }

  Future<List<RecycleBinEntry>> getExpiredRecycleBin(DateTime now) {
    return (select(recycleBinEntries)..where((entry) => entry.expiresAt.isSmallerThanValue(now))).get();
  }

  Future<List<RecycleBinEntry>> getAllRecycleBin() => (select(recycleBinEntries)..orderBy([(entry) => OrderingTerm.asc(entry.createdAt)])).get();

  Future<int> insertRecycleBinEntry(RecycleBinEntriesCompanion entry) => into(recycleBinEntries).insert(entry);

  Future<bool> deleteRecycleBinEntry(int id) {
    return (delete(recycleBinEntries)..where((entry) => entry.id.equals(id))).go().then((count) => count > 0);
  }

  Stream<List<SavingsSession>> watchSavingsSessions() {
    return (select(savingsSessions)..orderBy([(session) => OrderingTerm.desc(session.startedAt)])).watch();
  }

  Future<int> insertSavingsSession(SavingsSessionsCompanion entry) => into(savingsSessions).insert(entry);

  Future<bool> updateSavingsSession(int id, SavingsSessionsCompanion entry) {
    return (update(savingsSessions)..where((session) => session.id.equals(id))).write(entry).then((count) => count > 0);
  }

  Future<List<CompressionJob>> getJobsUpdatedAfter(DateTime start) {
    return (select(compressionJobs)..where((job) => job.updatedAt.isBiggerOrEqualValue(start))).get();
  }

  Future<void> replaceAll(List<MediaItemsCompanion> entries) async {
    await transaction(() async {
      await delete(mediaItems).go();
      await batch((batch) => batch.insertAll(mediaItems, entries));
    });
  }

  Future<void> upsertAll(List<MediaItemsCompanion> entries) async {
    await batch((batch) {
      for (final entry in entries) {
        batch.insert(
          mediaItems,
          entry,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
