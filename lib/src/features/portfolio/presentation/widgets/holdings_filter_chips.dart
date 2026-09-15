import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/context_extension.dart';
import '../../../../theme/app_borders.dart';
import '../../../../theme/app_spacing.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';
import '../../domain/entities/holdings_view.dart';
import '../cubit/holdings_cubit.dart';
import '../cubit/holdings_ui_cubit.dart';

class HoldingsFilterChips extends StatelessWidget {
  const HoldingsFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select(
      (HoldingsUiCubit cubit) => cubit.state.filter,
    );
    final count = context.select(
      (HoldingsCubit cubit) => cubit.state.holdings.length,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          _chip(
            context,
            HoldingsFilter.all,
            '${'dashboard.filter_all'.tr()} ($count)',
            selected,
          ),
          _chip(
            context,
            HoldingsFilter.invested,
            'dashboard.filter_invested'.tr(),
            selected,
          ),
          _chip(
            context,
            HoldingsFilter.profit,
            'dashboard.filter_profit'.tr(),
            selected,
          ),
          _chip(
            context,
            HoldingsFilter.loss,
            'dashboard.filter_loss'.tr(),
            selected,
          ),
          _chip(
            context,
            HoldingsFilter.movers,
            'dashboard.filter_movers'.tr(),
            selected,
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    HoldingsFilter filter,
    String label,
    HoldingsFilter selected,
  ) {
    final active = filter == selected;
    return FilterChip(
      selected: active,
      showCheckmark: false,
      label: Text(label),
      selectedColor: context.colors.primary,
      labelStyle: context.textTheme.labelSmall?.copyWith(
        color: active ? context.colors.onPrimary : context.colors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: context.colors.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: AppBorders.full),
      onSelected: (_) {
        context.read<HoldingsUiCubit>().applyFilter(
          filter: filter,
          holdings: context.read<HoldingsCubit>().state.holdings,
          livePrices: context.read<LivePricesCubit>().state.prices,
        );
      },
    );
  }
}
