import 'package:equatable/equatable.dart';

class PriceTick extends Equatable {
  const PriceTick({
    required this.ticker,
    required this.price,
    required this.timestamp,
    this.previousClose,
  });

  final String ticker;
  final double price;
  final DateTime timestamp;
  final double? previousClose;

  double get changePercent {
    final baseline = previousClose;
    if (baseline == null || baseline == 0) {
      return 0;
    }
    return ((price - baseline) / baseline) * 100;
  }

  @override
  List<Object?> get props => [ticker, price, timestamp, previousClose];
}
