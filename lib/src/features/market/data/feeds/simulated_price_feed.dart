import 'dart:async';
import 'dart:math';

import '../../../../core/connection/connection_status.dart';
import '../../../../core/reconnect/backoff.dart';
import '../../../../utils/logger.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/repositories/price_feed.dart';

class SimulatedPriceFeed implements PriceFeed {
  SimulatedPriceFeed({
    required this.backoff,
    this.simulateDisconnect = false,
    this.tickInterval = const Duration(milliseconds: 450),
    this.disconnectEvery = const Duration(seconds: 40),
    this.previousCloses = const {},
    Random? random,
  }) : _random = random ?? Random();

  final BackoffPolicy backoff;
  final bool simulateDisconnect;
  final Duration tickInterval;
  final Duration disconnectEvery;
  final Map<String, double> previousCloses;
  final Random _random;

  final _ticks = StreamController<PriceTick>.broadcast();
  final _connection = StreamController<FeedConnectionStatus>.broadcast();

  final Map<String, double> _prices = {};
  final Map<String, double> _previous = {};
  List<String> _tickers = const [];
  Timer? _tickTimer;
  Timer? _dropTimer;
  bool _stopped = true;
  int _attempt = 0;

  @override
  Stream<PriceTick> get ticks => _ticks.stream;

  @override
  Stream<FeedConnectionStatus> get connection => _connection.stream;

  @override
  Future<void> start(List<String> tickers) async {
    _stopped = false;
    _tickers = List<String>.from(tickers);
    _seedPrices();
    await _goLive(resetAttempt: true);
    if (simulateDisconnect) {
      _scheduleDrop();
    }
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    _tickTimer?.cancel();
    _dropTimer?.cancel();
    _emitConnection(FeedConnectionStatus.offline);
  }

  @override
  Future<List<PriceTick>> snapshot(List<String> tickers) async {
    if (_prices.isEmpty) {
      _tickers = List<String>.from(tickers);
      _seedPrices();
    }
    final now = DateTime.now();
    return [
      for (final ticker in tickers)
        if (_prices[ticker] != null)
          PriceTick(
            ticker: ticker,
            price: _prices[ticker]!,
            previousClose: _previous[ticker],
            timestamp: now,
          ),
    ];
  }

  @override
  Future<void> killForDemo() async {
    AppLogger.warning('Simulated feed killed');
    await _dropAndRestore();
  }

  Future<void> dispose() async {
    await stop();
    await _ticks.close();
    await _connection.close();
  }

  void _seedPrices() {
    previousCloses.forEach((ticker, close) {
      _previous[ticker] = close;
      _prices[ticker] = close;
    });
    for (final ticker in _tickers) {
      _previous.putIfAbsent(ticker, () => 100);
      _prices.putIfAbsent(ticker, () => 100);
    }
  }

  Future<void> _goLive({required bool resetAttempt}) async {
    if (_stopped) {
      return;
    }
    if (resetAttempt) {
      _attempt = 0;
    }
    final snap = await snapshot(_tickers);
    for (final tick in snap) {
      _ticks.add(tick);
    }
    _emitConnection(FeedConnectionStatus.live);
    _startTicking();
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(tickInterval, (_) => _emitRandomWalk());
  }

  void _emitRandomWalk() {
    if (_tickers.isEmpty || _stopped) {
      return;
    }
    final ticker = _tickers[_random.nextInt(_tickers.length)];
    final current = _prices[ticker] ?? 100;
    final delta = current * ((_random.nextDouble() - 0.48) * 0.006);
    final next = max(0.01, current + delta);
    _prices[ticker] = next;
    _ticks.add(
      PriceTick(
        ticker: ticker,
        price: next,
        previousClose: _previous[ticker],
        timestamp: DateTime.now(),
      ),
    );
  }

  void _scheduleDrop() {
    _dropTimer?.cancel();
    _dropTimer = Timer(disconnectEvery, () {
      if (!_stopped) {
        unawaited(_dropAndRestore());
      }
    });
  }

  Future<void> _dropAndRestore() async {
    _tickTimer?.cancel();
    _emitConnection(FeedConnectionStatus.reconnecting);
    final delay = backoff.delayForAttempt(_attempt, random: _random);
    _attempt += 1;
    AppLogger.info('Simulated reconnect in ${delay.inMilliseconds}ms');
    await Future<void>.delayed(delay);
    if (_stopped) {
      return;
    }
    await _goLive(resetAttempt: true);
    if (simulateDisconnect) {
      _scheduleDrop();
    }
  }

  void _emitConnection(FeedConnectionStatus status) {
    if (!_connection.isClosed) {
      _connection.add(status);
    }
  }
}
