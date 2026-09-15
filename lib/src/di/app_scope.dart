import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/market/data/create_price_feed.dart';
import '../features/market/domain/repositories/price_feed.dart';
import '../features/portfolio/data/holdings_seed.dart';
import '../features/theme/domain/repositories/theme_repository.dart';
import 'market_bindings.dart';
import 'portfolio_bindings.dart';
import 'theme_bindings.dart';

class AppScope {
  AppScope._({required this.providers, required this.feed});

  final List<BlocProvider> providers;
  final PriceFeed feed;

  static Future<AppScope> create({
    ThemeRepository? themeRepository,
    PriceFeed? feed,
  }) async {
    final theme = await ThemeBindings.create(repository: themeRepository);
    final portfolio = PortfolioBindings.create();
    final previousCloses = previousClosesFromHoldings(
      holdingCloses: {
        for (final holding in HoldingsSeed.holdings)
          holding.ticker: holding.previousClose,
      },
      tapeCloses: HoldingsSeed.tapePreviousClose,
    );
    final market = MarketBindings.create(
      previousCloses: previousCloses,
      feed: feed,
    );
    return AppScope._(
      feed: market.feed,
      providers: [
        ...theme.providers,
        ...portfolio.providers,
        ...market.providers,
      ],
    );
  }
}
