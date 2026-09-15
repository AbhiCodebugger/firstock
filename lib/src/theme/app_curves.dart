import 'package:flutter/material.dart';

/// Motion curves used by the dashboard (price flash, button loader, shimmer).
abstract final class AppCurves {
  AppCurves._();

  /// Standard easing — price flash and most UI transitions.
  static const Curve standard = Curves.easeInOut;

  /// Decelerate — elements entering (button loader swap).
  static const Curve decelerate = Curves.decelerate;

  /// Linear — continuous loops (skeleton shimmer).
  static const Curve linear = Curves.linear;
}
