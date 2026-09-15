import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/connection_status.dart';
import '../../../../core/money/inr_format.dart';
import '../../../../core/rebuild/rebuild_counters.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../flavors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../market/presentation/cubit/connection_cubit.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';
import '../../../market/presentation/cubit/live_prices_state.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/portfolio_math.dart';
import '../cubit/holdings_cubit.dart';
import 'summary_metric_card.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final holdings = context.select(
      (HoldingsCubit cubit) => cubit.state.holdings,
    );

    final summary = context.select(
      (LivePricesCubit cubit) => _summaryFor(holdings, cubit.state),
    );
    final status = context.select(
      (ConnectionCubit cubit) => cubit.state.status,
    );
    if (FlavorConfig.isLoaded && FlavorConfig.current.showRebuildCounters) {
      RebuildCounters.increment('summary');
    }
    final plColor = summary.unrealizedPl >= 0
        ? context.appColors.yield
        : context.appColors.loss;
    final todayColor = summary.todayChange >= 0
        ? context.appColors.yield
        : context.appColors.loss;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.itemGap,
        mainAxisSpacing: AppSpacing.itemGap,
        childAspectRatio: 2,
        children: [
          SummaryMetricCard(
            label: 'dashboard.total_invested'.tr(),
            value: formatInr(summary.invested, decimals: 0),
            subtitle: 'dashboard.across_equities'.tr(
              namedArgs: {'count': '${summary.holdingCount}'},
            ),
          ),
          SummaryMetricCard(
            label: 'dashboard.current_value'.tr(),
            value: formatInr(summary.currentValue, decimals: 0),
            subtitle: 'dashboard.inr_portfolio'.tr(),
            trailing: status == FeedConnectionStatus.live
                ? Text(
                    ConnectionLabels.live,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.appColors.yield,
                    ),
                  )
                : null,
          ),
          SummaryMetricCard(
            label: 'dashboard.profit_loss'.tr(),
            value: formatInr(summary.unrealizedPl, decimals: 0, signed: true),
            subtitle:
                '${formatPercent(summary.plPercent * 100)} (${'dashboard.all_time'.tr()})',
            valueColor: plColor,
          ),
          SummaryMetricCard(
            label: 'dashboard.todays_change'.tr(),
            value: formatInr(summary.todayChange, decimals: 0, signed: true),
            subtitle:
                '${formatPercent(summary.todayChangePercent * 100)} ${'dashboard.today'.tr()}',
            valueColor: todayColor,
          ),
        ],
      ),
    );
  }
}

PortfolioSummary _summaryFor(List<Holding> holdings, LivePricesState prices) {
  return summarizePortfolio(holdings, {
    for (final holding in holdings)
      if (prices.tickFor(holding.ticker) case final tick?)
        holding.ticker: tick.price,
  });
}
