import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/portfolio/data/chart_repository_impl.dart';
import '../features/portfolio/data/holdings_repository_impl.dart';
import '../features/portfolio/domain/usecases/load_holdings.dart';
import '../features/portfolio/domain/usecases/update_target_alert.dart';
import '../features/portfolio/presentation/cubit/chart_cubit.dart';
import '../features/portfolio/presentation/cubit/holdings_cubit.dart';
import '../features/portfolio/presentation/cubit/holdings_ui_cubit.dart';
import '../features/portfolio/presentation/cubit/target_alert_edit_cubit.dart';

/// Book, chart, and holdings UI cubits. [HoldingsUiCubit] is created first so
/// [HoldingsCubit.load] can hydrate pinned sort without touching [DashboardPage].
class PortfolioBindings {
  PortfolioBindings._({required this.providers});

  final List<BlocProvider> providers;

  factory PortfolioBindings.create() {
    final holdingsRepository = HoldingsRepositoryImpl();
    late final HoldingsUiCubit ui;
    return PortfolioBindings._(
      providers: [
        BlocProvider<HoldingsUiCubit>(
          create: (_) {
            ui = HoldingsUiCubit();
            return ui;
          },
          lazy: false,
        ),
        BlocProvider<HoldingsCubit>(
          create: (_) {
            final cubit = HoldingsCubit(
              loadHoldings: LoadHoldings(holdingsRepository),
              updateTargetAlert: UpdateTargetAlert(holdingsRepository),
            );
            unawaited(
              cubit.load().then((_) {
                if (!ui.isClosed) {
                  ui.hydrate(cubit.state.holdings);
                }
              }),
            );
            return cubit;
          },
          lazy: false,
        ),
        BlocProvider<ChartCubit>(
          create: (_) => ChartCubit(ChartRepositoryImpl())..load(),
          lazy: false,
        ),
        BlocProvider<TargetAlertEditCubit>(
          create: (_) => TargetAlertEditCubit(),
        ),
      ],
    );
  }
}
