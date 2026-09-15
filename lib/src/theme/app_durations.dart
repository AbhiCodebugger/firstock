/// Motion durations used by the dashboard.
abstract final class AppDurations {
  AppDurations._();

  /// 150 ms — button loader / opacity.
  static const Duration fast = Duration(milliseconds: 150);

  /// 200 ms — holdings search debounce.
  static const Duration quick = Duration(milliseconds: 200);

  /// 320 ms — live price flash (assignment window 260–400ms).
  static const Duration priceFlash = Duration(milliseconds: 320);

  /// 1000 ms — skeleton shimmer cycle.
  static const Duration shimmer = Duration(milliseconds: 1000);
}
