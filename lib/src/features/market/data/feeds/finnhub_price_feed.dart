import 'dart:async';
import 'dart:convert';

import '../../../../core/connection/connection_status.dart';
import '../../../../utils/logger.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/repositories/price_feed.dart';
import '../datasources/quote_remote_data_source.dart';
import '../error_mapper.dart';
import '../finnhub_symbol_map.dart';
import '../services/web_socket_service.dart';

class FinnhubPriceFeed implements PriceFeed {
  FinnhubPriceFeed({
    required this.quotes,
    required this.socket,
  });

  final QuoteRemoteDataSource quotes;
  final WebSocketService socket;

  final _ticks = StreamController<PriceTick>.broadcast();
  final Map<String, String> _symbolByTicker = {};
  final Map<String, double> _previous = {};
  List<String> _tickers = const [];
  StreamSubscription<dynamic>? _messages;
  StreamSubscription<FeedConnectionStatus>? _connection;

  @override
  Stream<PriceTick> get ticks => _ticks.stream;

  @override
  Stream<FeedConnectionStatus> get connection => socket.connection;

  @override
  Future<void> start(List<String> tickers) async {
    _tickers = List<String>.from(tickers);
    _resolveSymbols();
    _messages ??= socket.messages.listen(_onMessage);
    await socket.connect();
    _subscribe();
  }

  @override
  Future<void> stop() async {
    await socket.disconnect();
  }

  @override
  Future<List<PriceTick>> snapshot(List<String> tickers) async {
    _tickers = List<String>.from(tickers);
    _resolveSymbols();
    final result = await _quotesWithFallback(tickers);
    for (final tick in result) {
      if (tick.previousClose != null) {
        _previous[tick.ticker] = tick.previousClose!;
      }
      _ticks.add(tick);
    }
    return result;
  }

  @override
  Future<void> killForDemo() => socket.kill();

  Future<void> onBeforeReconnect() async {
    await snapshot(_tickers);
    _subscribe();
  }

  Future<void> dispose() async {
    await _messages?.cancel();
    await _connection?.cancel();
    await socket.dispose();
    await _ticks.close();
  }

  /// Free Finnhub plans 403 NSE symbols. Retry only the missing tickers
  /// with US fallbacks and subscribe to whichever symbol actually worked.
  Future<List<PriceTick>> _quotesWithFallback(List<String> tickers) async {
    final primary = await quotes.fetchQuotes(
      tickers,
      symbolByTicker: _symbolByTicker,
    );
    final missing = [
      for (final ticker in tickers)
        if (primary.every((tick) => tick.ticker != ticker)) ticker,
    ];
    if (missing.isEmpty) {
      return primary;
    }

    final fallbackMap = <String, String>{};
    for (final ticker in missing) {
      final fallback = finnhubSymbolFor(ticker, useFallback: true);
      if (fallback != _symbolByTicker[ticker]) {
        fallbackMap[ticker] = fallback;
      }
    }
    if (fallbackMap.isEmpty) {
      return _requireQuotes(primary, tickers);
    }

    AppLogger.warning(
      'Finnhub denied ${fallbackMap.length} symbol(s); retrying US fallbacks',
    );
    final extra = await quotes.fetchQuotes(
      fallbackMap.keys.toList(growable: false),
      symbolByTicker: fallbackMap,
    );
    for (final tick in extra) {
      final symbol = fallbackMap[tick.ticker];
      if (symbol != null) {
        _symbolByTicker[tick.ticker] = symbol;
      }
    }
    return _requireQuotes([...primary, ...extra], tickers);
  }

  List<PriceTick> _requireQuotes(List<PriceTick> ticks, List<String> tickers) {
    if (ticks.isEmpty && tickers.isNotEmpty) {
      throw mapFeedFailure(
        StateError('No quotes returned for ${tickers.join(', ')}'),
      );
    }
    return ticks;
  }

  void _resolveSymbols() {
    for (final ticker in _tickers) {
      _symbolByTicker[ticker] = finnhubSymbolFor(
        ticker,
        useFallback: false,
      );
    }
  }

  void _subscribe() {
    for (final symbol in _symbolByTicker.values.toSet()) {
      socket.send(jsonEncode({'type': 'subscribe', 'symbol': symbol}));
    }
  }

  void _onMessage(dynamic raw) {
    Map<String, dynamic>? payload;
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    } else if (raw is Map<String, dynamic>) {
      payload = raw;
    }
    if (payload == null || payload['type'] != 'trade') {
      return;
    }
    final data = payload['data'];
    if (data is! List) {
      return;
    }
    for (final item in data) {
      if (item is! Map) {
        continue;
      }
      final symbol = item['s'] as String?;
      final price = (item['p'] as num?)?.toDouble();
      if (symbol == null || price == null) {
        continue;
      }
      final ticker = uiTickerForFinnhub(symbol, _symbolByTicker);
      if (ticker == null) {
        continue;
      }
      _ticks.add(
        PriceTick(
          ticker: ticker,
          price: price,
          previousClose: _previous[ticker],
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}
