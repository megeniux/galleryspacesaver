import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-controlled appearance settings.
@immutable
class AppearanceState {
  // Dark is the brand-first default; users can still choose light or system.
  const AppearanceState({this.themeMode = ThemeMode.dark});

  final ThemeMode themeMode;

  AppearanceState copyWith({ThemeMode? themeMode}) =>
      AppearanceState(themeMode: themeMode ?? this.themeMode);
}

class AppearanceController extends StateNotifier<AppearanceState> {
  AppearanceController() : super(const AppearanceState()) {
    _restore();
  }

  static const _kThemeMode = 'appearance.themeMode';
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_kThemeMode);
      state = state.copyWith(
        themeMode: modeIndex != null && modeIndex < ThemeMode.values.length
            ? ThemeMode.values[modeIndex]
            : null,
      );
    } catch (_) {
      // Appearance is cosmetic; defaults are a safe outcome.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist((prefs) => prefs.setInt(_kThemeMode, mode.index));
  }

  Future<void> _persist(
    Future<void> Function(SharedPreferences prefs) write,
  ) async {
    try {
      await write(await SharedPreferences.getInstance());
    } catch (_) {
      // The in-memory change already applied; persistence is best effort.
    }
  }
}

final appearanceControllerProvider =
    StateNotifierProvider<AppearanceController, AppearanceState>(
      (ref) => AppearanceController(),
    );
