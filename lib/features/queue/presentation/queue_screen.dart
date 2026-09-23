import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/widgets/common.dart';
import '../../media/data/media_database.dart';
import '../queue_controller.dart';
import '../queue_providers.dart';
import 'recycle_bin_screen.dart';
import 'results_screen.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          finished: finished,
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
          onRecycleBin: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const RecycleBinScreen()),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: SectionHeader(title: 'Files')),
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
        for (final job in jobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _JobTile(job: job),
          ),
      ],
    );
  }
}

class _ProcessingPanel extends StatelessWidget {
  const _ProcessingPanel({
    required this.total,
    required this.finished,
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
    required this.onRecycleBin,
  });

  final int total;
  final int finished;
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
  final VoidCallback onRecycleBin;

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
        ? (paused
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
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onRecycleBin,
                tooltip: 'Recycle bin',
                icon: Icon(
                  Icons.restore_from_trash_outlined,
                  color: foreground,
                ),
              ),
            ),
            SizedBox.square(
              dimension: 152,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: 152,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 13,
                      backgroundColor: foreground.withValues(alpha: .18),
                      color: AppTheme.glowColor(context),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              current?.displayName ?? '$finished of $total files completed',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground),
            ),
            const SizedBox(height: 4),
            Text(
              '$finished of $total files · $pending queued · $active active',
              style: TextStyle(color: foreground.withValues(alpha: .82)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressMetric(
                      label: 'Space Saved',
                      value: formatBytes(savings),
                    ),
                  ),
                  Expanded(
                    child: _ProgressMetric(
                      label: 'Time Remaining',
                      value: eta ?? '—',
                    ),
                  ),
                ],
              ),
            ),
            if (notice != null) ...[
              const SizedBox(height: 10),
              Text(
                notice!,
                textAlign: TextAlign.center,
                style: TextStyle(color: foreground),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                if (!running && !paused && pending > 0)
                  Expanded(
                    child: FilledButton(
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.surface,
                        foregroundColor: scheme.primary,
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                if (running)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onPause,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.surface,
                        foregroundColor: scheme.primary,
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
                        backgroundColor: scheme.surface,
                        foregroundColor: scheme.primary,
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
  const _JobTile({required this.job});

  final CompressionJob job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _statusLabel(job.status);
    final progress = (job.progress as num).toDouble().clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(job.mediaType), color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(status, style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
            if (!{
              'done',
              'skipped',
              'failed',
              'cancelled',
            }.contains(job.status)) ...[
              const SizedBox(height: 8),
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
            const SizedBox(height: 7),
            Text(
              '${formatBytes(job.originalSize)} · attempt ${job.attempts}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            if (job.errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                job.errorMessage!,
                style: TextStyle(color: scheme.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (job.status == 'done' && job.outputPath != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReplace(context, ref, job),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Replace original'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
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
