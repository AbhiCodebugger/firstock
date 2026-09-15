import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/connection/connection_status.dart';
import 'package:mindorigin/src/core/reconnect/backoff.dart';
import 'package:mindorigin/src/features/market/data/feeds/simulated_price_feed.dart';

void main() {
  test('snapshot returns seed prices after start', () async {
    final feed = SimulatedPriceFeed(
      backoff: const BackoffPolicy(
        initial: Duration(milliseconds: 1),
        max: Duration(milliseconds: 1),
        jitter: 0,
      ),
      simulateDisconnect: false,
      tickInterval: const Duration(days: 1),
      previousCloses: const {'AAA': 10},
    );
    addTearDown(feed.dispose);

    final statuses = <FeedConnectionStatus>[];
    feed.connection.listen(statuses.add);
    await feed.start(['AAA']);
    final snap = await feed.snapshot(['AAA']);

    expect(snap.single.ticker, 'AAA');
    expect(snap.single.price, 10);
    expect(statuses, contains(FeedConnectionStatus.live));
  });
}
