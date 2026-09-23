import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/media/selection_controller.dart';

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    this.defaultPreset = CompressionPreset.balanced,
    this.notificationsEnabled = true,
  });

  final CompressionPreset defaultPreset;
  final bool notificationsEnabled;

  AppPreferencesState copyWith({
    CompressionPreset? defaultPreset,
    bool? notificationsEnabled,
  }) {
    return AppPreferencesState(
      defaultPreset: defaultPreset ?? this.defaultPreset,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class AppPreferencesController extends StateNotifier<AppPreferencesState> {
  AppPreferencesController() : super(const AppPreferencesState()) {
    _restore();
  }

  static const _presetKey = 'settings.defaultPreset';
  static const _notificationsKey = 'settings.notificationsEnabled';
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetName = prefs.getString(_presetKey);
      final preset = CompressionPreset.values.where((value) => value.name == presetName).firstOrNull;
      state = state.copyWith(
        defaultPreset: preset,
        notificationsEnabled: prefs.getBool(_notificationsKey),
      );
    } catch (_) {
      // Settings are optional; the privacy-safe in-memory defaults remain valid.
    }
  }

  Future<void> setDefaultPreset(CompressionPreset value) async {
    state = state.copyWith(defaultPreset: value);
    await _persist((prefs) => prefs.setString(_presetKey, value.name));
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _persist((prefs) => prefs.setBool(_notificationsKey, value));
  }

  Future<void> _persist(Future<void> Function(SharedPreferences prefs) write) async {
    try {
      await write(await SharedPreferences.getInstance());
    } catch (_) {
      // The in-memory setting already applies; persistence can retry next launch.
    }
  }
}

final appPreferencesProvider = StateNotifierProvider<AppPreferencesController, AppPreferencesState>(
  (ref) => AppPreferencesController(),
);

String presetLabel(CompressionPreset preset) => switch (preset) {
  CompressionPreset.light => 'Light',
  CompressionPreset.balanced => 'Balanced',
  CompressionPreset.aggressive => 'Aggressive',
  CompressionPreset.custom => 'Custom',
};
