import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_preferences.dart';
import '../../core/settings/cache_management_service.dart';
import '../../core/theme/appearance_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../features/media/selection_controller.dart';
import '../../features/queue/queue_controller.dart';
import '../../features/queue/presentation/recycle_bin_screen.dart';
import '../widgets/common.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    final preferences = ref.watch(appPreferencesProvider);
    final preferencesController = ref.read(appPreferencesProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const SectionHeader(title: 'Appearance'),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_themeModeLabel(appearance.themeMode)),
                leading: const Icon(Icons.brightness_6_outlined),
                onTap: () => _pickThemeMode(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Compression'),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: const Text('Default preset'),
                subtitle: Text(presetLabel(preferences.defaultPreset)),
                leading: const Icon(Icons.tune_outlined),
                onTap: () => _pickPreset(context, ref),
              ),
              SwitchListTile(
                value: preferences.notificationsEnabled,
                onChanged: preferencesController.setNotificationsEnabled,
                secondary: const Icon(Icons.notifications_none_outlined),
                title: const Text('Completion notifications'),
                subtitle: const Text('Allow optional batch-finished reminders'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Privacy'),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.lock_outline,
                  color: AppTheme.iconAccent(context),
                ),
                title: const Text('Everything happens on your device'),
                subtitle: const Text(
                  'Your media never leaves the device. Compression runs offline.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Storage'),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.restore_from_trash_outlined),
                title: const Text('Original backups'),
                subtitle: const Text(
                  'Restore saved originals; separate from queue and cache',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RecycleBinScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Clear compression cache'),
                subtitle: const Text(
                  'Remove temporary outputs; queue records remain',
                ),
                onTap: () => _confirmClearCache(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Follow system',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appearanceControllerProvider).themeMode;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (value) => Navigator.pop(sheetContext, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (mode) => RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_themeModeLabel(mode)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(appearanceControllerProvider.notifier)
          .setThemeMode(selected);
    }
  }

  Future<void> _pickPreset(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appPreferencesProvider).defaultPreset;
    final selected = await showModalBottomSheet<CompressionPreset>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<CompressionPreset>(
          groupValue: current,
          onChanged: (value) => Navigator.pop(sheetContext, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: CompressionPreset.values
                .where((preset) => preset != CompressionPreset.custom)
                .map(
                  (preset) => RadioListTile<CompressionPreset>(
                    value: preset,
                    title: Text(presetLabel(preset)),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(appPreferencesProvider.notifier)
          .setDefaultPreset(selected);
    }
  }

  Future<void> _confirmClearCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear compression cache?'),
        content: const Text(
          'Temporary compressed outputs and staging files will be deleted. Originals and recycle-bin backups are not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear cache'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await CacheManagementService().clearCompressionCache();
    final requeued = await ref
        .read(queueControllerProvider.notifier)
        .reconcileMissingOutputs();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removed == 0 && requeued == 0
              ? 'Compression cache is already empty.'
              : 'Removed $removed cache item${removed == 1 ? '' : 's'}; '
                    '$requeued job${requeued == 1 ? '' : 's'} ready to compress again.',
        ),
      ),
    );
  }
}
