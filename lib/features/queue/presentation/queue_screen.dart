import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/widgets/common.dart';
import '../../media/data/media_database.dart';
import '../../media/media_providers.dart';
import '../queue_controller.dart';
import '../queue_providers.dart';
import 'recycle_bin_screen.dart';
import 'results_screen.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  final Set<int> _selectedJobIds = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(queueControllerProvider.notifier).reconcileMissingOutputs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobs =
        ref.watch(queueJobsProvider).valueOrNull ?? const <CompressionJob>[];
    final queue = ref.watch(queueControllerProvider);
    final controller = ref.read(queueControllerProvider.notifier);
    final active = jobs
        .where((job) => job.status == 'running' || job.status == 'verifying')
        .length;
    final pending = jobs.where((job) => job.status == 'queued').length;
    final finished = jobs
        .where(
          (job) =>
              {'done', 'skipped', 'failed', 'cancelled'}.contains(job.status),
        )
        .length;
    final completed = jobs
        .where((job) => {'done', 'skipped'}.contains(job.status))
        .length;
    final failed = jobs.where((job) => job.status == 'failed').length;
    final replaceable = jobs
        .where((job) => job.status == 'done' && job.outputPath != null)
        .toList();
    final selectedForReplace = replaceable
        .where((job) => _selectedJobIds.contains(job.id))
        .toList();
    final current = jobs
        .where((job) => job.status == 'running' || job.status == 'verifying')
        .firstOrNull;
    final overall = jobs.isEmpty
        ? 0.0
        : ((finished + (current?.progress ?? 0)) / jobs.length).clamp(0.0, 1.0);
    final savings = jobs.fold<int>(
      0,
      (sum, job) =>
          sum +
          (job.outputSize == null ? 0 : job.originalSize - job.outputSize!),
    );
    final eta = _eta(queue.startedAt, overall, queue.status);

    if (jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.compress_outlined,
        title: 'No files ready to compress',
        message:
            'Choose files from All Files, select a compression option, and add them here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _ProcessingPanel(
          total: jobs.length,
          completed: completed,
          finished: finished,
          failed: failed,
          pending: pending,
          active: active,
          current: current,
          progress: overall,
          savings: savings,
          eta: eta,
          status: queue.status,
          notice: queue.notice,
          onStart: controller.start,
          onPause: controller.pause,
          onResume: controller.resume,
          onCancel: controller.cancel,
          onBackups: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const RecycleBinScreen()),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: SectionHeader(title: 'Compressed files')),
            if (finished > 0)
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ResultsScreen(),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View results'),
              ),
          ],
        ),
        if (queue.status == QueueRunStatus.idle && active == 0)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmClearQueue(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Clear queue & outputs'),
            ),
          ),
        if (replaceable.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedJobIds.length == replaceable.length,
                    onChanged: (selected) => setState(() {
                      _selectedJobIds
                        ..clear()
                        ..addAll(
                          selected == true
                              ? replaceable.map((job) => job.id)
                              : const <int>[],
                        );
                    }),
                  ),
                  Expanded(
                    child: Text(
                      selectedForReplace.isEmpty
                          ? 'Select files to replace'
                          : '${selectedForReplace.length} selected',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: selectedForReplace.isEmpty
                        ? null
                        : () async {
                            await _confirmReplaceSelected(
                              context,
                              ref,
                              selectedForReplace,
                            );
                            if (mounted) {
                              setState(_selectedJobIds.clear);
                            }
                          },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace selected'),
                  ),
                ],
              ),
            ),
          ),
        for (final job in jobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _JobTile(
              job: job,
              canSelect: job.status == 'done' && job.outputPath != null,
              isSelected: _selectedJobIds.contains(job.id),
              onSelected: () => setState(() {
                if (!_selectedJobIds.add(job.id)) {
                  _selectedJobIds.remove(job.id);
                }
              }),
            ),
          ),
      ],
    );
  }
}

class _ProcessingPanel extends StatelessWidget {
  const _ProcessingPanel({
    required this.total,
    required this.completed,
    required this.finished,
    required this.failed,
    required this.pending,
    required this.active,
    required this.current,
    required this.progress,
    required this.savings,
    required this.eta,
    required this.status,
    required this.notice,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onBackups,
  });

  final int total;
  final int completed;
  final int finished;
  final int failed;
  final int pending;
  final int active;
  final CompressionJob? current;
  final double progress;
  final int savings;
  final String? eta;
  final QueueRunStatus status;
  final String? notice;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onBackups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final panel = AppTheme.headerColor(context);
    final foreground = scheme.brightness == Brightness.dark
        ? scheme.onSurface
        : scheme.onPrimary;
    final running = status == QueueRunStatus.running;
    final paused = status == QueueRunStatus.paused;
    final label = current == null
        ? (failed > 0
              ? 'Finished with errors'
              : paused
              ? 'Paused'
              : pending > 0
              ? 'Ready to compress'
              : 'Compression complete')
        : current!.status == 'verifying'
        ? 'Verifying…'
        : 'Compressing…';
    return Card(
      color: panel,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 82,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 82,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: foreground.withValues(alpha: .18),
                          color: AppTheme.glowColor(context),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current?.displayName ??
                            '$completed of $total files completed',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: foreground),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$finished of $total files · $pending queued · $active active',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foreground.withValues(alpha: .82),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onBackups,
                  style: TextButton.styleFrom(foregroundColor: foreground),
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Backups'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressMetric(
                      label: 'Space saved',
                      value: formatBytes(savings),
                    ),
                  ),
                  Container(width: 1, height: 32, color: scheme.outlineVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressMetric(
                      label: 'Time remaining',
                      value: eta ?? '—',
                    ),
                  ),
                ],
              ),
            ),
            if (notice != null) ...[
              const SizedBox(height: 8),
              Text(
                notice!,
                textAlign: TextAlign.center,
                style: TextStyle(color: foreground),
              ),
            ],
            if (pending > 0 || running || paused) const SizedBox(height: 8),
            Row(
              children: [
                if (!running && !paused && pending > 0)
                  Expanded(
                    child: FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                if (running)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onPause,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                  ),
                if (paused)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onResume,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Continue'),
                    ),
                  ),
                if (running || paused) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: foreground,
                        side: BorderSide(color: foreground),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    ],
  );
}

String? _eta(DateTime? startedAt, double progress, QueueRunStatus status) {
  if (startedAt == null ||
      progress <= 0 ||
      progress >= 1 ||
      status != QueueRunStatus.running) {
    return null;
  }
  final elapsed = DateTime.now().difference(startedAt);
  final seconds = (elapsed.inSeconds * (1 - progress) / progress).round();
  final duration = Duration(seconds: seconds.clamp(0, 99 * 60 * 60));
  return duration.inHours > 0
      ? '${duration.inHours}h ${duration.inMinutes.remainder(60)}m'
      : '${duration.inMinutes}m';
}

class _JobTile extends ConsumerWidget {
  const _JobTile({
    required this.job,
    required this.canSelect,
    required this.isSelected,
    required this.onSelected,
  });

  final CompressionJob job;
  final bool canSelect;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (job.progress as num).toDouble().clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    final isActive = job.status == 'running' || job.status == 'verifying';
    final isError = job.status == 'failed' || job.status == 'cancelled';
    final isDone = job.status == 'done';
    final saved = job.outputSize == null
        ? null
        : (job.originalSize - job.outputSize!).clamp(0, job.originalSize);
    final statusColor = isError
        ? scheme.error
        : isDone
        ? SweeperColors.of(context).savings
        : isActive
        ? scheme.secondary
        : scheme.onSurfaceVariant;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canSelect)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onSelected(),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    _iconFor(job.mediaType),
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_mediaTypeLabel(job.mediaType)}  ·  ${formatBytes(job.originalSize)} original',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  label: _statusLabel(job.status),
                  color: statusColor,
                ),
              ],
            ),
            if (isDone && job.outputSize != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${formatBytes(job.originalSize)}  →  ${formatBytes(job.outputSize!)}',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (saved != null && saved > 0)
                      _StatusPill(
                        label: '${formatBytes(saved)} saved',
                        color: SweeperColors.of(context).savings,
                      ),
                  ],
                ),
              ),
            ],
            if (isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: LinearProgressIndicator(value: progress)),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
            if (job.errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: scheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.errorMessage!,
                        style: TextStyle(color: scheme.onErrorContainer),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (job.status == 'done' && job.outputPath != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ref
                            .read(mediaPlatformProvider)
                            .openPreview(
                              path: job.outputPath!,
                              mediaType: job.mediaType,
                            );
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Preview could not be opened: $error',
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Preview'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmReplace(context, ref, job),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace'),
                  ),
                ],
              ),
            ],
            if (job.status == 'done' && job.outputPath == null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(queueControllerProvider.notifier)
                      .requeueJob(job.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.replay),
                  label: const Text('Compress again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

Future<void> _confirmReplace(
  BuildContext context,
  WidgetRef ref,
  CompressionJob job,
) async {
  final keepBin = _keepRecycleBin(job.settingsJson);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Replace original?'),
      content: Text(
        keepBin
            ? 'Rigel Space Saver will verify the cached output, replace the original, and keep a recoverable copy for 30 days.'
            : 'Rigel Space Saver will verify the cached output and permanently replace the original. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Replace original'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final result = await ref
      .read(replaceOriginalServiceProvider)
      .replace(job: job, keepInRecycleBin: keepBin);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result.succeeded
            ? 'Original replaced safely.'
            : result.message ?? 'Replacement failed.',
      ),
    ),
  );
}

Future<void> _confirmReplaceSelected(
  BuildContext context,
  WidgetRef ref,
  List<CompressionJob> jobs,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Replace ${jobs.length} selected originals?'),
      content: const Text(
        'Each verified compressed output will be checked again before replacement. '
        'Recycle-bin backup settings will be respected for every file.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Replace selected'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(content: Text('Replacing ${jobs.length} originals safely…')),
  );
  var succeeded = 0;
  final failures = <String>[];
  final service = ref.read(replaceOriginalServiceProvider);
  for (final job in jobs) {
    final result = await service.replace(
      job: job,
      keepInRecycleBin: _keepRecycleBin(job.settingsJson),
    );
    if (result.succeeded) {
      succeeded++;
    } else {
      failures.add(
        '${job.displayName}: ${result.message ?? 'Replacement failed.'}',
      );
    }
  }
  if (!context.mounted) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        failures.isEmpty
            ? '$succeeded selected originals replaced safely.'
            : '$succeeded replaced, ${failures.length} failed: ${failures.first}',
      ),
    ),
  );
}

Future<void> _confirmClearQueue(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Clear compression queue?'),
      content: const Text(
        'This removes the queue records and temporary compressed outputs so you can choose files and settings again. '
        'Original media, recycle-bin backups, and saved history totals are not deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep queue'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Clear queue'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    final removed = await ref
        .read(queueControllerProvider.notifier)
        .clearQueue();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleared $removed queue item${removed == 1 ? '' : 's'}.'),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Queue could not be cleared: $error')),
    );
  }
}

bool _keepRecycleBin(String settingsJson) {
  try {
    return (jsonDecode(settingsJson)
            as Map<String, dynamic>)['keepRecycleBin'] ==
        true;
  } catch (_) {
    // Malformed historical settings default to keeping no destructive backup.
    return false;
  }
}

String _statusLabel(String value) => switch (value) {
  'queued' => 'Queued',
  'running' => 'Compressing',
  'verifying' => 'Verifying',
  'done' => 'Done',
  'skipped' => 'Skipped',
  'failed' => 'Failed',
  'cancelled' => 'Cancelled',
  _ => value,
};

IconData _iconFor(String value) => switch (value) {
  'image' => Icons.image_outlined,
  'video' => Icons.movie_outlined,
  _ => Icons.music_note_outlined,
};

String _mediaTypeLabel(String value) => switch (value) {
  'image' => 'Photo',
  'video' => 'Video',
  'audio' => 'Audio',
  _ => 'Media',
};
