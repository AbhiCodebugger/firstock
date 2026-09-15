import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chart_point.dart';
import '../../domain/repositories/chart_repository.dart';

class ChartState extends Equatable {
  const ChartState({
    this.range = ChartRange.threeDays,
    this.points = const [],
    this.visible = const [],
  });

  final ChartRange range;
  final List<ChartPoint> points;
  final List<ChartPoint> visible;

  @override
  List<Object?> get props => [range, points, visible];
}

class ChartCubit extends Cubit<ChartState> {
  ChartCubit(this._repository) : super(const ChartState());

  final ChartRepository _repository;

  Future<void> load() async {
    final points = await _repository.series();
    emit(
      ChartState(
        range: state.range,
        points: points,
        visible: _window(points, state.range),
      ),
    );
  }

  void setRange(ChartRange range) {
    if (range == state.range) {
      return;
    }
    emit(
      ChartState(
        range: range,
        points: state.points,
        visible: _window(state.points, range),
      ),
    );
  }

  List<ChartPoint> _window(List<ChartPoint> points, ChartRange range) {
    final count = range.pointCount;
    if (points.length <= count) {
      return points;
    }
    return points.sublist(points.length - count);
  }
}
