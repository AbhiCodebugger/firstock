import 'package:equatable/equatable.dart';

class Holding extends Equatable {
  const Holding({
    required this.ticker,
    required this.company,
    required this.exchange,
    required this.monogram,
    required this.quantity,
    required this.avgBuyPrice,
    required this.previousClose,
    this.targetAlert,
  });

  final String ticker;
  final String company;
  final String exchange;
  final String monogram;
  final double quantity;
  final double avgBuyPrice;
  final double previousClose;
  final double? targetAlert;

  Holding copyWith({double? targetAlert, bool clearAlert = false}) {
    return Holding(
      ticker: ticker,
      company: company,
      exchange: exchange,
      monogram: monogram,
      quantity: quantity,
      avgBuyPrice: avgBuyPrice,
      previousClose: previousClose,
      targetAlert: clearAlert ? null : (targetAlert ?? this.targetAlert),
    );
  }

  @override
  List<Object?> get props => [
        ticker,
        company,
        exchange,
        monogram,
        quantity,
        avgBuyPrice,
        previousClose,
        targetAlert,
      ];
}
