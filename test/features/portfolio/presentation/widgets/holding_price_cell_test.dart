import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/rebuild/rebuild_counters.dart';
import 'package:mindorigin/src/features/market/domain/entities/price_tick.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/live_prices_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/widgets/holding_price_cell.dart';
import 'package:mindorigin/src/flavors.dart';

import '../../../../support/fake_price_feed.dart';

void main() {
  testWidgets('a tick on AAA does not rebuild BBB', (tester) async {
    FlavorConfig.load(Flavor.dev);
    RebuildCounters.reset();
    final feed = FakePriceFeed();
    final cubit = LivePricesCubit(feed: feed);
    addTearDown(() async {
      await cubit.close();
      await feed.dispose();
    });
    await cubit.start(['AAA', 'BBB']);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const Column(
            children: [
              HoldingPriceCell(ticker: 'AAA', fallbackPrice: 1),
              HoldingPriceCell(ticker: 'BBB', fallbackPrice: 2),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    final beforeB = RebuildCounters.counts['price_BBB'] ?? 0;

    feed.emitTick(
      PriceTick(ticker: 'AAA', price: 99, timestamp: DateTime(2026)),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(RebuildCounters.counts['price_AAA'], greaterThan(1));
    expect(RebuildCounters.counts['price_BBB'], beforeB);
  }, timeout: const Timeout(Duration(seconds: 15)));
}
