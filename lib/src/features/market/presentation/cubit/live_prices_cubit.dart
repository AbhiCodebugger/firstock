import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/price_tick.dart';
import '../../domain/repositories/price_feed.dart';
import '../../domain/usecases/watch_prices.dart';
import 'live_prices_state.dart';

class LivePricesCubit extends Cubit<LivePricesState> {
  LivePricesCubit({
    required PriceFeed feed,
    WatchPrices? watchPrices,
  })  : _feed = feed,
        _watchPrices = watchPrices ?? WatchPrices(feed),
        super(const LivePricesState());

  final PriceFeed _feed;
  final WatchPrices _watchPrices;
  StreamSubscription<PriceTick>? _sub;
  final Map<String, PriceTick> _pending = {};
  bool _scheduled = false;
  List<String> _tickers = const [];

  Future<void> start(List<String> tickers) async {
    _tickers = List<String>.from(tickers);
    await _sub?.cancel();
    _sub = _watchPrices().listen(_onTick);
    await _feed.start(_tickers);
  }

  Future<void> retry() => start(_tickers);

  Future<void> killForDemo() => _feed.killForDemo();

  void _onTick(PriceTick tick) {
    final existing = state.ticks[tick.ticker];
    if (existing != null &&
        existing.price == tick.price &&
        existing.previousClose == tick.previousClose) {
      return;
    }
    _pending[tick.ticker] = tick;
    if (_scheduled) {
      return;
    }
    _scheduled = true;
    scheduleMicrotask(_flush);
  }

  void _flush() {
    _scheduled = false;
    if (_pending.isEmpty || isClosed) {
      return;
    }
    final next = Map<String, PriceTick>.from(state.ticks)..addAll(_pending);
    _pending.clear();
    emit(LivePricesState(ticks: next));
  }

  @override
  Future<void> close() async {
    if (isClosed) {
      return;
    }
    await _sub?.cancel();
    await _feed.stop();
    return super.close();
  }
}
