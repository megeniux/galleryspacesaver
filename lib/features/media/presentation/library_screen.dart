import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/widgets/common.dart';
import '../data/media_database.dart';
import '../data/media_platform.dart';
import '../media_providers.dart';
import '../selection_controller.dart';
import '../selection_estimator.dart';
import '../../queue/queue_controller.dart';

enum MediaSort {
  sizeDescending,
  sizeAscending,
  dateDescending,
  dateAscending,
  nameAscending,
  nameDescending,
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  MediaPermissionStatus? _permission;
  MediaSort _sort = MediaSort.sizeDescending;
  bool _grid = false;
  bool _scanning = false;
  MediaKind? _kindFilter;
  String _search = '';
  int? _sizeThreshold;
  DateTimeRange? _dateRange;
  String? _format;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final status = await ref.read(mediaRepositoryProvider).permissionStatus();
    if (!mounted) return;
    ref.read(mediaPermissionStateProvider.notifier).state = status;
    setState(() => _permission = status);
    if (status.canScan) await _scan();
  }

  Future<void> _requestPermission({Iterable<MediaKind>? kinds}) async {
    final status = await ref
        .read(mediaRepositoryProvider)
        .requestPermissions(kinds: kinds);
    if (!mounted) return;
    ref.read(mediaPermissionStateProvider.notifier).state = status;
    setState(() => _permission = status);
    if (status.canScan) await _scan();
  }

  Future<void> _scan({bool incremental = false}) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    try {
      final status = await ref
          .read(mediaRepositoryProvider)
          .scan(incremental: incremental);
      if (mounted) setState(() => _permission = status);
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not scan media: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Home's Quick Tools can ask Files to open on a specific media kind.
    ref.listen<MediaKind?>(libraryKindFocusProvider, (_, kind) {
      if (kind == null) return;
      setState(() {
        _kindFilter = kind;
        _sort = MediaSort.sizeDescending;
      });
      ref.read(libraryKindFocusProvider.notifier).state = null;
    });
    final items =
        ref.watch(mediaItemsProvider).valueOrNull ?? const <MediaItem>[];
    final selection = ref.watch(selectionControllerProvider);
    final sharedPermission = ref.watch(mediaPermissionStateProvider);
    final permission = sharedPermission ?? _permission;
    final selectedItems = items
        .where((item) => selection.selectedUris.contains(item.uri))
        .toList();
    final visible = _filterAndSort(items, _kindFilter);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _search = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search files…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (permission != null && permission.canSelectMore)
          _LimitedAccessBanner(
            status: permission,
            onSelectMore: () => _requestPermission(
              kinds: const [MediaKind.image, MediaKind.video],
            ),
            onOpenSettings: () => const MediaPlatform().openAppSettings(),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _kindChip('All', null),
              _kindChip('Photos', MediaKind.image),
              _kindChip('Videos', MediaKind.video),
              _kindChip('Audio', MediaKind.audio),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilterChip(
                    avatar: const Icon(Icons.filter_list, size: 18),
                    label: Text(_filterLabel),
                    labelStyle: TextStyle(
                      color:
                          (_sizeThreshold != null ||
                              _dateRange != null ||
                              _format != null)
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    selected:
                        _sizeThreshold != null ||
                        _dateRange != null ||
                        _format != null,
                    onSelected: (_) => _showFilters(items),
                  ),
                  if (visible.isNotEmpty &&
                      selection.selectedUris.length != visible.length)
                    ActionChip(
                      label: const Text('Select all'),
                      onPressed: () => ref
                          .read(selectionControllerProvider.notifier)
                          .selectAll(visible.map((item) => item.uri)),
                    ),
                ],
              ),
              Row(
                children: [
                  PopupMenuButton<MediaSort>(
                    tooltip: 'Sort',
                    initialValue: _sort,
                    onSelected: (sort) => setState(() => _sort = sort),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: MediaSort.sizeDescending,
                        child: Text('Largest first'),
                      ),
                      PopupMenuItem(
                        value: MediaSort.sizeAscending,
                        child: Text('Smallest first'),
                      ),
                      PopupMenuItem(
                        value: MediaSort.dateDescending,
                        child: Text('Newest first'),
                      ),
                      PopupMenuItem(
                        value: MediaSort.dateAscending,
                        child: Text('Oldest first'),
                      ),
                      PopupMenuItem(
                        value: MediaSort.nameAscending,
                        child: Text('Name A–Z'),
                      ),
                      PopupMenuItem(
                        value: MediaSort.nameDescending,
                        child: Text('Name Z–A'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_sortLabel),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _grid ? 'List view' : 'Grid view',
                    icon: Icon(
                      _grid
                          ? Icons.view_list_outlined
                          : Icons.grid_view_outlined,
                    ),
                    onPressed: () => setState(() => _grid = !_grid),
                  ),
                  IconButton(
                    tooltip: 'Scan again',
                    onPressed: _scanning
                        ? null
                        : () => _scan(incremental: true),
                    icon: _scanning
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: permission == null
              ? const Center(child: CircularProgressIndicator())
              : !permission.canScan
              ? _PermissionState(
                  status: permission,
                  onRequest: _requestPermission,
                )
              : (_scanning && items.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : visible.isEmpty
              ? RefreshIndicator(
                  onRefresh: () => _scan(incremental: true),
                  child: ListView(
                    children: const [SizedBox(height: 100), _EmptyLibrary()],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _scan(incremental: true),
                  child: _grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: .86,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) => _MediaGridTile(
                            item: visible[index],
                            settings: selection.settings,
                            selected: selection.selectedUris.contains(
                              visible[index].uri,
                            ),
                            onToggle: () => ref
                                .read(selectionControllerProvider.notifier)
                                .toggle(visible[index].uri),
                            onPreview: () => _showItemPreview(
                              visible[index],
                              selection.settings,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) => _MediaListTile(
                            item: visible[index],
                            settings: selection.settings,
                            selected: selection.selectedUris.contains(
                              visible[index].uri,
                            ),
                            onToggle: () => ref
                                .read(selectionControllerProvider.notifier)
                                .toggle(visible[index].uri),
                            onPreview: () => _showItemPreview(
                              visible[index],
                              selection.settings,
                            ),
                          ),
                        ),
                ),
        ),
        if (selectedItems.isNotEmpty)
          _SelectionBar(
            items: selectedItems,
            settings: selection.settings,
            onClear: () =>
                ref.read(selectionControllerProvider.notifier).clear(),
            onConfigure: () =>
                _openCompressionSettings(selectedItems, selection.settings),
          ),
      ],
    );
  }

  String get _filterLabel {
    if (_sizeThreshold != null) return 'Over ${formatBytes(_sizeThreshold!)}';
    if (_dateRange != null) return 'Date range';
    if (_format != null) return _format!;
    return 'Filter';
  }

  Widget _kindChip(String label, MediaKind? kind) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _kindFilter == kind,
      labelStyle: TextStyle(
        color: _kindFilter == kind
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => setState(() => _kindFilter = kind),
    ),
  );

  // ignore: unused_element
  String get _sortLabel => switch (_sort) {
    MediaSort.sizeDescending => 'Largest size',
    MediaSort.sizeAscending => 'Smallest size',
    MediaSort.dateDescending => 'Newest',
    MediaSort.dateAscending => 'Oldest',
    MediaSort.nameAscending => 'Name A–Z',
    MediaSort.nameDescending => 'Name Z–A',
  };

  List<MediaItem> _filterAndSort(List<MediaItem> items, MediaKind? kind) {
    final filtered = items.where((item) {
      if (kind != null && item.mediaType != kind.name) return false;
      if (_search.isNotEmpty &&
          !item.displayName.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_sizeThreshold != null && item.size <= _sizeThreshold!) {
        return false;
      }
      if (_dateRange != null &&
          (item.modifiedAt == null ||
              item.modifiedAt!.isBefore(_dateRange!.start) ||
              item.modifiedAt!.isAfter(
                _dateRange!.end.add(const Duration(days: 1)),
              ))) {
        return false;
      }
      if (_format != null &&
          item.mimeType?.split('/').last.toUpperCase() != _format) {
        return false;
      }
      return true;
    }).toList();
    filtered.sort((a, b) {
      final result = switch (_sort) {
        MediaSort.sizeDescending => b.size.compareTo(a.size),
        MediaSort.sizeAscending => a.size.compareTo(b.size),
        MediaSort.dateDescending => (b.modifiedAt ?? DateTime(0)).compareTo(
          a.modifiedAt ?? DateTime(0),
        ),
        MediaSort.dateAscending => (a.modifiedAt ?? DateTime(0)).compareTo(
          b.modifiedAt ?? DateTime(0),
        ),
        MediaSort.nameAscending => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
        MediaSort.nameDescending => b.displayName.toLowerCase().compareTo(
          a.displayName.toLowerCase(),
        ),
      };
      return result == 0 ? a.displayName.compareTo(b.displayName) : result;
    });
    return filtered;
  }

  Future<void> _showFilters(List<MediaItem> items) async {
    final formats =
        items
            .map((item) => item.mimeType?.split('/').last.toUpperCase())
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    var threshold = _sizeThreshold;
    var range = _dateRange;
    var format = _format;
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FilterSheet(
        threshold: threshold,
        range: range,
        format: format,
        formats: formats,
        onThreshold: (value) => threshold = value,
        onRange: (value) => range = value,
        onFormat: (value) => format = value,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _sizeThreshold = result.threshold;
        _dateRange = result.range;
        _format = result.format;
      });
    }
  }

  Future<void> _openCompressionSettings(
    List<MediaItem> selectedItems,
    CompressionSettings settings,
  ) async {
    final result = await Navigator.of(context).push<_CompressionSheetResult>(
      MaterialPageRoute<_CompressionSheetResult>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Compression Options')),
          body: _CompressionSheet(items: selectedItems, initial: settings),
        ),
      ),
    );
    if (result == null || !mounted) return;
    ref.read(selectionControllerProvider.notifier).setSettings(result.settings);
    if (result.enqueue) {
      await ref
          .read(queueControllerProvider.notifier)
          .enqueue(selectedItems, result.settings);
      ref.read(selectionControllerProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedItems.length} file${selectedItems.length == 1 ? '' : 's'} added to the queue.',
            ),
          ),
        );
      }
    }
    if (result.preview) {
      await _showPreview(selectedItems.first, result.settings);
    }
  }

  Future<void> _showPreview(
    MediaItem item,
    CompressionSettings settings,
  ) async {
    if (item.mimeType == null) return;
    final preview = await ref
        .read(mediaPlatformProvider)
        .previewCompression(
          uri: item.uri,
          mimeType: item.mimeType!,
          quality: settings.imageQuality,
          maxDimension: settings.imageMaxDimension,
        );
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _PreviewSheet(item: item, preview: preview),
    );
  }

  Future<void> _showItemPreview(
    MediaItem item,
    CompressionSettings settings,
  ) async {
    final canRenderImage =
        item.mediaType == MediaKind.image.name &&
        {'image/jpeg', 'image/png', 'image/webp'}.contains(item.mimeType);
    if (canRenderImage) {
      await _showPreview(item, settings);
      return;
    }
    if (!mounted) return;
    final potential = estimateSavings(item, settings);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowIcon(
                item.mediaType == MediaKind.video.name
                    ? Icons.movie_rounded
                    : Icons.graphic_eq_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 14),
              Text(
                item.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatBytes(item.size)}  ·  Potential save ~${formatBytes(potential)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'A visual preview is not available for this format, but the file is ready for compression.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _Overview extends ConsumerWidget {
  const _Overview({required this.items});

  final List<MediaItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final storage = ref.watch(storageInfoProvider).valueOrNull;
    final totals = <String, int>{'image': 0, 'video': 0, 'audio': 0};
    for (final item in items) {
      totals[item.mediaType] = (totals[item.mediaType] ?? 0) + item.size;
    }
    final largest = items.isEmpty
        ? null
        : (items.toList()..sort((a, b) => b.size.compareTo(a.size))).first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 10),
              if (storage == null)
                Text(
                  'Reading device storage…',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                )
              else ...[
                Row(
                  children: [
                    Icon(
                      Icons.sd_storage_outlined,
                      size: 18,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${formatBytes(storage.freeBytes)} free of ${formatBytes(storage.totalBytes)} total',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Semantics(
                  label:
                      'Device storage used ${formatBytes(storage.usedBytes)} of ${formatBytes(storage.totalBytes)}',
                  child: LinearProgressIndicator(
                    value: storage.totalBytes == 0
                        ? 0
                        : storage.usedBytes / storage.totalBytes,
                    backgroundColor: scheme.onPrimaryContainer.withValues(
                      alpha: .18,
                    ),
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _Total(
                    label: 'Images',
                    value: totals['image']!,
                    icon: Icons.image_outlined,
                  ),
                  _Total(
                    label: 'Videos',
                    value: totals['video']!,
                    icon: Icons.movie_outlined,
                  ),
                  _Total(
                    label: 'Audio',
                    value: totals['audio']!,
                    icon: Icons.music_note_outlined,
                  ),
                ],
              ),
              if (largest != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Biggest offender · ${largest.displayName} · ${formatBytes(largest.size)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.icon});
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${formatBytes(value)}\n$label',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

class _PermissionState extends StatelessWidget {
  const _PermissionState({required this.status, required this.onRequest});
  final MediaPermissionStatus status;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final permanent = status.state == MediaPermissionState.permanentlyDenied;
    return EmptyState(
      icon: permanent ? Icons.lock_outline : Icons.photo_library_outlined,
      title: permanent ? 'Media access is turned off' : 'Allow media access',
      message: permanent
          ? 'Enable Photos and videos, music and audio in Android Settings to scan your library.'
          : 'Rigel Space Saver scans media locally on your device. Choose which photos and videos to share if Android offers partial access.',
      action: FilledButton.icon(
        onPressed: permanent
            ? () => const MediaPlatform().openAppSettings()
            : onRequest,
        icon: Icon(permanent ? Icons.settings_outlined : Icons.shield_outlined),
        label: Text(permanent ? 'Open permission settings' : 'Allow access'),
      ),
    );
  }
}

class _LimitedAccessBanner extends StatelessWidget {
  const _LimitedAccessBanner({
    required this.status,
    required this.onSelectMore,
    required this.onOpenSettings,
  });

  final MediaPermissionStatus status;
  final VoidCallback onSelectMore;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missing = <String>[
      if (!status.grantedKinds.contains(MediaKind.image)) 'photos',
      if (!status.grantedKinds.contains(MediaKind.video)) 'videos',
      if (!status.grantedKinds.contains(MediaKind.audio)) 'audio',
    ];
    final message = status.visualUserSelected
        ? 'Only the photos and videos you picked are visible. Pick more to find bigger savings.'
        : missing.isEmpty
        ? 'Android granted limited media access.'
        : 'Rigel cannot see your ${missing.join(' and ')} yet, so those files are missing from this list.';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited media access',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onSelectMore,
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                      label: const Text('Select more'),
                    ),
                    TextButton(
                      onPressed: onOpenSettings,
                      child: const Text('Allow all'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();
  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.photo_library_outlined,
    title: 'Nothing here yet',
    message: 'No media matched this tab or filter. Pull down to scan again.',
  );
}

class _MediaGridTile extends StatelessWidget {
  const _MediaGridTile({
    required this.item,
    required this.settings,
    required this.selected,
    required this.onToggle,
    required this.onPreview,
  });
  final MediaItem item;
  final CompressionSettings settings;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onPreview,
      onLongPress: onToggle,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Thumbnail(item: item)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatBytes(item.size),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Save ~${formatBytes(estimateSavings(item, settings))}',
                      style: TextStyle(
                        color: SweeperColors.of(context).savings,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (selected)
            Positioned(
              top: 8,
              right: 8,
              child: IgnorePointer(
                child: Checkbox(value: true, onChanged: (_) => onToggle()),
              ),
            ),
        ],
      ),
    ),
  );
}

class _MediaListTile extends StatelessWidget {
  const _MediaListTile({
    required this.item,
    required this.settings,
    required this.selected,
    required this.onToggle,
    required this.onPreview,
  });
  final MediaItem item;
  final CompressionSettings settings;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      onTap: onPreview,
      onLongPress: onToggle,
      selected: selected,
      leading: SizedBox(width: 56, height: 56, child: _Thumbnail(item: item)),
      title: Text(
        item.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatBytes(item.size)} · ${item.mimeType ?? item.mediaType}',
          ),
          Text(
            'Potential save ~${formatBytes(estimateSavings(item, settings))}',
            style: TextStyle(
              color: SweeperColors.of(context).savings,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Preview',
            onPressed: onPreview,
            icon: const Icon(Icons.visibility_outlined),
          ),
          Checkbox(value: selected, onChanged: (_) => onToggle()),
        ],
      ),
    ),
  );
}

class _Thumbnail extends ConsumerStatefulWidget {
  const _Thumbnail({required this.item});
  final MediaItem item;

  @override
  ConsumerState<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends ConsumerState<_Thumbnail> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _loadThumbnail(widget.item);
  }

  @override
  void didUpdateWidget(covariant _Thumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.uri != widget.item.uri ||
        oldWidget.item.mediaType != widget.item.mediaType) {
      _thumbnailFuture = _loadThumbnail(widget.item);
    }
  }

  Future<Uint8List?> _loadThumbnail(MediaItem item) {
    return ref
        .read(mediaPlatformProvider)
        .thumbnail(item.uri, MediaKind.values.byName(item.mediaType));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    if (item.mediaType == MediaKind.audio.name) {
      return ColoredBox(
        color: scheme.secondaryContainer,
        child: Icon(
          Icons.music_note,
          color: scheme.onSecondaryContainer,
          size: 34,
        ),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        }
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              item.mediaType == 'video'
                  ? Icons.movie_outlined
                  : Icons.image_outlined,
              color: scheme.onSurfaceVariant,
              size: 34,
            ),
          ),
        );
      },
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.items,
    required this.settings,
    required this.onClear,
    required this.onConfigure,
  });

  final List<MediaItem> items;
  final CompressionSettings settings;
  final VoidCallback onClear;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final selectedBytes = items.fold(0, (sum, item) => sum + item.size);
    final savings = estimateSelectedSavings(items, settings);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${items.length} files · ${formatBytes(selectedBytes)} selected\n~${formatBytes(savings)} estimated savings',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(onPressed: onConfigure, child: const Text('Next')),
            IconButton(
              onPressed: onClear,
              tooltip: 'Clear selection',
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompressionSheetResult {
  const _CompressionSheetResult({
    required this.settings,
    this.preview = false,
    this.enqueue = false,
  });
  final CompressionSettings settings;
  final bool preview;
  final bool enqueue;
}

class _CompressionSheet extends StatefulWidget {
  const _CompressionSheet({required this.items, required this.initial});
  final List<MediaItem> items;
  final CompressionSettings initial;

  @override
  State<_CompressionSheet> createState() => _CompressionSheetState();
}

class _CompressionSheetState extends State<_CompressionSheet> {
  late CompressionSettings settings = widget.initial;

  @override
  Widget build(BuildContext context) {
    final savings = estimateSelectedSavings(widget.items, settings);
    final hasImage = widget.items.any(
      (item) => item.mediaType == MediaKind.image.name,
    );
    final canPreview =
        widget.items.length == 1 &&
        widget.items.single.mediaType == MediaKind.image.name &&
        {
          'image/jpeg',
          'image/png',
          'image/webp',
        }.contains(widget.items.single.mimeType);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compression settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.items.length} selected · ${formatBytes(savings)} estimated savings',
            ),
            const SizedBox(height: 16),
            Text('Preset', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<CompressionPreset>(
              groupValue: settings.preset,
              onChanged: (value) {
                if (value != null) {
                  setState(() => settings = settings.forPreset(value));
                }
              },
              child: Column(
                children:
                    const [
                          CompressionPreset.aggressive,
                          CompressionPreset.balanced,
                          CompressionPreset.light,
                          CompressionPreset.custom,
                        ]
                        .map(
                          (preset) => _PresetOptionCard(
                            preset: preset,
                            selected: settings.preset == preset,
                            onTap: () => setState(
                              () => settings = settings.forPreset(preset),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            if (settings.preset == CompressionPreset.custom) ...[
              const SizedBox(height: 16),
              if (hasImage) ...[
                _SliderSetting(
                  label: 'Image quality',
                  value: settings.imageQuality,
                  min: 40,
                  max: 95,
                  suffix: '%',
                  onChanged: (value) =>
                      _customize(settings.copyWith(imageQuality: value)),
                ),
                _SliderSetting(
                  label: 'Image max dimension',
                  value: settings.imageMaxDimension,
                  min: 720,
                  max: 4096,
                  divisions: 14,
                  suffix: ' px',
                  onChanged: (value) =>
                      _customize(settings.copyWith(imageMaxDimension: value)),
                ),
              ],
              if (widget.items.any(
                (item) => item.mediaType == MediaKind.video.name,
              )) ...[
                _SliderSetting(
                  label: 'Video bitrate',
                  value: settings.videoBitrateKbps,
                  min: 500,
                  max: 8000,
                  divisions: 15,
                  suffix: ' kbps',
                  onChanged: (value) =>
                      _customize(settings.copyWith(videoBitrateKbps: value)),
                ),
                _SliderSetting(
                  label: 'Video max dimension',
                  value: settings.videoMaxDimension,
                  min: 480,
                  max: 2160,
                  divisions: 14,
                  suffix: ' px',
                  onChanged: (value) =>
                      _customize(settings.copyWith(videoMaxDimension: value)),
                ),
                _SliderSetting(
                  label: 'Video FPS cap',
                  value: settings.videoFpsCap,
                  min: 24,
                  max: 60,
                  suffix: ' fps',
                  onChanged: (value) =>
                      _customize(settings.copyWith(videoFpsCap: value)),
                ),
              ],
              if (widget.items.any(
                (item) => item.mediaType == MediaKind.audio.name,
              ))
                _SliderSetting(
                  label: 'Audio bitrate',
                  value: settings.audioBitrateKbps,
                  min: 64,
                  max: 320,
                  divisions: 16,
                  suffix: ' kbps',
                  onChanged: (value) =>
                      _customize(settings.copyWith(audioBitrateKbps: value)),
                ),
            ],
            const Divider(height: 28),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Replace originals'),
              subtitle: const Text('Disabled until output verification passes'),
              value: settings.replaceOriginal,
              onChanged: (value) => setState(
                () => settings = settings.copyWith(replaceOriginal: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Strip metadata'),
              subtitle: const Text('Remove EXIF, GPS and embedded tags'),
              value: settings.stripMetadata,
              onChanged: (value) => setState(
                () => settings = settings.copyWith(stripMetadata: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Keep original in recycle bin'),
              subtitle: const Text('Available when replacement is enabled'),
              value: settings.keepRecycleBin,
              onChanged: settings.replaceOriginal
                  ? (value) => setState(
                      () => settings = settings.copyWith(keepRecycleBin: value),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (canPreview)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(
                        context,
                        _CompressionSheetResult(
                          settings: settings,
                          preview: true,
                        ),
                      ),
                      icon: const Icon(Icons.preview_outlined),
                      label: const Text('Preview'),
                    ),
                  ),
                if (canPreview) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _showEstimatedSavings(context, savings),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _customize(CompressionSettings value) {
    setState(() => settings = value.copyWith(preset: CompressionPreset.custom));
  }

  Future<void> _showEstimatedSavings(BuildContext context, int savings) async {
    final shouldQueue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Estimated savings'),
        content: Text(
          'This selection could save about ${formatBytes(savings)}. Add it to the compression queue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Add to queue'),
          ),
        ],
      ),
    );
    if (shouldQueue == true && context.mounted) {
      Navigator.pop(
        context,
        _CompressionSheetResult(settings: settings, enqueue: true),
      );
    }
  }
}

class _PresetOptionCard extends StatelessWidget {
  const _PresetOptionCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final CompressionPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (title, description) = switch (preset) {
      CompressionPreset.light => (
        'High Quality',
        'Larger file size · best quality',
      ),
      CompressionPreset.balanced => (
        'Balanced (Recommended)',
        'Good size reduction · good quality',
      ),
      CompressionPreset.aggressive => (
        'High Compression',
        'Smaller file size · good quality',
      ),
      CompressionPreset.custom => (
        'Custom',
        'Set your own compression options',
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<CompressionPreset>(value: preset),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
    this.divisions,
  });
  final String label;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value$suffix'),
        ],
      ),
      Slider(
        value: value.toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: divisions,
        label: '$value$suffix',
        onChanged: (value) => onChanged(value.round()),
      ),
    ],
  );
}

class _PreviewSheet extends ConsumerWidget {
  const _PreviewSheet({required this.item, required this.preview});
  final MediaItem item;
  final Uint8List? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compression preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              item.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            if (preview == null)
              Text(
                'A preview is not available for this format yet.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else ...[
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: _PreviewImage(
                        future: ref
                            .read(mediaPlatformProvider)
                            .thumbnail(item.uri, MediaKind.image),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Image.memory(preview!, fit: BoxFit.cover)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Original\n${formatBytes(item.size)}'),
                  Text(
                    'Preview\n${formatBytes(preview!.length)}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.future});
  final Future<Uint8List?> future;

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: future,
    builder: (context, snapshot) => snapshot.hasData
        ? Image.memory(snapshot.data!, fit: BoxFit.cover)
        : ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
  );
}

class _FilterResult {
  const _FilterResult({this.threshold, this.range, this.format});
  final int? threshold;
  final DateTimeRange? range;
  final String? format;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.threshold,
    required this.range,
    required this.format,
    required this.formats,
    required this.onThreshold,
    required this.onRange,
    required this.onFormat,
  });
  final int? threshold;
  final DateTimeRange? range;
  final String? format;
  final List<String> formats;
  final ValueChanged<int?> onThreshold;
  final ValueChanged<DateTimeRange?> onRange;
  final ValueChanged<String?> onFormat;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? threshold = widget.threshold;
  late DateTimeRange? range = widget.range;
  late String? format = widget.format;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter library', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              for (final option in <int?>[
                null,
                10 * 1024 * 1024,
                50 * 1024 * 1024,
                100 * 1024 * 1024,
              ])
                ChoiceChip(
                  label: Text(
                    option == null ? 'Any size' : '> ${formatBytes(option)}',
                  ),
                  selected: threshold == option,
                  onSelected: (_) => setState(() => threshold = option),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.date_range_outlined),
                label: Text(
                  range == null
                      ? 'Any date'
                      : '${range!.start.month}/${range!.start.day} – ${range!.end.month}/${range!.end.day}',
                ),
              ),
              if (range != null)
                IconButton(
                  onPressed: () => setState(() => range = null),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear date',
                ),
            ],
          ),
          if (widget.formats.isNotEmpty)
            DropdownButton<String?>(
              value: format,
              isExpanded: true,
              hint: const Text('Any format'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any format'),
                ),
                ...widget.formats.map(
                  (item) =>
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                ),
              ],
              onChanged: (value) => setState(() => format = value),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _FilterResult(
                  threshold: threshold,
                  range: range,
                  format: format,
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: range,
    );
    if (picked != null) setState(() => range = picked);
  }
}
