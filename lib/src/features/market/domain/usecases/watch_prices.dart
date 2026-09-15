import '../entities/price_tick.dart';
import '../repositories/price_feed.dart';

class WatchPrices {
  const WatchPrices(this._feed);

  final PriceFeed _feed;

  Stream<PriceTick> call() => _feed.ticks;
}
