import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/connection_cubit.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/live_prices_cubit.dart';
import 'package:mindorigin/src/features/portfolio/data/chart_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_seed.dart';
import 'package:mindorigin/src/features/portfolio/domain/usecases/load_holdings.dart';
import 'package:mindorigin/src/features/portfolio/domain/usecases/update_target_alert.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/chart_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/holdings_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/holdings_ui_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/target_alert_edit_cubit.dart';
import 'package:mindorigin/src/features/portfolio/presentation/screens/dashboard_page.dart';
import 'package:mindorigin/src/shared/wrappers/skeleton_wrapper.dart';
import 'package:mindorigin/src/features/theme/domain/repositories/theme_repository.dart';
import 'package:mindorigin/src/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:mindorigin/src/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_price_feed.dart';

class _MemoryThemeRepository implements ThemeRepository {
  @override
  Future<String?> loadMode() async => 'dark';

  @override
  Future<void> saveMode(String mode) async {}
}

void main() {
  testWidgets('dashboard title renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    FlavorConfig.load(Flavor.dev);

    final feed = FakePriceFeed();
    final holdings = HoldingsCubit(
      loadHoldings: LoadHoldings(HoldingsRepositoryImpl()),
      updateTargetAlert: UpdateTargetAlert(HoldingsRepositoryImpl()),
    );
    await holdings.load();
    final ui = HoldingsUiCubit()..hydrate(holdings.state.holdings);
    final prices = LivePricesCubit(feed: feed);
    await prices.start(HoldingsSeed.watchTickers);
    final chart = ChartCubit(ChartRepositoryImpl(now: DateTime(2026, 9, 13)));
    await chart.load();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => ThemeCubit(_MemoryThemeRepository()),
                ),
                BlocProvider.value(value: holdings),
                BlocProvider.value(value: ui),
                BlocProvider.value(value: prices),
                BlocProvider(create: (_) => ConnectionCubit(feed: feed)),
                BlocProvider.value(value: chart),
                BlocProvider(create: (_) => TargetAlertEditCubit()),
              ],
              child: const MaterialApp(home: DashboardPage()),
            );
          },
        ),
      ),
    );
    addTearDown(() async {
      await prices.close();
      await holdings.close();
      await chart.close();
      await feed.dispose();
    });

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(
      tester.widget<SkeletonWrapper>(find.byType(SkeletonWrapper)).isLoading,
      isFalse,
    );
  });

  testWidgets('dashboard skeletons while holdings are unloaded', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    FlavorConfig.load(Flavor.dev);

    final feed = FakePriceFeed();
    final holdings = HoldingsCubit(
      loadHoldings: LoadHoldings(HoldingsRepositoryImpl()),
      updateTargetAlert: UpdateTargetAlert(HoldingsRepositoryImpl()),
    );
    final ui = HoldingsUiCubit();
    final prices = LivePricesCubit(feed: feed);
    await prices.start(HoldingsSeed.watchTickers);
    final chart = ChartCubit(ChartRepositoryImpl(now: DateTime(2026, 9, 13)));
    await chart.load();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => ThemeCubit(_MemoryThemeRepository()),
                ),
                BlocProvider.value(value: holdings),
                BlocProvider.value(value: ui),
                BlocProvider.value(value: prices),
                BlocProvider(create: (_) => ConnectionCubit(feed: feed)),
                BlocProvider.value(value: chart),
                BlocProvider(create: (_) => TargetAlertEditCubit()),
              ],
              child: const MaterialApp(home: DashboardPage()),
            );
          },
        ),
      ),
    );
    addTearDown(() async {
      await prices.close();
      await holdings.close();
      await chart.close();
      await feed.dispose();
    });

    await tester.pump();

    expect(
      tester.widget<SkeletonWrapper>(find.byType(SkeletonWrapper)).isLoading,
      isTrue,
    );
  });
}
