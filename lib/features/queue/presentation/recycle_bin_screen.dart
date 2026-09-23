import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../presentation/widgets/common.dart';
import '../replace_original_service.dart';
import '../queue_providers.dart';

class RecycleBinScreen extends ConsumerWidget {
  const RecycleBinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(recycleBinProvider).valueOrNull ?? const [];
    final service = ref.read(replaceOriginalServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle bin'),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: 'Empty recycle bin',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmEmpty(context, service),
            ),
        ],
      ),
      body: entries.isEmpty
          ? const EmptyState(icon: Icons.restore_from_trash_outlined, title: 'Recycle bin is empty', message: 'Originals kept during replacement will appear here for 30 days.')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.restore_from_trash_outlined),
                    title: Text(entry.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${formatBytes(entry.size)} · expires ${entry.expiresAt.month}/${entry.expiresAt.day}/${entry.expiresAt.year}'),
                    trailing: TextButton(onPressed: () => _restore(context, service, entry), child: const Text('Restore')),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _restore(BuildContext context, ReplaceOriginalService service, dynamic entry) async {
    final result = await service.restore(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.succeeded ? 'Original restored.' : result.message ?? 'Restore failed.')));
  }

  Future<void> _confirmEmpty(BuildContext context, ReplaceOriginalService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty recycle bin?'),
        content: const Text('These backups will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Empty bin')),
        ],
      ),
    );
    if (confirmed == true) await service.empty();
  }
}
