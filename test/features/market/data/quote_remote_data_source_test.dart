import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/market/data/datasources/quote_remote_data_source.dart';
import 'package:mindorigin/src/utils/failure.dart';

import '../../../support/fake_app_http_client.dart';

void main() {
  test('omits a 403 symbol instead of throwing', () async {
    final http = FakeAppHttpClient({
      'RELIANCE.NS': const ScriptedQuote(
        status: 403,
        data: {'error': "You don't have access to this resource."},
      ),
      'INFY': const ScriptedQuote(
        status: 200,
        data: {'c': 11.0, 'pc': 10.9},
      ),
    });
    final quotes = QuoteRemoteDataSource(http, token: 'test-token');

    final ticks = await quotes.fetchQuotes(
      ['RELIANCE', 'INFY'],
      symbolByTicker: const {'RELIANCE': 'RELIANCE.NS', 'INFY': 'INFY'},
    );

    expect(ticks.map((tick) => tick.ticker), ['INFY']);
    expect(ticks.single.price, 11);
    expect(http.requestedSymbols, ['RELIANCE.NS', 'INFY']);
  });

  test('fails fast when the Finnhub token is empty', () async {
    final http = FakeAppHttpClient({});
    final quotes = QuoteRemoteDataSource(http, token: '');

    expect(
      () => quotes.fetchQuotes(
        ['INFY'],
        symbolByTicker: const {'INFY': 'INFY'},
      ),
      throwsA(isA<ServerFailure>()),
    );
    expect(http.requestedSymbols, isEmpty);
  });
}
