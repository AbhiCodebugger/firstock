import 'package:flutter/material.dart';

/// App-specific colors that aren't part of the standard [ColorScheme].
/// Access via `context.appColors`.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.yield,
    required this.onYield,
    required this.loss,
    required this.onLoss,
    this.successContainer,
    this.onSuccessContainer,
    this.warningContainer,
    this.onWarningContainer,
    this.infoContainer,
    this.onInfoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color yield;
  final Color onYield;
  final Color loss;
  final Color onLoss;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? infoContainer;
  final Color? onInfoContainer;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? yield,
    Color? onYield,
    Color? loss,
    Color? onLoss,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      yield: yield ?? this.yield,
      onYield: onYield ?? this.onYield,
      loss: loss ?? this.loss,
      onLoss: onLoss ?? this.onLoss,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      yield: Color.lerp(yield, other.yield, t)!,
      onYield: Color.lerp(onYield, other.onYield, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      onLoss: Color.lerp(onLoss, other.onLoss, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      ),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      ),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
}

abstract final class StitchColors {
  static const Color navy = Color(0xFF051424);
  static const Color yield = Color(0xFF4EDEA3);
  static const Color yieldContainer = Color(0xFF10B981);
  static const Color onYield = Color(0xFF003824);
  static const Color loss = Color(0xFFF43F5E);
  static const Color marketBlue = Color(0xFF7BD0FF);
  static const Color onSurface = Color(0xFFD4E4FA);
  static const Color onSurfaceVariant = Color(0xFFBBCABF);
  static const Color outline = Color(0xFF86948A);
  static const Color surfaceLowest = Color(0xFF010F1F);
  static const Color surfaceLow = Color(0xFF0D1C2D);
  static const Color surfaceContainer = Color(0xFF122131);
  static const Color surfaceHigh = Color(0xFF1C2B3C);
  static const Color surfaceHighest = Color(0xFF273647);
  static const Color lightCanvas = Color(0xFFF8FAFC);
  static const Color lightYield = Color(0xFF059669);
  static const Color lightLoss = Color(0xFFE11D48);
}

class AppPalettes {
  AppPalettes._();

  static const light = AppColorsExtension(
    success: StitchColors.lightYield,
    onSuccess: Colors.white,
    successContainer: Color(0xFFA7F3D0),
    onSuccessContainer: Color(0xFF064E3B),
    warning: Color(0xFFED6C02),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFCC80),
    onWarningContainer: Color(0xFFE65100),
    info: StitchColors.marketBlue,
    onInfo: Color(0xFF00354A),
    infoContainer: Color(0xFFC4E7FF),
    onInfoContainer: Color(0xFF003E55),
    yield: StitchColors.lightYield,
    onYield: Colors.white,
    loss: StitchColors.lightLoss,
    onLoss: Colors.white,
  );

  static const dark = AppColorsExtension(
    success: StitchColors.yield,
    onSuccess: StitchColors.onYield,
    successContainer: Color(0xFF064E3B),
    onSuccessContainer: StitchColors.yield,
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF5D4037),
    warningContainer: Color(0xFFE65100),
    onWarningContainer: Color(0xFFFFCC80),
    info: StitchColors.marketBlue,
    onInfo: Color(0xFF00354A),
    infoContainer: Color(0xFF003E55),
    onInfoContainer: Color(0xFFC4E7FF),
    yield: StitchColors.yield,
    onYield: StitchColors.onYield,
    loss: StitchColors.loss,
    onLoss: Colors.white,
  );
}

ColorScheme stitchDarkScheme() {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: StitchColors.yield,
    onPrimary: StitchColors.onYield,
    primaryContainer: StitchColors.yieldContainer,
    onPrimaryContainer: Color(0xFF00422B),
    secondary: Color(0xFFFFB2B7),
    onSecondary: Color(0xFF67001B),
    secondaryContainer: Color(0xFFB50036),
    onSecondaryContainer: Color(0xFFFFC2C4),
    tertiary: StitchColors.marketBlue,
    onTertiary: Color(0xFF00354A),
    tertiaryContainer: Color(0xFF19AEE8),
    onTertiaryContainer: Color(0xFF003E55),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: StitchColors.navy,
    onSurface: StitchColors.onSurface,
    onSurfaceVariant: StitchColors.onSurfaceVariant,
    outline: StitchColors.outline,
    outlineVariant: Color(0xFF3C4A42),
    surfaceContainerLowest: StitchColors.surfaceLowest,
    surfaceContainerLow: StitchColors.surfaceLow,
    surfaceContainer: StitchColors.surfaceContainer,
    surfaceContainerHigh: StitchColors.surfaceHigh,
    surfaceContainerHighest: StitchColors.surfaceHighest,
    inverseSurface: StitchColors.onSurface,
    onInverseSurface: Color(0xFF233143),
    inversePrimary: Color(0xFF006C49),
    surfaceTint: StitchColors.yield,
  );
}

ColorScheme stitchLightScheme() {
  return const ColorScheme(
    brightness: Brightness.light,
    primary: StitchColors.lightYield,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFA7F3D0),
    onPrimaryContainer: Color(0xFF064E3B),
    secondary: StitchColors.lightLoss,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFDAD6),
    onSecondaryContainer: Color(0xFF410002),
    tertiary: Color(0xFF0369A1),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFC4E7FF),
    onTertiaryContainer: Color(0xFF001E2C),
    error: StitchColors.lightLoss,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: StitchColors.lightCanvas,
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFCBD5E1),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Colors.white,
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFCBD5E1),
    inverseSurface: Color(0xFF1E293B),
    onInverseSurface: Color(0xFFF8FAFC),
    inversePrimary: StitchColors.yield,
    surfaceTint: StitchColors.lightYield,
  );
}
