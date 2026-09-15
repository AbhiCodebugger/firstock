import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/holding.dart';
import '../../domain/entities/holdings_view.dart';
import '../../domain/portfolio_math.dart';

class HoldingsUiState extends Equatable {
  const HoldingsUiState({
    this.query = '',
    this.sort = HoldingsSort.nameAsc,
    this.filter = HoldingsFilter.all,
    this.expandedTicker,
    this.pinnedOrder = const [],
    this.pinnedFilterIds = const {},
  });

  final String query;
  final HoldingsSort sort;
  final HoldingsFilter filter;
  final String? expandedTicker;
  final List<String> pinnedOrder;
  final Set<String> pinnedFilterIds;

  HoldingsUiState copyWith({
    String? query,
    HoldingsSort? sort,
    HoldingsFilter? filter,
    String? expandedTicker,
    bool clearExpanded = false,
    List<String>? pinnedOrder,
    Set<String>? pinnedFilterIds,
  }) {
    return HoldingsUiState(
      query: query ?? this.query,
      sort: sort ?? this.sort,
      filter: filter ?? this.filter,
      expandedTicker: clearExpanded
          ? null
          : (expandedTicker ?? this.expandedTicker),
      pinnedOrder: pinnedOrder ?? this.pinnedOrder,
      pinnedFilterIds: pinnedFilterIds ?? this.pinnedFilterIds,
    );
  }

  @override
  List<Object?> get props => [
    query,
    sort,
    filter,
    expandedTicker,
    pinnedOrder,
    pinnedFilterIds,
  ];
}

class HoldingsUiCubit extends Cubit<HoldingsUiState> {
  HoldingsUiCubit() : super(const HoldingsUiState());

  void hydrate(List<Holding> holdings) {
    if (state.pinnedOrder.isNotEmpty) {
      return;
    }
    emit(
      state.copyWith(
        pinnedOrder: holdings.map((h) => h.ticker).toList(),
        pinnedFilterIds: holdings.map((h) => h.ticker).toSet(),
      ),
    );
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
  }

  void applySort({
    required HoldingsSort sort,
    required List<Holding> holdings,
    required Map<String, double> livePrices,
  }) {
    final ordered = sortHoldings(
      holdings,
      sort,
      livePrices,
    ).map((h) => h.ticker).toList();
    emit(state.copyWith(sort: sort, pinnedOrder: ordered));
  }

  void applyFilter({
    required HoldingsFilter filter,
    required List<Holding> holdings,
    required Map<String, double> livePrices,
  }) {
    final ids = holdings
        .where(
          (h) => matchesFilter(h, filter, livePrice: livePrices[h.ticker]),
        )
        .map((h) => h.ticker)
        .toSet();
    emit(state.copyWith(filter: filter, pinnedFilterIds: ids));
  }

  void toggleExpanded(String ticker) {
    if (state.expandedTicker == ticker) {
      emit(state.copyWith(clearExpanded: true));
      return;
    }
    emit(state.copyWith(expandedTicker: ticker));
  }
}
