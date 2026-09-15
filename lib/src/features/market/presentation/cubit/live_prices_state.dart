import 'package:equatable/equatable.dart';

import '../../domain/entities/price_tick.dart';

class LivePricesState extends Equatable {
  const LivePricesState({this.ticks = const {}});

  final Map<String, PriceTick> ticks;

  PriceTick? tickFor(String ticker) => ticks[ticker];

  Map<String, double> get prices => {
        for (final entry in ticks.entries) entry.key: entry.value.price,
      };

  @override
  List<Object?> get props => [ticks];
}
