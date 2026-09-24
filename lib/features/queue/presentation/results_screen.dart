import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../presentation/widgets/common.dart';
import '../../media/data/media_database.dart';
import '../queue_controller.dart';
import 'file_details_screen.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key, this.since});

  final DateTime? since;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs =
        ref.watch(queueJobsProvider).valueOrNull ?? const <CompressionJob>[];
    final completed = jobs.where((job) {
      final inSession = since == null || !job.updatedAt.isBefore(since!);
      return inSession &&
          {'done', 'skipped', 'failed', 'cancelled'}.contains(job.status);
    }).toList();
    if (completed.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No results yet',
          message: 'Run a compression batch to see its report here.',
        ),
      );
    }

    final original = completed.fold<int>(
      0,
      (sum, job) => sum + job.originalSize,
    );
    final newSize = completed.fold<int>(
      0,
      (sum, job) => sum + (job.outputSize ?? job.originalSize),
    );
    final saved = (original - newSize).clamp(0, original);
    final savedPercent = original == 0 ? 0 : ((saved / original) * 100).round();
    final skipped = completed.where((job) => job.status == 'skipped').length;
    final failed = completed.where((job) => job.status == 'failed').length;
    final done = completed.where((job) => job.status == 'done').length;
    final savingsColor = SweeperColors.of(context).savings;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          Center(
            child: Semantics(
              label: 'Compression completed successfully',
              child: Lottie.asset(
                'assets/lottie/success.json',
                width: 118,
                height: 118,
                repeat: false,
              ),
            ),
          ),
          Text(
            'Compression Complete!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '$done files processed successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text('Total Savings'),
                  const SizedBox(height: 4),
                  Text(
                    formatBytes(saved),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: savingsColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '($savedPercent% smaller)',
                    style: TextStyle(
                      color: savingsColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              children: [
                _ResultRow(
                  label: 'Original Size',
                  value: formatBytes(original),
                ),
                _ResultRow(
                  label: 'New Size',
                  value: formatBytes(newSize),
                  valueColor: savingsColor,
                ),
                _ResultRow(label: 'Files Processed', value: '$done'),
                _ResultRow(label: 'Files Skipped', value: '$skipped'),
                _ResultRow(
                  label: 'Files Failed',
                  value: '$failed',
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'File details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final job in completed) _ResultTile(job: job),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(),
    ],
  );
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.job});

  final CompressionJob job;

  @override
  Widget build(BuildContext context) {
    final output = job.outputSize;
    final saved = output == null ? null : job.originalSize - output;
    final scheme = Theme.of(context).colorScheme;
    final hasError = job.status == 'failed' || job.status == 'cancelled';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasError ? scheme.errorContainer : null,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => FileDetailsScreen(job: job)),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _mediaIcon(job.mediaType),
            color: AppTheme.iconAccent(context),
          ),
        ),
        title: Text(
          job.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: saved != null && saved > 0
            ? Text('${formatBytes(saved)} saved')
            : Text(
                job.errorMessage ?? _status(job.status),
                style: hasError
                    ? TextStyle(color: scheme.onErrorContainer)
                    : null,
              ),
        trailing: Icon(
          job.status == 'done' ? Icons.check_circle : Icons.info_outline,
          color: job.status == 'done'
              ? SweeperColors.of(context).savings
              : hasError
              ? scheme.onErrorContainer
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

IconData _mediaIcon(String value) => switch (value) {
  'image' => Icons.image_outlined,
  'video' => Icons.movie_outlined,
  _ => Icons.music_note_outlined,
};

String _status(String value) => switch (value) {
  'done' => 'Done',
  'skipped' => 'Skipped',
  'failed' => 'Failed',
  'cancelled' => 'Cancelled',
  _ => value,
};
