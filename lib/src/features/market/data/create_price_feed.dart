import '../../../config/app_http_client.dart';
import '../../../config/env.dart';
import '../../../flavors.dart';
import '../domain/repositories/price_feed.dart';
import 'datasources/quote_remote_data_source.dart';
import 'feeds/finnhub_price_feed.dart';
import 'feeds/simulated_price_feed.dart';
import 'services/web_socket_service.dart';

PriceFeed createPriceFeed(
  FlavorConfig config, {
  required AppHttpClient httpClient,
  Map<String, double> simulatedPreviousCloses = const {},
}) {
  if (config.feedType == FeedType.finnhub) {
    late final FinnhubPriceFeed feed;
    final socket = WebSocketService(
      uri: _finnhubUri(config),
      backoff: config.backoff,
      onBeforeConnect: () => feed.onBeforeReconnect(),
    );
    feed = FinnhubPriceFeed(
      quotes: QuoteRemoteDataSource(httpClient),
      socket: socket,
    );
    return feed;
  }

  return SimulatedPriceFeed(
    backoff: config.backoff,
    simulateDisconnect: config.simulateDisconnect,
    previousCloses: simulatedPreviousCloses,
  );
}

Uri _finnhubUri(FlavorConfig config) {
  final token = Env.finnhubToken;
  final base = Uri.parse(config.wsUrl);
  if (token.isEmpty) {
    return base;
  }
  return base.replace(
    queryParameters: {...base.queryParameters, 'token': token},
  );
}

Map<String, double> previousClosesFromHoldings({
  required Map<String, double> holdingCloses,
  required Map<String, double> tapeCloses,
}) {
  return {...tapeCloses, ...holdingCloses};
}
