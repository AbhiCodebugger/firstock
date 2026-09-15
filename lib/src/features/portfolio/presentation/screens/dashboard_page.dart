import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindorigin/src/core/connection/connection_status.dart';
import 'package:mindorigin/src/features/market/presentation/cubit/connection_cubit.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../shared/wrappers/skeleton_wrapper.dart';
import '../../../../theme/app_spacing.dart';
import '../../../market/presentation/widgets/connection_banner.dart';
import '../../../market/presentation/widgets/ticker_strip.dart';
import '../../data/holdings_seed.dart';
import '../cubit/holdings_cubit.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/holdings_filter_chips.dart';
import '../widgets/holdings_section.dart';
import '../widgets/portfolio_chart.dart';
import '../widgets/summary_cards.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (HoldingsCubit cubit) => !cubit.state.loaded,
    );
    final status = context.select(
      (ConnectionCubit cubit) => cubit.state.status,
    );

    return SkeletonWrapper(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: const DashboardHeader(),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const ConnectionBanner(),
              if (status == FeedConnectionStatus.live)
                SizedBox(height: AppSpacing.itemGap)
              else
                const SizedBox.shrink(),
              TickerStrip(tickers: HoldingsSeed.watchTickers),
              SizedBox(height: AppSpacing.itemGap),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tablet = constraints.maxWidth >= kTabletBreakpoint;
                    if (tablet) {
                      return const _TabletBody();
                    }
                    return const _PhoneBody();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneBody extends StatelessWidget {
  const _PhoneBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: ListView(
            children: [
              SizedBox(height: AppSpacing.pagePadding),
              const SummaryCards(),
              SizedBox(height: AppSpacing.pagePadding),
              const PortfolioChart(),
              SizedBox(height: AppSpacing.pagePadding),
              const HoldingsFilterChips(),
            ],
          ),
        ),
        const Expanded(flex: 5, child: HoldingsSection(asTable: false)),
      ],
    );
  }
}

class _TabletBody extends StatelessWidget {
  const _TabletBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(top: AppSpacing.pagePadding),
            children: [
              const SummaryCards(),
              SizedBox(height: AppSpacing.pagePadding),
              const HoldingsFilterChips(),
              SizedBox(height: AppSpacing.pagePadding),
              const PortfolioChart(),
            ],
          ),
        ),
        const Expanded(child: HoldingsSection(asTable: true)),
      ],
    );
  }
}
