import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/media_database.dart';
import 'data/media_platform.dart';
import 'data/media_repository.dart';

final mediaDatabaseProvider = Provider<MediaDatabase>((ref) {
  final database = MediaDatabase();
  ref.onDispose(database.close);
  return database;
});

final mediaPlatformProvider = Provider<MediaPlatform>((ref) => MediaPlatform());

// The shell owns the first-run prompt so it can appear after onboarding. Library
// still observes this state when it is mounted inside the IndexedStack.
final mediaPermissionStateProvider = StateProvider<MediaPermissionStatus?>(
  (ref) => null,
);

/// Set by Home's Quick Tools so opening Files lands on the right media kind.
/// Library consumes and clears it when it applies the filter.
final libraryKindFocusProvider = StateProvider<MediaKind?>((ref) => null);

/// Home's large-file shortcut opens Files already sorted and filtered to items
/// above the lightweight review threshold.
final libraryLargeFilesFocusProvider = StateProvider<bool>((ref) => false);

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(
    ref.watch(mediaDatabaseProvider),
    ref.watch(mediaPlatformProvider),
  );
});

final mediaItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaRepositoryProvider).watchItems();
});

final storageInfoProvider = FutureProvider<StorageInfo>((ref) {
  return ref.watch(mediaPlatformProvider).storageInfo();
});
