import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'offpath_colors.dart';

/// Builds OffPath's light and dark themes.
/// Material 3 components underneath, styled with iOS-like grouped surfaces.
abstract final class AppTheme {
  static ThemeData get light => _build(
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.purple1, // white text on it: 5.6:1
      onPrimary: Colors.white,
      secondary: AppPalette.purple2,
      onSecondary: Colors.white,
      error: AppPalette.pink1,
      onError: Colors.white,
      surface: AppPalette.lightCard, // cards
      onSurface: AppPalette.ink,
      onSurfaceVariant: AppPalette.lightTextSecondary, // secondary text
      surfaceContainerHighest: AppPalette.lightTrack, // tracks, chips
      outlineVariant: AppPalette.lightTrack,
    ),
    page: AppPalette.lightPage,
    extra: OffPathColors.light,
  );

  static ThemeData get dark => _build(
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.purple3, // black text on it: 6.8:1
      onPrimary: AppPalette.ink,
      secondary: AppPalette.purple2,
      onSecondary: AppPalette.ink,
      error: AppPalette.pink3,
      onError: AppPalette.ink,
      surface: AppPalette.darkCard,
      onSurface: Colors.white,
      onSurfaceVariant: AppPalette.darkTextSecondary,
      surfaceContainerHighest: AppPalette.darkTrack,
      outlineVariant: AppPalette.darkElevated,
    ),
    page: AppPalette.darkPage, // pure black, like HealthMate
    extra: OffPathColors.dark,
  );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color page,
    required OffPathColors extra,
  }) {
    final base = ThemeData(colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: page,
      textTheme: _textTheme(base.textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      extensions: [extra],
    );
  }

  /// Plus Jakarta Sans for headings, Inter for body text.
  /// Labels (buttons, chips, nav bar) keep Roboto, Android's system font.
  static TextTheme _textTheme(TextTheme t) {
    TextStyle? heading(TextStyle? s, FontWeight w) =>
        s?.copyWith(fontFamily: 'PlusJakartaSans', fontWeight: w);
    TextStyle? body(TextStyle? s) => s?.copyWith(fontFamily: 'Inter');

    return t.copyWith(
      displayLarge: heading(t.displayLarge, FontWeight.w800),
      displayMedium: heading(t.displayMedium, FontWeight.w800),
      displaySmall: heading(t.displaySmall, FontWeight.w700),
      headlineLarge: heading(t.headlineLarge, FontWeight.w700),
      headlineMedium: heading(t.headlineMedium, FontWeight.w700),
      headlineSmall: heading(t.headlineSmall, FontWeight.w700),
      titleLarge: heading(t.titleLarge, FontWeight.w700),
      titleMedium: heading(t.titleMedium, FontWeight.w600),
      titleSmall: heading(t.titleSmall, FontWeight.w600),
      bodyLarge: body(t.bodyLarge),
      bodyMedium: body(t.bodyMedium),
      bodySmall: body(t.bodySmall),
    );
  }
}