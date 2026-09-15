import '../entities/chart_point.dart';

abstract class ChartRepository {
  Future<List<ChartPoint>> series();
}
