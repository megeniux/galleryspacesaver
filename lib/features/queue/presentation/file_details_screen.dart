import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../media/data/media_database.dart';
import '../../media/data/media_platform.dart';
import '../../media/media_providers.dart';

class FileDetailsScreen extends ConsumerStatefulWidget {
  const FileDetailsScreen({required this.job, super.key});

  final CompressionJob job;

  @override
  ConsumerState<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends ConsumerState<FileDetailsScreen> {
  late final Future<Uint8List?> _thumbnail = _loadThumbnail();

  Future<Uint8List?> _loadThumbnail() {
    if (widget.job.mediaType == MediaKind.audio.name) return Future.value();
    return ref
        .read(mediaPlatformProvider)
        .thumbnail(
          widget.job.inputUri,
          MediaKind.values.byName(widget.job.mediaType),
        );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final output = job.outputSize;
    final saved = output == null
        ? null
        : (job.originalSize - output).clamp(0, job.originalSize);
    final percent = saved == null || job.originalSize == 0
        ? 0
        : ((saved / job.originalSize) * 100).round();
    final savingsColor = SweeperColors.of(context).savings;
    return Scaffold(
      appBar: AppBar(title: const Text('File Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 220,
              child: _Preview(job: job, future: _thumbnail),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Original Size',
                    value: formatBytes(job.originalSize),
                  ),
                  _DetailRow(
                    label: 'New Size',
                    value: output == null ? '—' : formatBytes(output),
                  ),
                  _DetailRow(
                    label: 'Saved',
                    value: saved == null
                        ? '—'
                        : '${formatBytes(saved)} ($percent%)',
                    valueColor: savingsColor,
                  ),
                  _DetailRow(label: 'Type', value: job.mediaType.toUpperCase()),
                  _DetailRow(label: 'Status', value: _status(job.status)),
                  _DetailRow(label: 'Date', value: _formatDate(job.updatedAt)),
                  _DetailRow(
                    label: 'Location',
                    value: job.status == 'done'
                        ? 'Compressed output ready'
                        : 'Original retained',
                    valueColor: job.status == 'done' ? savingsColor : null,
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.job, required this.future});

  final CompressionJob job;
  final Future<Uint8List?> future;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        }
        return ColoredBox(
          color: scheme.primaryContainer,
          child: Center(
            child: Icon(
              _mediaIcon(job.mediaType),
              size: 64,
              color: AppTheme.iconAccent(context),
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      if (showDivider) const Divider(),
    ],
  );
}

IconData _mediaIcon(String value) => switch (value) {
  'image' => Icons.image_outlined,
  'video' => Icons.movie_outlined,
  _ => Icons.music_note_outlined,
};

String _status(String value) => switch (value) {
  'done' => 'Completed',
  'skipped' => 'Skipped',
  'failed' => 'Failed',
  'cancelled' => 'Cancelled',
  _ => value,
};

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}
