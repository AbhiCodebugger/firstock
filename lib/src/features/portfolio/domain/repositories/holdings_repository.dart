import '../entities/holding.dart';

abstract class HoldingsRepository {
  Future<List<Holding>> load();

  Future<void> updateTargetAlert(String ticker, double? value);
}
