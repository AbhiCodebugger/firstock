import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/market/domain/entities/price_tick.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/live_prices_cubit.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/live_prices_state.dart';

import '../../../../support/fake_price_feed.dart';

void main() {
  late FakePriceFeed feed;
  late LivePricesCubit cubit;

  setUp(() {
    feed = FakePriceFeed();
    cubit = LivePricesCubit(feed: feed);
  });

  tearDown(() async {
    await cubit.close();
    await feed.dispose();
  });

  blocTest<LivePricesCubit, LivePricesState>(
    'coalesces ticks for one ticker',
    build: () => cubit,
    act: (c) async {
      await c.start(['AAA']);
      feed.emitTick(
        PriceTick(
          ticker: 'AAA',
          price: 10,
          timestamp: DateTime(2026, 1, 1),
        ),
      );
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<LivePricesState>().having(
        (s) => s.tickFor('AAA')?.price,
        'price',
        10,
      ),
    ],
  );

  test('killForDemo delegates to the feed', () async {
    await cubit.start(['AAA']);
    await cubit.killForDemo();
    expect(feed.killed, 1);
  });

  test('close stops the feed', () async {
    await cubit.start(['AAA']);
    await cubit.close();
    expect(feed.stopped, isTrue);
  });
}
