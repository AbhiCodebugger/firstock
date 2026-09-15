import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/app_http_client.dart';
import '../features/market/data/create_price_feed.dart';
import '../features/market/domain/repositories/price_feed.dart';
import '../features/market/presentation/cubit/connection_cubit.dart';
import '../features/market/presentation/cubit/live_prices_cubit.dart';
import '../features/portfolio/data/holdings_seed.dart';
import '../flavors.dart';

/// Shared [PriceFeed] plus live-price and connection cubits.
class MarketBindings {
  MarketBindings._({required this.feed, required this.providers});

  final PriceFeed feed;
  final List<BlocProvider> providers;

  factory MarketBindings.create({
    required Map<String, double> previousCloses,
    PriceFeed? feed,
  }) {
    final priceFeed =
        feed ??
        createPriceFeed(
          FlavorConfig.current,
          httpClient: AppHttpClient(),
          simulatedPreviousCloses: previousCloses,
        );
    return MarketBindings._(
      feed: priceFeed,
      providers: [
        BlocProvider<LivePricesCubit>(
          create: (_) {
            final cubit = LivePricesCubit(feed: priceFeed);
            unawaited(cubit.start(HoldingsSeed.watchTickers));
            return cubit;
          },
          lazy: false,
        ),
        BlocProvider<ConnectionCubit>(
          create: (_) => ConnectionCubit(feed: priceFeed),
          lazy: false,
        ),
      ],
    );
  }
}
