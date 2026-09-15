import '../entities/price_tick.dart';
import '../repositories/price_feed.dart';

class FetchQuoteSnapshot {
  const FetchQuoteSnapshot(this._feed);

  final PriceFeed _feed;

  Future<List<PriceTick>> call(List<String> tickers) {
    return _feed.snapshot(tickers);
  }
}
