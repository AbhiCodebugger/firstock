import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../theme/app_borders.dart';
import '../../../../theme/app_spacing.dart';
import '../../domain/entities/holding.dart';
import '../cubit/holdings_ui_cubit.dart';
import 'holding_pl_cell.dart';
import 'holding_price_cell.dart';
import 'target_alert_field.dart';

class HoldingsCard extends StatelessWidget {
  const HoldingsCard({
    super.key,
    required this.holding,
    required this.expanded,
  });

  final Holding holding;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final plColor = context.appColors.yield;

    return ClipRRect(
      borderRadius: AppBorders.md,
      child: ColoredBox(
        color: context.colors.surfaceContainer,
        child: Column(
          children: [
            InkWell(
              onTap: () => context
                  .read<HoldingsUiCubit>()
                  .toggleExpanded(holding.ticker),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: plColor.withValues(alpha: 0.12),
                      child: Text(
                        holding.monogram,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: plColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  holding.company,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: context.colors.onSurface,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceContainerHighest,
                                  borderRadius: AppBorders.xs,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    'dashboard.nse'.tr(),
                                    style:
                                        context.textTheme.labelSmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'dashboard.shares_avg'.tr(
                              namedArgs: {
                                'qty': formatIndianNumber(
                                  holding.quantity,
                                  decimals: 0,
                                ),
                                'avg': formatInr(holding.avgBuyPrice),
                              },
                            ),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        HoldingPriceCell(
                          ticker: holding.ticker,
                          fallbackPrice: holding.avgBuyPrice,
                        ),
                        HoldingPlCell(holding: holding),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              ColoredBox(
                color: context.colors.surfaceContainerLow,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: TargetAlertField(
                    ticker: holding.ticker,
                    savedAlert: holding.targetAlert,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
