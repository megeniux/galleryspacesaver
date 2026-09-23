import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/media/data/media_database.dart';
import '../../features/media/data/media_platform.dart';
import '../../features/media/media_providers.dart';
import '../../features/media/selection_controller.dart';
import '../../features/media/selection_estimator.dart';
import '../widgets/common.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({required this.onOpenFiles, super.key});

  final VoidCallback onOpenFiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sweeperColors = SweeperColors.of(context);
    final items =
        ref.watch(mediaItemsProvider).valueOrNull ?? const <MediaItem>[];
    final storage = ref.watch(storageInfoProvider).valueOrNull;
    final compressionSettings = ref.watch(selectionControllerProvider).settings;
    final totals = <String, int>{'image': 0, 'video': 0, 'audio': 0};
    final counts = <String, int>{'image': 0, 'video': 0, 'audio': 0};
    for (final item in items) {
      totals[item.mediaType] = (totals[item.mediaType] ?? 0) + item.size;
      counts[item.mediaType] = (counts[item.mediaType] ?? 0) + 1;
    }
    final usedFraction = storage == null || storage.totalBytes == 0
        ? 0.0
        : (storage.usedBytes / storage.totalBytes).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Text(
              'DEVICE OVERVIEW',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: sweeperColors.savings,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: sweeperColors.savings.withValues(alpha: .65),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: sweeperColors.savings,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            // The media card has one more legend row than storage. Measuring
            // first gives the row a finite height, then stretching keeps both
            // overview cards aligned without a device-specific fixed height.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StorageOverviewCard(
                  storage: storage,
                  usedFraction: usedFraction,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MediaOverviewCard(
                  totals: totals,
                  colors: <String, Color>{
                    'image': sweeperColors.photos,
                    'video': sweeperColors.videos,
                    'audio': sweeperColors.audio,
                  },
                ),
              ),
            ],
          ),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 20),
          _EasySavings(
            items: items,
            settings: compressionSettings,
            onOpenFiles: onOpenFiles,
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onOpenFiles,
          icon: const Icon(Icons.bolt_rounded),
          label: const Text('Start Saving Space'),
        ),
        const SizedBox(height: 24),
        SectionHeader(title: 'Quick Tools'),
        const SizedBox(height: 10),
        _QuickTools(
          totals: totals,
          counts: counts,
          onOpenKind: (kind) {
            ref.read(libraryKindFocusProvider.notifier).state = kind;
            onOpenFiles();
          },
          onOpenFiles: onOpenFiles,
        ),
      ],
    );
  }
}

class _EasySavings extends StatelessWidget {
  const _EasySavings({
    required this.items,
    required this.settings,
    required this.onOpenFiles,
  });

  final List<MediaItem> items;
  final CompressionSettings settings;
  final VoidCallback onOpenFiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final candidates = [...items]..sort((a, b) => b.size.compareTo(a.size));
    final largest = candidates.take(3).toList();
    final potential = estimateSelectedSavings(largest, settings);
    return SpaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Easy savings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '~${formatBytes(potential)} possible',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: SweeperColors.of(context).savings,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Start with your largest files for the fastest win.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final item in largest)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  GlowIcon(
                    item.mediaType == MediaKind.video.name
                        ? Icons.movie_rounded
                        : item.mediaType == MediaKind.audio.name
                        ? Icons.graphic_eq_rounded
                        : Icons.image_rounded,
                    size: 34,
                    color: SweeperColors.of(context).savings,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatBytes(item.size),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenFiles,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Review files'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  const _StorageOverviewCard({
    required this.storage,
    required this.usedFraction,
  });

  final StorageInfo? storage;
  final double usedFraction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SpaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage_rounded, color: scheme.primary, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Storage',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: _StorageRing(
              storage: storage,
              usedFraction: usedFraction,
              dimension: 112,
            ),
          ),
          const SizedBox(height: 6),
          _StorageLegend(
            color: AppColors.logoBlue,
            label: 'Used',
            value: storage == null ? '—' : formatBytes(storage!.usedBytes),
          ),
          const SizedBox(height: 5),
          _StorageLegend(
            color: scheme.secondary,
            label: 'Free',
            value: storage == null ? '—' : formatBytes(storage!.freeBytes),
          ),
        ],
      ),
    );
  }
}

class _MediaOverviewCard extends StatelessWidget {
  const _MediaOverviewCard({required this.totals, required this.colors});

  final Map<String, int> totals;
  final Map<String, Color> colors;

  static const _labels = <String, String>{
    'image': 'Photos',
    'video': 'Videos',
    'audio': 'Audio',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = totals.values.fold<int>(0, (sum, value) => sum + value);
    return SpaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.donut_large_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Media',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: SizedBox.square(
              dimension: 112,
              child: CustomPaint(
                painter: _MediaDistributionPainter(
                  values: totals,
                  colors: colors,
                  trackColor: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: SizedBox(
                    // Keep the label inside the donut hole (112 - 2*7 - 18).
                    width: (112 - 32) * 0.82,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatBytes(total),
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in _labels.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: _MediaLegend(
                color: colors[entry.key]!,
                label: entry.value,
                value: total == 0
                    ? '0%'
                    : '${((totals[entry.key] ?? 0) * 100 / total).round()}%',
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaLegend extends StatelessWidget {
  const _MediaLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    ],
  );
}

class _StorageRing extends StatelessWidget {
  const _StorageRing({
    required this.storage,
    required this.usedFraction,
    this.dimension = 152,
  });

  final StorageInfo? storage;
  final double usedFraction;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    // The painter insets the arc by 7px and strokes it 18px wide, so the empty
    // hole is `dimension - 32`. Text must stay inside the square inscribed in
    // that hole, otherwise long values like "512.0 GB" ride over the chart.
    final innerDiameter = dimension - 32;
    final labelWidth = innerDiameter * 0.82;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: usedFraction),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: dimension,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(dimension),
              painter: _StorageDonutPainter(
                usedFraction: value,
                usedColor: AppColors.logoBlue,
                freeColor: Theme.of(context).colorScheme.secondary,
                trackColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            SizedBox(
              width: labelWidth,
              height: innerDiameter * 0.68,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        storage == null
                            ? '—'
                            : formatBytes(storage!.totalBytes),
                        maxLines: 1,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'TOTAL',
                      maxLines: 1,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageDonutPainter extends CustomPainter {
  const _StorageDonutPainter({
    required this.usedFraction,
    required this.usedColor,
    required this.freeColor,
    required this.trackColor,
  });

  final double usedFraction;
  final Color usedColor;
  final Color freeColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const chartStroke = 18.0;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 7;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final free = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStroke
      ..strokeCap = StrokeCap.round
      ..color = freeColor;
    final used = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStroke
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [usedColor, AppColors.cyan],
      ).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    final usedSweep = math.pi * 2 * usedFraction;
    final freeSweep = math.pi * 2 * (1 - usedFraction);
    canvas.drawArc(rect, -math.pi / 2 + usedSweep, freeSweep, false, free);
    canvas.drawArc(rect, -math.pi / 2, usedSweep, false, used);
  }

  @override
  bool shouldRepaint(covariant _StorageDonutPainter oldDelegate) =>
      oldDelegate.usedFraction != usedFraction ||
      oldDelegate.usedColor != usedColor ||
      oldDelegate.freeColor != freeColor;
}

class _StorageLegend extends StatelessWidget {
  const _StorageLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    ],
  );
}

class _MediaDistributionChart extends StatelessWidget {
  const _MediaDistributionChart({required this.totals, required this.colors});

  final Map<String, int> totals;
  final Map<String, Color> colors;

  static const _labels = <String, String>{
    'image': 'Photos',
    'video': 'Videos',
    'audio': 'Audio',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = totals.values.fold<int>(0, (sum, value) => sum + value);
    return SpaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 142,
            child: CustomPaint(
              painter: _MediaDistributionPainter(
                values: totals,
                colors: colors,
                trackColor: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: Text(
                  formatBytes(total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: _labels.entries.map((entry) {
                final value = totals[entry.key] ?? 0;
                final share = total == 0 ? 0 : value / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[entry.key],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${(share * 100).round()}%',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaDistributionPainter extends CustomPainter {
  const _MediaDistributionPainter({
    required this.values,
    required this.colors,
    required this.trackColor,
  });

  final Map<String, int> values;
  final Map<String, Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.values.fold<int>(0, (sum, value) => sum + value);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (final key in _MediaDistributionChart._labels.keys) {
      final value = values[key] ?? 0;
      if (value == 0) continue;
      final sweep = math.pi * 2 * value / total;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = colors[key]!;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MediaDistributionPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.trackColor != trackColor;
}

class _QuickTools extends StatelessWidget {
  const _QuickTools({
    required this.totals,
    required this.counts,
    required this.onOpenKind,
    required this.onOpenFiles,
  });

  final Map<String, int> totals;
  final Map<String, int> counts;
  final void Function(MediaKind kind) onOpenKind;
  final VoidCallback onOpenFiles;

  String _summary(String key, String empty) {
    final count = counts[key] ?? 0;
    if (count == 0) return empty;
    final size = formatBytes(totals[key] ?? 0);
    return '$count file${count == 1 ? '' : 's'} · $size to work with';
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _QuickToolTile(
        icon: Icons.movie_filter_rounded,
        title: 'Shrink big videos',
        subtitle: _summary('video', 'No videos found yet'),
        onPressed: () => onOpenKind(MediaKind.video),
      ),
      const SizedBox(height: 10),
      _QuickToolTile(
        icon: Icons.photo_size_select_large_rounded,
        title: 'Shrink large photos',
        subtitle: _summary('image', 'No photos found yet'),
        onPressed: () => onOpenKind(MediaKind.image),
      ),
      const SizedBox(height: 10),
      _QuickToolTile(
        icon: Icons.audiotrack_rounded,
        title: 'Compress audio',
        subtitle: _summary('audio', 'No audio found yet'),
        onPressed: () => onOpenKind(MediaKind.audio),
      ),
      const SizedBox(height: 10),
      _QuickToolTile(
        icon: Icons.sort_rounded,
        title: 'Biggest files first',
        subtitle: 'Review everything, largest to smallest',
        onPressed: onOpenFiles,
      ),
    ],
  );
}

class _QuickToolTile extends StatelessWidget {
  const _QuickToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SpaceCard(
    padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
    child: Row(
      children: [
        GlowIcon(icon, size: 44, color: SweeperColors.of(context).savings),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 3),
              Text(subtitle),
            ],
          ),
        ),
        IconButton(
          tooltip: title,
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ],
    ),
  );
}
