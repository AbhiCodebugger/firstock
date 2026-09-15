import 'dart:async';

import 'package:mindorigin/src/core/connection/connection_status.dart';
import 'package:mindorigin/src/features/market/domain/entities/price_tick.dart';
import 'package:mindorigin/src/features/market/domain/repositories/price_feed.dart';

class FakePriceFeed implements PriceFeed {
  final _ticks = StreamController<PriceTick>.broadcast();
  final _connection = StreamController<FeedConnectionStatus>.broadcast();

  var started = false;
  var stopped = false;
  var killed = 0;
  List<String> tickers = const [];

  @override
  Stream<PriceTick> get ticks => _ticks.stream;

  @override
  Stream<FeedConnectionStatus> get connection => _connection.stream;

  @override
  Future<void> start(List<String> tickers) async {
    started = true;
    this.tickers = tickers;
    _connection.add(FeedConnectionStatus.live);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    _connection.add(FeedConnectionStatus.offline);
  }

  @override
  Future<List<PriceTick>> snapshot(List<String> tickers) async {
    return const [];
  }

  @override
  Future<void> killForDemo() async {
    killed += 1;
    _connection.add(FeedConnectionStatus.reconnecting);
  }

  void emitTick(PriceTick tick) => _ticks.add(tick);

  void emitConnection(FeedConnectionStatus status) => _connection.add(status);

  Future<void> dispose() async {
    await _ticks.close();
    await _connection.close();
  }
}
