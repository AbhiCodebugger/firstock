import '../domain/entities/chart_point.dart';
import '../domain/portfolio_math.dart';
import '../domain/repositories/chart_repository.dart';
import 'holdings_seed.dart';

class ChartRepositoryImpl implements ChartRepository {
  ChartRepositoryImpl({DateTime? now}) : _now = now;

  final DateTime? _now;

  @override
  Future<List<ChartPoint>> series() async {
    final today = _now ?? DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final prices = {
      for (final h in HoldingsSeed.holdings) h.ticker: h.previousClose,
    };
    final baseline = summarizePortfolio(HoldingsSeed.holdings, prices);
    const walk = <double>[
      0.94,
      0.96,
      0.95,
      0.98,
      0.97,
      0.99,
      1.01,
      0.995,
      1.015,
      1,
    ];
    return [
      for (var i = 0; i < walk.length; i++)
        ChartPoint(
          date: day.subtract(Duration(days: walk.length - 1 - i)),
          value: baseline.currentValue * walk[i],
        ),
    ];
  }
}
