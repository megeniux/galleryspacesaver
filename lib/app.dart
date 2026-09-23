import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/appearance_controller.dart';
import 'presentation/screens/splash_screen.dart';

class RigelGallerySweeperApp extends ConsumerWidget {
  const RigelGallerySweeperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);

    return MaterialApp(
      title: 'Rigel Space Saver',
      debugShowCheckedModeBanner: false,
      themeMode: appearance.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      home: const SplashScreen(),
    );
  }
}
