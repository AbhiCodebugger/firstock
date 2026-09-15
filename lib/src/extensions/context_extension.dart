import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get typography => theme.textTheme;
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Semantic colors (yield / loss / success).
  AppColorsExtension get appColors =>
      theme.extension<AppColorsExtension>() ??
      (isDarkMode ? AppPalettes.dark : AppPalettes.light);

  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  Size get screenSize => mediaQuerySize;
  double get width => mediaQuerySize.width;
  double get height => mediaQuerySize.height;

  EdgeInsets get safeArea => MediaQuery.paddingOf(this);

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);

  Future<T?> push<T extends Object?>(Route<T> route) {
    return Navigator.of(this).push<T>(route);
  }

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }
}
