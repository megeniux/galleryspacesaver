import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wallpaper-derived accent colors exposed by Android 12+ (Material You).
@immutable
class SystemPalette {
  const SystemPalette({
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.neutral1,
  });

  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color neutral1;

  ColorScheme toScheme(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: accent1,
    brightness: brightness,
    secondary: accent2,
    tertiary: accent3,
  );
}

/// Reads the Android system palette over a platform channel.
///
/// This replaces the `dynamic_color` package, which cannot be built against the
/// project's current Kotlin/AGP toolchain (1.9.x) or Dart SDK (2.x).
class SystemPaletteService {
  const SystemPaletteService();

  static const MethodChannel _channel = MethodChannel(
    'com.techrigel.rigelspacesaver/system_palette',
  );

  /// Returns the device palette, or null when unavailable (pre-Android 12,
  /// non-Android platforms, or OEM builds missing the system color resources).
  Future<SystemPalette?> read() async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMapMethod<String, int>(
        'getSeedColors',
      );
      if (result == null) return null;

      final accent1 = result['accent1'];
      final accent2 = result['accent2'];
      final accent3 = result['accent3'];
      final neutral1 = result['neutral1'];
      if (accent1 == null ||
          accent2 == null ||
          accent3 == null ||
          neutral1 == null) {
        return null;
      }

      return SystemPalette(
        accent1: Color(accent1),
        accent2: Color(accent2),
        accent3: Color(accent3),
        neutral1: Color(neutral1),
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

/// Resolves once at startup; the wallpaper palette cannot change while the
/// app process is alive without a configuration change restarting it.
final systemPaletteProvider = FutureProvider<SystemPalette?>(
  (ref) => const SystemPaletteService().read(),
);
