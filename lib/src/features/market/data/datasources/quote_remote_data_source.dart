import '../../../../config/app_http_client.dart';
import '../../../../config/env.dart';
import '../../../../utils/logger.dart';
import '../../domain/entities/price_tick.dart';
import '../error_mapper.dart';
import '../finnhub_symbol_map.dart';

class QuoteRemoteDataSource {
  QuoteRemoteDataSource(this._client, {String? token}) : _token = token;

  final AppHttpClient _client;
  final String? _token;

  String get _finnhubToken => _token ?? Env.finnhubToken;

  /// Fetches quotes for [tickers]. Missing or denied symbols are omitted so
  /// the feed can retry US fallbacks per ticker. Empty token fails fast.
  Future<List<PriceTick>> fetchQuotes(
    List<String> tickers, {
    required Map<String, String> symbolByTicker,
  }) async {
    final token = _finnhubToken;
    if (token.isEmpty) {
      throw mapFeedFailure(
        StateError(
          'FINNHUB_TOKEN is missing. Run prod with --dart-define=FINNHUB_TOKEN=...',
        ),
      );
    }
    final now = DateTime.now();
    final ticks = <PriceTick>[];
    for (final ticker in tickers) {
      final symbol = symbolByTicker[ticker] ??
          finnhubSymbolFor(ticker, useFallback: false);
      final result = await _client.get(
        '/quote',
        queryParameters: {'symbol': symbol, 'token': token},
        allowClientError: true,
      );
      await result.fold(
        (failure) async {
          AppLogger.warning(
              'Quote failed for $ticker ($symbol): ${failure.message}');
        },
        (response) async {
          if (response.statusCode != 200) {
            AppLogger.warning(
              'Quote ${response.statusCode} for $ticker ($symbol)',
            );
            return;
          }
          final data = response.data;
          if (data is! Map) {
            return;
          }
          final current = _asDouble(data['c']);
          final previous = _asDouble(data['pc']);
          if (current == null || current == 0) {
            return;
          }
          ticks.add(
            PriceTick(
              ticker: ticker,
              price: current,
              previousClose: previous,
              timestamp: now,
            ),
          );
        },
      );
    }
    return ticks;
  }

  double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value');
  }
}
