import 'package:equatable/equatable.dart';

/// Derived portfolio totals. Computed at read time from holdings + ticks.
class PortfolioSummary extends Equatable {
  const PortfolioSummary({
    required this.invested,
    required this.currentValue,
    required this.unrealizedPl,
    required this.plPercent,
    required this.todayChange,
    required this.todayChangePercent,
    required this.holdingCount,
  });

  final double invested;
  final double currentValue;
  final double unrealizedPl;
  final double plPercent;
  final double todayChange;
  final double todayChangePercent;
  final int holdingCount;

  @override
  List<Object?> get props => [
        invested,
        currentValue,
        unrealizedPl,
        plPercent,
        todayChange,
        todayChangePercent,
        holdingCount,
      ];
}
