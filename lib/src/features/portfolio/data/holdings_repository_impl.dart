import '../domain/entities/holding.dart';
import '../domain/repositories/holdings_repository.dart';
import 'holdings_seed.dart';

class HoldingsRepositoryImpl implements HoldingsRepository {
  HoldingsRepositoryImpl({List<Holding>? seed})
      : _holdings = List<Holding>.from(seed ?? HoldingsSeed.holdings);

  final List<Holding> _holdings;

  @override
  Future<List<Holding>> load() async {
    return List<Holding>.unmodifiable(_holdings);
  }

  @override
  Future<void> updateTargetAlert(String ticker, double? value) async {
    final index = _holdings.indexWhere((h) => h.ticker == ticker);
    if (index < 0) {
      return;
    }
    _holdings[index] = _holdings[index].copyWith(
      targetAlert: value,
      clearAlert: value == null,
    );
  }
}
