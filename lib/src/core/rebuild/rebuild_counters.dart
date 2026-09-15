/// Dev-only rebuild counts used with Track Widget Rebuilds.
class RebuildCounters {
  RebuildCounters._();

  static final Map<String, int> counts = <String, int>{};

  static int increment(String key) {
    final next = (counts[key] ?? 0) + 1;
    counts[key] = next;
    return next;
  }

  static void reset() => counts.clear();
}
