import 'entities/holding.dart';
import 'entities/holding_metrics.dart';
import 'entities/holdings_view.dart';
import 'entities/portfolio_summary.dart';

/// Live price used for valuation. Falls back to avg buy when no tick exists.
double livePriceOf(Holding holding, double? tickPrice) {
  return tickPrice ?? holding.avgBuyPrice;
}

HoldingMetrics metricsFor(Holding holding, {double? livePrice}) {
  final price = livePriceOf(holding, livePrice);
  final invested = holding.quantity * holding.avgBuyPrice;
  final currentValue = holding.quantity * price;
  final unrealizedPl = currentValue - invested;
  final plPercent = invested == 0 ? 0.0 : unrealizedPl / invested;
  final todayChange = holding.quantity * (price - holding.previousClose);
  return HoldingMetrics(
    invested: invested,
    currentValue: currentValue,
    unrealizedPl: unrealizedPl,
    plPercent: plPercent,
    todayChange: todayChange,
    livePrice: price,
  );
}

PortfolioSummary summarizePortfolio(
  List<Holding> holdings,
  Map<String, double> livePrices,
) {
  var invested = 0.0;
  var currentValue = 0.0;
  var todayChange = 0.0;
  for (final holding in holdings) {
    final metrics = metricsFor(
      holding,
      livePrice: livePrices[holding.ticker],
    );
    invested += metrics.invested;
    currentValue += metrics.currentValue;
    todayChange += metrics.todayChange;
  }
  final unrealizedPl = currentValue - invested;
  final plPercent = invested == 0 ? 0.0 : unrealizedPl / invested;
  final todayChangePercent = currentValue - todayChange == 0
      ? 0.0
      : todayChange / (currentValue - todayChange);
  return PortfolioSummary(
    invested: invested,
    currentValue: currentValue,
    unrealizedPl: unrealizedPl,
    plPercent: plPercent,
    todayChange: todayChange,
    todayChangePercent: todayChangePercent,
    holdingCount: holdings.length,
  );
}

bool matchesFilter(
  Holding holding,
  HoldingsFilter filter, {
  double? livePrice,
}) {
  final metrics = metricsFor(holding, livePrice: livePrice);
  switch (filter) {
    case HoldingsFilter.all:
      return true;
    case HoldingsFilter.invested:
      return metrics.invested >= 100000;
    case HoldingsFilter.profit:
      return metrics.unrealizedPl > 0;
    case HoldingsFilter.loss:
      return metrics.unrealizedPl < 0;
    case HoldingsFilter.movers:
      final prev = holding.previousClose;
      if (prev == 0) {
        return false;
      }
      final changePct = ((metrics.livePrice - prev) / prev).abs();
      return changePct >= 0.01;
  }
}

List<Holding> sortHoldings(
  List<Holding> holdings,
  HoldingsSort sort,
  Map<String, double> livePrices,
) {
  final copy = List<Holding>.from(holdings);
  int byTicker(Holding a, Holding b) => a.ticker.compareTo(b.ticker);
  copy.sort((a, b) {
    final ma = metricsFor(a, livePrice: livePrices[a.ticker]);
    final mb = metricsFor(b, livePrice: livePrices[b.ticker]);
    final cmp = switch (sort) {
      HoldingsSort.plDesc => mb.unrealizedPl.compareTo(ma.unrealizedPl),
      HoldingsSort.plAsc => ma.unrealizedPl.compareTo(mb.unrealizedPl),
      HoldingsSort.priceDesc => mb.livePrice.compareTo(ma.livePrice),
      HoldingsSort.qtyDesc => b.quantity.compareTo(a.quantity),
      HoldingsSort.nameAsc => a.company.compareTo(b.company),
    };
    return cmp != 0 ? cmp : byTicker(a, b);
  });
  return copy;
}

List<Holding> applyHoldingsView({
  required List<Holding> holdings,
  required String query,
  required List<String> pinnedOrder,
  required Set<String> pinnedFilterIds,
}) {
  final searched = query.trim().isEmpty
      ? holdings
      : holdings.where((h) {
          final q = query.trim().toLowerCase();
          return h.company.toLowerCase().contains(q) ||
              h.ticker.toLowerCase().contains(q);
        }).toList();
  final filtered =
      searched.where((h) => pinnedFilterIds.contains(h.ticker)).toList();
  if (pinnedOrder.isEmpty) {
    return filtered;
  }
  final rank = {for (var i = 0; i < pinnedOrder.length; i++) pinnedOrder[i]: i};
  filtered.sort((a, b) {
    final ra = rank[a.ticker] ?? 1 << 20;
    final rb = rank[b.ticker] ?? 1 << 20;
    if (ra != rb) {
      return ra.compareTo(rb);
    }
    return a.ticker.compareTo(b.ticker);
  });
  return filtered;
}
