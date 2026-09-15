import 'dart:math' as math;

/// Exponential backoff with jitter. Owned by the feed / socket layer.
class BackoffPolicy {
  const BackoffPolicy({
    this.initial = const Duration(seconds: 1),
    this.max = const Duration(seconds: 30),
    this.jitter = 0.2,
  });

  final Duration initial;
  final Duration max;
  final double jitter;

  Duration delayForAttempt(int attempt, {math.Random? random}) {
    final exp = initial.inMilliseconds * math.pow(2, math.max(0, attempt)).toInt();
    final capped = math.min(exp, max.inMilliseconds);
    final rng = random ?? math.Random();
    final factor = 1 + ((rng.nextDouble() * 2 - 1) * jitter);
    final millis = math.max(initial.inMilliseconds, (capped * factor).round());
    return Duration(milliseconds: millis);
  }
}
