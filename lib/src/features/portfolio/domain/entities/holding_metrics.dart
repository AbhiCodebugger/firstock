import 'package:equatable/equatable.dart';

/// Derived row metrics. Never persisted on a cubit as source of truth.
class HoldingMetrics extends Equatable {
  const HoldingMetrics({
    required this.invested,
    required this.currentValue,
    required this.unrealizedPl,
    required this.plPercent,
    required this.todayChange,
    required this.livePrice,
  });

  final double invested;
  final double currentValue;
  final double unrealizedPl;
  final double plPercent;
  final double todayChange;
  final double livePrice;

  @override
  List<Object?> get props => [
        invested,
        currentValue,
        unrealizedPl,
        plPercent,
        todayChange,
        livePrice,
      ];
}
