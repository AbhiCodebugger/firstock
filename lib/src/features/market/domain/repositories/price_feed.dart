import '../../../../core/connection/connection_status.dart';
import '../entities/price_tick.dart';

/// Live prices contract. Transport types stay in `data/`.
abstract class PriceFeed {
  Stream<PriceTick> get ticks;
  Stream<FeedConnectionStatus> get connection;

  Future<void> start(List<String> tickers);
  Future<void> stop();
  Future<List<PriceTick>> snapshot(List<String> tickers);

  /// Dev demo hook — drops the socket so reconnect is visible.
  Future<void> killForDemo();
}
