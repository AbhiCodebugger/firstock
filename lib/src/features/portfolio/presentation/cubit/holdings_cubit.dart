import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/collection_extension.dart';
import '../../domain/entities/holding.dart';
import '../../domain/usecases/load_holdings.dart';
import '../../domain/usecases/update_target_alert.dart';

class HoldingsState extends Equatable {
  const HoldingsState({this.holdings = const [], this.loaded = false});

  final List<Holding> holdings;
  final bool loaded;

  Holding? byTicker(String ticker) =>
      holdings.where((holding) => holding.ticker == ticker).firstOrNull;

  @override
  List<Object?> get props => [holdings, loaded];
}

class HoldingsCubit extends Cubit<HoldingsState> {
  HoldingsCubit({
    required LoadHoldings loadHoldings,
    required UpdateTargetAlert updateTargetAlert,
  })  : _loadHoldings = loadHoldings,
        _updateTargetAlert = updateTargetAlert,
        super(const HoldingsState());

  final LoadHoldings _loadHoldings;
  final UpdateTargetAlert _updateTargetAlert;

  Future<void> load() async {
    final holdings = await _loadHoldings();
    emit(HoldingsState(holdings: holdings, loaded: true));
  }

  Future<bool> saveAlert({
    required String ticker,
    required double? value,
    required double? snapshot,
  }) async {
    final wrote = await _updateTargetAlert(
      ticker: ticker,
      value: value,
      snapshot: snapshot,
    );
    if (!wrote) {
      return false;
    }
    final next = [
      for (final holding in state.holdings)
        if (holding.ticker == ticker)
          holding.copyWith(targetAlert: value, clearAlert: value == null)
        else
          holding,
    ];
    emit(HoldingsState(holdings: next, loaded: true));
    return true;
  }
}
