import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_page_transitions.dart';
import 'app_spacing.dart';

/// Gaya teks khusus di luar slot TextTheme; di-`merge` ke gaya tema agar font tetap.
abstract final class AppTextStyles {
  static const lead = TextStyle(fontSize: 15.5, height: 1.55);
  static const greeting = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2);
  static const cardTitle =
      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3);
  static const price =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.3);
  static const priceUnit =
      TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.3);
  static const photoChip =
      TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.2);
  static const navLabel = TextStyle(fontSize: 11, height: 1.2);
  static const overline = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, height: 1.2);
  static const kategoriLabel = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.7, height: 1.2);
  static const detailTitle = TextStyle(
      fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.25);
  static const totalBig =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w800, height: 1.2);
  static const small = TextStyle(fontSize: 12, height: 1.3);
  static const pageTitle = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.2);
  static const statValue =
      TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.2);
  static const statLabel = TextStyle(fontSize: 11.5, height: 1.3);
  static const rowTitle =
      TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.3);
  static const bookingTitle =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.3);
  static const checklistTitle = TextStyle(
      fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2);
  static const checklistLabel =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3);
  static const profileName = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.2);
  static const groupLabel = TextStyle(
      fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, height: 1.2);
  static const menuLabel =
      TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3);
  static const notifTitle = TextStyle(fontSize: 14, height: 1.3);
  static const notifBody = TextStyle(fontSize: 13, height: 1.35);
  static const chatName =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.25);
  static const chatPreview = TextStyle(fontSize: 13, height: 1.35);
  static const bubble = TextStyle(fontSize: 15, height: 1.4);
  static const chatMeta = TextStyle(fontSize: 12, height: 1.2);
  static const dokumen = TextStyle(fontSize: 16, height: 1.6);
}

abstract final class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: AppPalette.lightBg,
        colors: AppColors.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppPalette.lightAccent,
          onPrimary: AppPalette.lightOnAccent,
          primaryContainer: AppPalette.lightAccentSoft,
          onPrimaryContainer: AppPalette.lightAccentText,
          secondary: AppPalette.darkAccent,
          onSecondary: AppPalette.darkOnAccent,
          secondaryContainer: AppPalette.lightAccentSoft,
          onSecondaryContainer: AppPalette.lightTextPrimary,
          error: AppPalette.lightError,
          onError: AppPalette.lightOnAccent,
          surface: AppPalette.lightSurface,
          onSurface: AppPalette.lightTextPrimary,
          onSurfaceVariant: AppPalette.lightTextSecondary,
          surfaceContainerHighest: AppPalette.lightSurfaceAlt,
          outline: AppPalette.lightBorder,
          outlineVariant: AppPalette.lightBorder,
        ),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppPalette.darkBg,
        colors: AppColors.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppPalette.darkAccent,
          onPrimary: AppPalette.darkOnAccent,
          primaryContainer: AppPalette.darkAccentSoft,
          onPrimaryContainer: AppPalette.darkAccentText,
          secondary: AppPalette.darkAccentText,
          onSecondary: AppPalette.darkOnAccent,
          secondaryContainer: AppPalette.darkAccentSoft,
          onSecondaryContainer: AppPalette.darkTextPrimary,
          error: AppPalette.darkError,
          onError: AppPalette.darkBg,
          surface: AppPalette.darkSurface,
          onSurface: AppPalette.darkTextPrimary,
          onSurfaceVariant: AppPalette.darkTextSecondary,
          surfaceContainerHighest: AppPalette.darkSurfaceAlt,
          outline: AppPalette.darkBorder,
          outlineVariant: AppPalette.darkBorder,
        ),
      );

  static TextTheme _textTheme(Color primary) {
    const base = TextTheme(
      headlineLarge: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.15),
      headlineMedium: TextStyle(
          fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.7, height: 1.2),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.45),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3),
    );
    return GoogleFonts.plusJakartaSansTextTheme(base)
        .apply(bodyColor: primary, displayColor: primary);
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required AppColors colors,
    required ColorScheme scheme,
  }) {
    final text = _textTheme(scheme.onSurface);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.inputAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: text,
      extensions: [colors],
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        errorMaxLines: 2,
        border: border(colors.border),
        enabledBorder: border(colors.border),
        disabledBorder: border(colors.border.withValues(alpha: 0.5)),
        focusedBorder: border(scheme.primary, 1.5),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.5),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accentText,
          textStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: AppPalette.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        showDragHandle: true,
        dragHandleColor: colors.border,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.checkbox))),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return null;
          if (states.contains(WidgetState.error)) {
            return BorderSide(color: scheme.error, width: 1.5);
          }
          return BorderSide(color: scheme.onSurfaceVariant, width: 1.5);
        }),
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? scheme.primary : null),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputAll),
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final p in TargetPlatform.values)
            p: const AppPageTransitionsBuilder(),
        },
      ),
    );
  }
}
