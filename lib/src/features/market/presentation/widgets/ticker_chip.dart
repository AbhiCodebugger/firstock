import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../core/rebuild/rebuild_counters.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../flavors.dart';
import '../../../../theme/app_curves.dart';
import '../../../../theme/app_durations.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';
import '../cubit/live_prices_cubit.dart';

class TickerChip extends StatelessWidget {
  const TickerChip({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    final tick = context.select(
      (LivePricesCubit cubit) => cubit.state.tickFor(ticker),
    );
    if (FlavorConfig.isLoaded && FlavorConfig.current.showRebuildCounters) {
      RebuildCounters.increment('ticker_$ticker');
    }
    final colors = context.appColors;
    final change = tick?.changePercent ?? 0;
    final up = change >= 0;
    final flash = up ? colors.yield : colors.loss;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(right: AppSpacing.md),
        child: AnimatedContainer(
          duration: AppDurations.priceFlash,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: flash.withValues(alpha: tick == null ? 0 : 0.12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ticker,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                tick == null ? '—' : formatInr(tick.price),
                style: tabularFigures(
                  context.textTheme.labelSmall!.copyWith(
                    color: context.colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                formatPercent(change),
                style: tabularFigures(
                  context.textTheme.labelSmall!.copyWith(
                    color: up ? colors.yield : colors.loss,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
