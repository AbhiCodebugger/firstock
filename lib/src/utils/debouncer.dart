import 'dart:async';

/// Runs [action] after [delay] of inactivity. Search uses this so typing
/// does not emit a [HoldingsUiCubit] query on every keystroke.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 200)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
