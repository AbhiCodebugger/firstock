import '../entities/holding.dart';
import '../repositories/holdings_repository.dart';

class LoadHoldings {
  const LoadHoldings(this._repository);

  final HoldingsRepository _repository;

  Future<List<Holding>> call() => _repository.load();
}
