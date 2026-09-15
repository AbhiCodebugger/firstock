import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/context_extension.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../theme/app_durations.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/debouncer.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/holdings_view.dart';
import '../../domain/portfolio_math.dart';
import '../cubit/holdings_cubit.dart';
import '../cubit/holdings_ui_cubit.dart';
import 'holdings_card.dart';
import 'holdings_table.dart';

class HoldingsSection extends StatefulWidget {
  const HoldingsSection({super.key, required this.asTable});

  final bool asTable;

  @override
  State<HoldingsSection> createState() => _HoldingsSectionState();
}

class _HoldingsSectionState extends State<HoldingsSection> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Debouncer _searchDebouncer = Debouncer(delay: AppDurations.quick);

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _controller.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      if (!mounted) {
        return;
      }
      context.read<HoldingsUiCubit>().setQuery(value);
    });
  }

  void _resetHoldingsView() {
    _searchDebouncer.dispose();
    _searchController.clear();
    context.read<HoldingsUiCubit>().setQuery('');
    context.read<HoldingsUiCubit>().applyFilter(
          filter: HoldingsFilter.all,
          holdings: context.read<HoldingsCubit>().state.holdings,
          livePrices: context.read<LivePricesCubit>().state.prices,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loaded = context.select(
      (HoldingsCubit cubit) => cubit.state.loaded,
    );
    final holdings = context.select(
      (HoldingsCubit cubit) => cubit.state.holdings,
    );
    final ui = context.watch<HoldingsUiCubit>().state;
    final visible = applyHoldingsView(
      holdings: holdings,
      query: ui.query,
      pinnedOrder: ui.pinnedOrder,
      pinnedFilterIds: ui.pinnedFilterIds.isEmpty
          ? holdings.map((h) => h.ticker).toSet()
          : ui.pinnedFilterIds,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final showHeader = constraints.maxHeight >= 168;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'dashboard.holdings_title'.tr(),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                    DropdownButton<HoldingsSort>(
                      value: ui.sort,
                      underline: const SizedBox.shrink(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface,
                      ),
                      dropdownColor: context.colors.surfaceContainerHigh,
                      iconEnabledColor: context.colors.onSurfaceVariant,
                      onChanged: (sort) {
                        if (sort == null) {
                          return;
                        }
                        context.read<HoldingsUiCubit>().applySort(
                              sort: sort,
                              holdings: holdings,
                              livePrices:
                                  context.read<LivePricesCubit>().state.prices,
                            );
                      },
                      items: [
                        DropdownMenuItem(
                          value: HoldingsSort.plDesc,
                          child: Text('dashboard.sort_pl_desc'.tr()),
                        ),
                        DropdownMenuItem(
                          value: HoldingsSort.plAsc,
                          child: Text('dashboard.sort_pl_asc'.tr()),
                        ),
                        DropdownMenuItem(
                          value: HoldingsSort.priceDesc,
                          child: Text('dashboard.sort_price_desc'.tr()),
                        ),
                        DropdownMenuItem(
                          value: HoldingsSort.qtyDesc,
                          child: Text('dashboard.sort_qty_desc'.tr()),
                        ),
                        DropdownMenuItem(
                          value: HoldingsSort.nameAsc,
                          child: Text('dashboard.sort_name_asc'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xs,
                AppSpacing.pagePadding,
                AppSpacing.sm,
              ),
              child: AppTextField(
                key: const ValueKey('holdings_search'),
                hint: 'dashboard.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: loaded && visible.isEmpty
                  ? AppEmptyState(
                      icon: Icons.search_off,
                      title: 'dashboard.empty_holdings'.tr(),
                      subtitle: 'dashboard.empty_holdings_hint'.tr(),
                      actionLabel: 'dashboard.show_all'.tr(),
                      onAction: _resetHoldingsView,
                    )
                  : widget.asTable
                      ? SingleChildScrollView(
                          controller: _controller,
                          child: HoldingsTable(
                            holdings: visible,
                            expandedTicker: ui.expandedTicker,
                            onToggle:
                                context.read<HoldingsUiCubit>().toggleExpanded,
                          ),
                        )
                      : ListView.separated(
                          controller: _controller,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.pagePadding,
                          ),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final holding = visible[index];
                            return RepaintBoundary(
                              key: ValueKey(holding.ticker),
                              child: HoldingsCard(
                                holding: holding,
                                expanded: ui.expandedTicker == holding.ticker,
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

/// Keeps [Holding] in scope for tests without exporting math.
List<Holding> debugVisibleHoldings({
  required List<Holding> holdings,
  required HoldingsUiState ui,
}) {
  return applyHoldingsView(
    holdings: holdings,
    query: ui.query,
    pinnedOrder: ui.pinnedOrder,
    pinnedFilterIds: ui.pinnedFilterIds,
  );
}
