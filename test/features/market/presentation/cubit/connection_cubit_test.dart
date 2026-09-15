import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/connection/connection_status.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/connection_cubit.dart';

import '../../../../support/fake_price_feed.dart';

void main() {
  test('exposes exact Live / Reconnecting… / Offline labels', () async {
    final feed = FakePriceFeed();
    final cubit = ConnectionCubit(feed: feed);
    feed.emitConnection(FeedConnectionStatus.live);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.label, ConnectionLabels.live);

    feed.emitConnection(FeedConnectionStatus.reconnecting);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.label, ConnectionLabels.reconnecting);

    feed.emitConnection(FeedConnectionStatus.offline);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.label, ConnectionLabels.offline);

    await cubit.close();
    await feed.dispose();
  });
}
