import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../presentation/widgets/common.dart';
import '../replace_original_service.dart';
import '../queue_providers.dart';

class RecycleBinScreen extends ConsumerStatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  ConsumerState<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends ConsumerState<RecycleBinScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(replaceOriginalServiceProvider).recoverOrphanedBackups(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(recycleBinProvider).valueOrNull ?? const [];
    final service = ref.read(replaceOriginalServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Original backups'),
        actions: [
          if (entries.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmEmpty(context, service),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Empty backups'),
            ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyState(
              icon: Icons.restore_from_trash_outlined,
              title: 'No original backups',
              message:
                  'Original versions kept during replacement will appear here for 30 days. This screen does not clear the compression queue or output cache.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: entries.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'These are recoverable copies of originals. Restore puts a copy back in your gallery. Queue cleanup and compressed-output cleanup are separate actions.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final entry = entries[index - 1];
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.restore_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatBytes(entry.size)}  ·  Expires ${entry.expiresAt.month}/${entry.expiresAt.day}/${entry.expiresAt.year}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => _restore(context, service, entry),
                          child: const Text('Restore'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    ReplaceOriginalService service,
    dynamic entry,
  ) async {
    final result = await service.restore(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.succeeded
              ? 'Original restored safely.'
              : result.message ?? 'Restore failed.',
        ),
      ),
    );
  }

  Future<void> _confirmEmpty(
    BuildContext context,
    ReplaceOriginalService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete original backups?'),
        content: const Text(
          'These recovery copies will be permanently deleted. Your gallery files, compression queue, and compressed-output cache are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete backups'),
          ),
        ],
      ),
    );
    if (confirmed == true) await service.empty();
  }
}
