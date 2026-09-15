import '../repositories/holdings_repository.dart';

class UpdateTargetAlert {
  const UpdateTargetAlert(this._repository);

  final HoldingsRepository _repository;

  /// Snapshot-and-diff: skip I/O when the draft equals the opened value.
  Future<bool> call({
    required String ticker,
    required double? value,
    required double? snapshot,
  }) async {
    if (value == snapshot) {
      return false;
    }
    await _repository.updateTargetAlert(ticker, value);
    return true;
  }
}
