import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/core/rebuild/rebuild_counters.dart';
import 'package:mindorigin/src/features/market/domain/entities/price_tick.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/connection_cubit.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/live_prices_cubit.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_seed.dart';
import 'package:mindorigin/src/features/portfolio/domain/usecases/load_holdings.dart';
import 'package:mindorigin/src/features/portfolio/domain/usecases/update_target_alert.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/holdings_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/widgets/summary_cards.dart';
import 'package:mindorigin/src/flavors.dart';
import 'package:mindorigin/src/theme/color_schemes.dart';

import '../../../../support/fake_price_feed.dart';

void main() {
  testWidgets('a tape-only tick does not rebuild summary cards', (tester) async {
    FlavorConfig.load(Flavor.dev);
    RebuildCounters.reset();

    final feed = FakePriceFeed();
    final holdings = HoldingsCubit(
      loadHoldings: LoadHoldings(HoldingsRepositoryImpl()),
      updateTargetAlert: UpdateTargetAlert(HoldingsRepositoryImpl()),
    );
    await holdings.load();
    final prices = LivePricesCubit(feed: feed);
    await prices.start(HoldingsSeed.watchTickers);
    final connection = ConnectionCubit(feed: feed);

    addTearDown(() async {
      await prices.close();
      await connection.close();
      await holdings.close();
      await feed.dispose();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: stitchDarkScheme(),
              extensions: const [AppPalettes.dark],
            ),
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: holdings),
                BlocProvider.value(value: prices),
                BlocProvider.value(value: connection),
              ],
              child: const Scaffold(body: SummaryCards()),
            ),
          );
        },
      ),
    );
    await tester.pump();
    final before = RebuildCounters.counts['summary'] ?? 0;

    feed.emitTick(
      PriceTick(
        ticker: 'NIFTY 50',
        price: 25000,
        timestamp: DateTime(2026),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(RebuildCounters.counts['summary'], before);

    feed.emitTick(
      PriceTick(
        ticker: 'RELIANCE',
        price: 2800,
        previousClose: 2740.10,
        timestamp: DateTime(2026),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(RebuildCounters.counts['summary'], greaterThan(before));
  });
}
