import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../features/media/presentation/library_screen.dart';
import '../../features/media/data/media_platform.dart';
import '../../features/media/media_providers.dart';
import '../../features/queue/presentation/queue_screen.dart';
import '../../features/savings/presentation/savings_screen.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_dashboard.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';

/// Root shell using the five visual destinations from the approved design.
/// The existing Library, Queue and Savings flows remain the source of truth.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Rigel Space Saver',
    'All Files',
    'Compression Queue',
    'History',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showOnboardingIfNeeded();
      await _requestMediaAccessIfNeeded();
    });
  }

  Future<void> _requestMediaAccessIfNeeded() async {
    final repository = ref.read(mediaRepositoryProvider);
    var status = await repository.permissionStatus();
    final needsMoreMediaAccess =
        status.state != MediaPermissionState.granted &&
        status.state != MediaPermissionState.permanentlyDenied;
    if (needsMoreMediaAccess) {
      status = await repository.requestPermissions();
      if (status.canScan) {
        await repository.scan();
        ref.invalidate(mediaItemsProvider);
      }
    }
    if (mounted) {
      ref.read(mediaPermissionStateProvider.notifier).state = status;
    }
  }

  Future<void> _showOnboardingIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted || prefs.getBool('onboarding.complete') == true) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const OnboardingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      // Bottom navigation changes the shell tab without creating a route. Keep
      // Android back intuitive by returning to Home before allowing app exit.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) setState(() => _index = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 72,
          centerTitle: _index == 0,
          flexibleSpace: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient(context),
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              tooltip: 'Open navigation menu',
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: _index == 0
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandLogo(size: 50, borderRadius: 15),
                    SizedBox(width: 12),
                    Text(
                      'Rigel Space Saver',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : Text(_titles[_index]),
          actions: [
            if (_index == 0)
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => setState(() => _index = 4),
              ),
          ],
        ),
        drawer: _NavigationDrawer(
          selectedIndex: _index,
          onSelected: (index) => setState(() => _index = index),
        ),
        body: IndexedStack(
          index: _index,
          children: [
            HomeDashboard(onOpenFiles: () => setState(() => _index = 1)),
            const LibraryScreen(),
            const QueueScreen(),
            const SavingsScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(gradient: AppTheme.brandGradient(context)),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: 'Files',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Compress',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.brightness == Brightness.dark
        ? scheme.onSurface
        : scheme.onPrimary;
    return Drawer(
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.brandGradient(context)),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Row(
                  children: [
                    BrandLogo(
                      size: 76,
                      borderRadius: 20,
                      shadowColor: scheme.secondary,
                      shadowOpacity: .18,
                      shadowBlurRadius: 13,
                      shadowSpreadRadius: .5,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Rigel Space Saver',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => _select(context, 0),
              ),
              _DrawerItem(
                icon: Icons.folder_outlined,
                label: 'All Files',
                selected: selectedIndex == 1,
                onTap: () => _select(context, 1),
              ),
              _DrawerItem(
                icon: Icons.history_outlined,
                label: 'History',
                selected: selectedIndex == 3,
                onTap: () => _select(context, 3),
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                selected: selectedIndex == 4,
                onTap: () => _select(context, 4),
              ),
              Divider(color: foreground.withValues(alpha: .24), height: 28),
              _DrawerItem(
                icon: Icons.help_outline,
                label: 'Help & FAQ',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.feedback_outlined,
                label: 'Send Feedback',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.star_outline,
                label: 'Rate the App',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, int index) {
    Navigator.pop(context);
    onSelected(index);
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.brightness == Brightness.dark
        ? scheme.onSurface
        : scheme.onPrimary;
    return ListTile(
      leading: Icon(icon, color: foreground),
      title: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
      selected: selected,
      selectedTileColor: scheme.primary.withValues(alpha: .16),
      onTap: onTap,
    );
  }
}
