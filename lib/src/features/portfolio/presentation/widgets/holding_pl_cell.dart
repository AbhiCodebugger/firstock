import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../theme/text_theme.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';
import '../../domain/entities/holding.dart';
import '../../domain/portfolio_math.dart';

class HoldingPlCell extends StatelessWidget {
  const HoldingPlCell({
    super.key,
    required this.holding,
    this.compact = true,
  });

  final Holding holding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tick = context.select(
      (LivePricesCubit cubit) => cubit.state.tickFor(holding.ticker),
    );
    final metrics = metricsFor(holding, livePrice: tick?.price);
    final color = metrics.unrealizedPl >= 0
        ? context.appColors.yield
        : context.appColors.loss;
    return Text(
      formatInr(metrics.unrealizedPl, decimals: 0, signed: true),
      textAlign: TextAlign.end,
      style: tabularFigures(
        (compact ? context.textTheme.labelSmall : context.textTheme.bodySmall)!
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
