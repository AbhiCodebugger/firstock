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
import 'package:mindorigin/src/features/portfolio/presentation/widgets/holdings_section.dart';
import 'package:mindorigin/src/shared/widgets/app_empty_state.dart';
import 'package:mindorigin/src/theme/app_durations.dart';
import 'package:mindorigin/src/features/theme/domain/repositories/theme_repository.dart';
import 'package:mindorigin/src/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:mindorigin/src/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/fake_price_feed.dart';

class _MemoryThemeRepository implements ThemeRepository {
  @override
  Future<String?> loadMode() async => 'dark';

  @override
  Future<void> saveMode(String mode) async {}
}

void main() {
  testWidgets('holdings sit above the system nav bar', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    tester.view.padding = const FakeViewPadding(bottom: 48, top: 24);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48, top: 24);
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);
    await tester.pump();

    final section = tester.getRect(find.byType(HoldingsSection));
    expect(section.bottom, lessThanOrEqualTo(600 - 48 + 0.5));
  });

  testWidgets('holdings sit above the keyboard', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    tester.view.padding = FakeViewPadding.zero;
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);
    await tester.pump();

    final section = tester.getRect(find.byType(HoldingsSection));
    expect(section.bottom, lessThanOrEqualTo(900 - 280 + 0.5));
  });

  testWidgets('search field keeps focus after the keyboard inset appears', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);
    await tester.pump();

    final search = find.byType(TextFormField).first;
    await tester.tap(search);
    await tester.pump();

    final focused = tester.state<EditableTextState>(
      find.byType(EditableText).first,
    );
    expect(focused.widget.focusNode.hasFocus, isTrue);

    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();

    expect(
      tester
          .state<EditableTextState>(find.byType(EditableText).first)
          .widget
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('unknown search shows AppEmptyState and Show all restores rows', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 900);
    addTearDown(tester.view.reset);

    await _pumpDashboard(tester);
    await tester.pump();

    await tester.enterText(find.byKey(const ValueKey('holdings_search')), 'zzzz');
    await tester.pump(AppDurations.quick);

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('dashboard.empty_holdings'), findsOneWidget);
  });
}

Future<void> _pumpDashboard(WidgetTester tester) async {
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
              BlocProvider(create: (_) => ThemeCubit(_MemoryThemeRepository())),
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
}
