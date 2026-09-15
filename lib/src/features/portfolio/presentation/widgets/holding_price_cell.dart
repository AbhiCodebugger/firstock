import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../core/rebuild/rebuild_counters.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../flavors.dart';
import '../../../../theme/app_curves.dart';
import '../../../../theme/app_durations.dart';
import '../../../../theme/text_theme.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';

class HoldingPriceCell extends StatelessWidget {
  const HoldingPriceCell({
    super.key,
    required this.ticker,
    required this.fallbackPrice,
  });

  final String ticker;
  final double fallbackPrice;

  @override
  Widget build(BuildContext context) {
    final tick = context.select(
      (LivePricesCubit cubit) => cubit.state.tickFor(ticker),
    );
    if (FlavorConfig.isLoaded && FlavorConfig.current.showRebuildCounters) {
      RebuildCounters.increment('price_$ticker');
    }
    final price = tick?.price ?? fallbackPrice;
    final up = (tick?.changePercent ?? 0) >= 0;
    final flash = up ? context.appColors.yield : context.appColors.loss;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppDurations.priceFlash,
        curve: AppCurves.standard,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        color: flash.withValues(alpha: tick == null ? 0 : 0.14),
        child: Text(
          formatInr(price),
          style: tabularFigures(
            context.textTheme.labelMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
