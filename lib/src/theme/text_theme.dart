import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle tabularFigures(TextStyle style) {
  return style.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Paints a [TextTheme] with [onSurface] so Google Fonts light-theme ink
/// does not leak into dark mode.
TextTheme withOnSurfaceInk(TextTheme theme, Color onSurface) {
  return theme.apply(
    bodyColor: onSurface,
    displayColor: onSurface,
  );
}

/// Builds Plus Jakarta / Inter styles, then paints them with [onSurface].
///
/// [GoogleFonts] text themes default to light-theme ink. Without [onSurface]
/// those colors stay nearly black in dark mode.
TextTheme buildTextTheme({required Color onSurface}) {
  final headlines = GoogleFonts.plusJakartaSansTextTheme();
  final body = GoogleFonts.interTextTheme();

  final theme = body.copyWith(
    displayLarge: headlines.displayLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 48 / 40,
    ),
    displayMedium: headlines.displayMedium?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.45,
      height: 38 / 30,
    ),
    headlineLarge: headlines.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.28,
      height: 36 / 28,
    ),
    headlineMedium: headlines.headlineMedium?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.22,
      height: 30 / 22,
    ),
    headlineSmall: headlines.headlineSmall?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 26 / 18,
    ),
    titleLarge: headlines.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: headlines.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: headlines.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: body.bodyLarge?.copyWith(fontSize: 16, height: 24 / 16),
    bodyMedium: body.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14),
    bodySmall: body.bodySmall?.copyWith(fontSize: 12, height: 16 / 12),
    labelLarge: body.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: body.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.24,
    ),
    labelSmall: body.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.44,
    ),
  );
  return withOnSurfaceInk(theme, onSurface);
}
