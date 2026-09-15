import 'package:equatable/equatable.dart';

class ChartPoint extends Equatable {
  const ChartPoint({required this.date, required this.value});

  final DateTime date;
  final double value;

  @override
  List<Object?> get props => [date, value];
}

enum ChartRange { oneDay, threeDays, fiveDays, sevenDays, tenDays }

extension ChartRangeX on ChartRange {
  int get dayCount => switch (this) {
        ChartRange.oneDay => 1,
        ChartRange.threeDays => 3,
        ChartRange.fiveDays => 5,
        ChartRange.sevenDays => 7,
        ChartRange.tenDays => 10,
      };

  /// Points to slice from the series. [oneDay] uses 2 so the line chart has
  /// a start/end pair (daily data has one point per day).
  int get pointCount => switch (this) {
        ChartRange.oneDay => 2,
        ChartRange.threeDays => 3,
        ChartRange.fiveDays => 5,
        ChartRange.sevenDays => 7,
        ChartRange.tenDays => 10,
      };

  String get label => switch (this) {
        ChartRange.oneDay => '1d',
        ChartRange.threeDays => '3d',
        ChartRange.fiveDays => '5d',
        ChartRange.sevenDays => '7d',
        ChartRange.tenDays => '10d',
      };
}
