import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/data/chart_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/domain/entities/chart_point.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/chart_cubit.dart';

void main() {
  test('changing range does not depend on live ticks', () async {
    final cubit = ChartCubit(
      ChartRepositoryImpl(now: DateTime(2026, 9, 13)),
    );
    await cubit.load();
    expect(cubit.state.points.length, 10);
    cubit.setRange(ChartRange.oneDay);
    expect(cubit.state.visible.length, 2);
    cubit.setRange(ChartRange.tenDays);
    expect(cubit.state.visible.length, 10);
    await cubit.close();
  });
}
