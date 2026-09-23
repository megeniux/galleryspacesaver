import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../presentation/widgets/common.dart';
import '../../media/data/media_database.dart';
import '../../queue/presentation/results_screen.dart';
import '../savings_providers.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sessions =
        ref.watch(savingsSessionsProvider).valueOrNull ??
        const <SavingsSession>[];
    final totalFreed = sessions.fold<int>(
      0,
      (sum, session) => sum + session.bytesFreed,
    );
    final totalFiles = sessions.fold<int>(
      0,
      (sum, session) => sum + session.filesProcessed,
    );
    if (sessions.isEmpty) {
      return const EmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'No sweeps logged yet',
        message: 'Your recovered space and compression runs will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Text(
              'RECOVERY LOG',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Icon(Icons.radar_rounded, size: 18, color: scheme.secondary),
          ],
        ),
        const SizedBox(height: 10),
        SpaceCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              GlowIcon(
                Icons.storage_rounded,
                size: 60,
                color: scheme.secondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Space recovered',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatBytes(totalFreed),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$totalFiles files across ${sessions.length} sweeps',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'Latest sweeps',
          trailing: Text(
            'TAP TO OPEN',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ),
        for (final session in sessions) _SessionTile(session: session),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final SavingsSession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final successful = session.failedCount == 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SpaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultsScreen(since: session.startedAt),
          ),
        ),
        child: Row(
          children: [
            GlowIcon(
              Icons.auto_awesome_rounded,
              size: 46,
              color: successful ? AppColors.savings : AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.filesProcessed} files compressed',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatBytes(session.bytesFreed)} recovered  ·  ${_formatDate(session.startedAt)}',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(
              successful ? Icons.check_circle_rounded : Icons.info_rounded,
              color: successful ? AppColors.savings : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year}, $hour:$minute';
}
