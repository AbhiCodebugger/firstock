import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TargetAlertEditState extends Equatable {
  const TargetAlertEditState({
    this.ticker,
    this.snapshot,
    this.draft = '',
  });

  final String? ticker;
  final double? snapshot;
  final String draft;

  double? get parsed {
    final text = draft.trim();
    if (text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }

  bool get hasChanged => parsed != snapshot;

  @override
  List<Object?> get props => [ticker, snapshot, draft];
}

class TargetAlertEditCubit extends Cubit<TargetAlertEditState> {
  TargetAlertEditCubit() : super(const TargetAlertEditState());

  void begin(String ticker, double? snapshot) {
    emit(
      TargetAlertEditState(
        ticker: ticker,
        snapshot: snapshot,
        draft: snapshot?.toString() ?? '',
      ),
    );
  }

  void setDraft(String value) {
    if (state.ticker == null) {
      return;
    }
    emit(
      TargetAlertEditState(
        ticker: state.ticker,
        snapshot: state.snapshot,
        draft: value,
      ),
    );
  }

  void clear() {
    emit(const TargetAlertEditState());
  }
}
