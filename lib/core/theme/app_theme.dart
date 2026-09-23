import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The Rigel visual system: deep-space dark mode and a crisp blue-white light
/// mode share the same neon accents, geometry, and interaction states.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static Color headerColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.spaceElevated
        : AppColors.navy;
  }

  static LinearGradient brandGradient(BuildContext context) =>
      const LinearGradient(
        colors: [AppColors.navy, AppColors.logoBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Color glowColor(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = dark
        ? const ColorScheme.dark(
            primary: AppColors.navy,
            onPrimary: Colors.white,
            primaryContainer: AppColors.spacePanel,
            onPrimaryContainer: Color(0xFFDDF8FF),
            secondary: AppColors.gold,
            onSecondary: AppColors.space,
            secondaryContainer: Color(0xFF4A3917),
            onSecondaryContainer: Color(0xFFFFE8A8),
            surface: AppColors.space,
            onSurface: Color(0xFFEAF5FF),
            surfaceContainerLowest: Color(0xFF040B13),
            surfaceContainerLow: AppColors.spaceElevated,
            surfaceContainer: AppColors.spaceElevated,
            surfaceContainerHigh: AppColors.spacePanel,
            surfaceContainerHighest: Color(0xFF1A3C5E),
            onSurfaceVariant: Color(0xFFA9C0D8),
            outline: Color(0xFF6F8BA6),
            outlineVariant: Color(0xFF294966),
            error: AppColors.danger,
            onError: AppColors.space,
          )
        : const ColorScheme.light(
            primary: AppColors.navy,
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFDDF4FF),
            onPrimaryContainer: Color(0xFF082743),
            secondary: AppColors.gold,
            onSecondary: AppColors.space,
            secondaryContainer: Color(0xFFFFF2CD),
            onSecondaryContainer: Color(0xFF4B3500),
            surface: AppColors.lightSurface,
            onSurface: AppColors.lightText,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: AppColors.lightSurface,
            surfaceContainer: AppColors.lightPanel,
            surfaceContainerHigh: Color(0xFFE0EBF5),
            surfaceContainerHighest: Color(0xFFD6E3F0),
            onSurfaceVariant: AppColors.lightMuted,
            outline: Color(0xFF7890A8),
            outlineVariant: Color(0xFFB5C7D8),
            error: Color(0xFFB3261E),
            onError: Colors.white,
          );

    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      scaffoldBackgroundColor: dark
          ? AppColors.space
          : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.spaceElevated : AppColors.navy,
        foregroundColor: dark ? scheme.onSurface : scheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -.25,
          color: dark ? scheme.onSurface : scheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? AppColors.spaceElevated : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: .1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? AppColors.gold : AppColors.navy,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: dark ? AppColors.gold : AppColors.navy),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? AppColors.gold : AppColors.navy,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: dark
            ? AppColors.gold.withValues(alpha: .22)
            : AppColors.electricBlue.withValues(alpha: .16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: dark ? .35 : .1),
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.gold
                : Colors.white.withValues(alpha: .72),
          );
        }),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: dark ? AppColors.gold : AppColors.navy,
        checkmarkColor: dark ? AppColors.space : Colors.white,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.surfaceContainerHighest;
          }
          if (states.contains(WidgetState.selected)) {
            return dark ? scheme.secondary : scheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return scheme.outline;
          return dark ? scheme.secondary : scheme.primary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return dark ? scheme.secondary : scheme.primary;
          }
          return scheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStatePropertyAll(scheme.outline),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: dark ? scheme.secondary : scheme.primary,
        thumbColor: dark ? scheme.secondary : scheme.primary,
        overlayColor: (dark ? scheme.secondary : scheme.primary).withValues(
          alpha: .12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.spaceElevated : AppColors.lightPanel,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: dark ? AppColors.gold : scheme.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: dark ? AppColors.gold : scheme.primary,
            width: 1.2,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.spacePanel : AppColors.navy,
        contentTextStyle: TextStyle(
          color: dark ? AppColors.space : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? AppColors.gold : scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      extensions: <ThemeExtension<dynamic>>[
        SweeperColors(
          savings: AppColors.savings,
          warning: AppColors.warning,
          danger: AppColors.danger,
          photos: AppColors.photos,
          videos: AppColors.videos,
          audio: AppColors.audio,
          documents: AppColors.documents,
        ),
      ],
    );
  }
}

@immutable
class SweeperColors extends ThemeExtension<SweeperColors> {
  const SweeperColors({
    required this.savings,
    required this.warning,
    required this.danger,
    required this.photos,
    required this.videos,
    required this.audio,
    required this.documents,
  });

  final Color savings;
  final Color warning;
  final Color danger;
  final Color photos;
  final Color videos;
  final Color audio;
  final Color documents;

  static SweeperColors of(BuildContext context) =>
      Theme.of(context).extension<SweeperColors>()!;

  @override
  SweeperColors copyWith({
    Color? savings,
    Color? warning,
    Color? danger,
    Color? photos,
    Color? videos,
    Color? audio,
    Color? documents,
  }) => SweeperColors(
    savings: savings ?? this.savings,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    photos: photos ?? this.photos,
    videos: videos ?? this.videos,
    audio: audio ?? this.audio,
    documents: documents ?? this.documents,
  );

  @override
  SweeperColors lerp(ThemeExtension<SweeperColors>? other, double t) {
    if (other is! SweeperColors) return this;
    return SweeperColors(
      savings: Color.lerp(savings, other.savings, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      photos: Color.lerp(photos, other.photos, t)!,
      videos: Color.lerp(videos, other.videos, t)!,
      audio: Color.lerp(audio, other.audio, t)!,
      documents: Color.lerp(documents, other.documents, t)!,
    );
  }
}
