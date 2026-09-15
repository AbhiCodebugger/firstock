import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/reconnect/backoff.dart';
import 'package:mindorigin/src/features/market/data/datasources/quote_remote_data_source.dart';
import 'package:mindorigin/src/features/market/data/feeds/finnhub_price_feed.dart';
import 'package:mindorigin/src/features/market/data/services/web_socket_service.dart';

import '../../../support/fake_app_http_client.dart';

void main() {
  test('retries only denied NSE symbols with US fallbacks', () async {
    final http = FakeAppHttpClient({
      'RELIANCE.NS': const ScriptedQuote(status: 403),
      'INFY': const ScriptedQuote(status: 200, data: {'c': 11.0, 'pc': 10.9}),
      'AAPL': const ScriptedQuote(status: 200, data: {'c': 190.0, 'pc': 188.0}),
    });
    final feed = FinnhubPriceFeed(
      quotes: QuoteRemoteDataSource(http, token: 'test-token'),
      socket: WebSocketService(
        uri: Uri.parse('wss://example.test'),
        backoff: const BackoffPolicy(jitter: 0),
        socketFactory: (_) => throw UnsupportedError('socket unused'),
      ),
    );
    addTearDown(feed.dispose);

    final ticks = await feed.snapshot(['RELIANCE', 'INFY']);

    expect(ticks.map((tick) => tick.ticker).toSet(), {'RELIANCE', 'INFY'});
    expect(
      ticks.firstWhere((tick) => tick.ticker == 'RELIANCE').price,
      190,
    );
    expect(http.requestedSymbols, ['RELIANCE.NS', 'INFY', 'AAPL']);
  });
}
