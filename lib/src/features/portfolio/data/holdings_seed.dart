import '../domain/entities/holding.dart';

/// Stitch dashboard book. Same Indian names in every flavor.
abstract final class HoldingsSeed {
  static const List<Holding> holdings = [
    Holding(
      ticker: 'RELIANCE',
      company: 'Reliance Industries',
      exchange: 'NSE',
      monogram: 'REL',
      quantity: 100,
      avgBuyPrice: 1561.90,
      previousClose: 2740.10,
    ),
    Holding(
      ticker: 'TCS',
      company: 'Tata Consultancy Services',
      exchange: 'NSE',
      monogram: 'TCS',
      quantity: 40,
      avgBuyPrice: 2660,
      previousClose: 4120,
      targetAlert: 4450,
    ),
    Holding(
      ticker: 'HDFCBANK',
      company: 'HDFC Bank Ltd',
      exchange: 'NSE',
      monogram: 'HDF',
      quantity: 120,
      avgBuyPrice: 1408.90,
      previousClose: 1682.30,
      targetAlert: 1850,
    ),
    Holding(
      ticker: 'INFY',
      company: 'Infosys',
      exchange: 'NSE',
      monogram: 'INF',
      quantity: 80,
      avgBuyPrice: 1319.35,
      previousClose: 1845.60,
      targetAlert: 2050,
    ),
    Holding(
      ticker: 'ZOMATO',
      company: 'Zomato Ltd',
      exchange: 'NSE',
      monogram: 'ZOM',
      quantity: 200,
      avgBuyPrice: 288.40,
      previousClose: 264.40,
      targetAlert: 310,
    ),
  ];

  static const List<String> tapeExtras = [
    'NIFTY 50',
    'SENSEX',
    'TATAMOTORS',
    'ITC',
  ];

  static const Map<String, double> tapePreviousClose = {
    'NIFTY 50': 24852.15,
    'SENSEX': 81720.40,
    'TATAMOTORS': 972.40,
    'ITC': 492.15,
  };

  static List<String> get holdingTickers =>
      holdings.map((h) => h.ticker).toList(growable: false);

  static List<String> get watchTickers => [
        ...tapeExtras,
        ...holdingTickers,
      ];
}
