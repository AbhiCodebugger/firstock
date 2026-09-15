import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/domain/entities/holding.dart';
import 'package:mindorigin/src/features/portfolio/domain/entities/holdings_view.dart';
import 'package:mindorigin/src/features/portfolio/domain/portfolio_math.dart';

void main() {
  const holding = Holding(
    ticker: 'AAA',
    company: 'Alpha',
    exchange: 'NSE',
    monogram: 'ALP',
    quantity: 10,
    avgBuyPrice: 100,
    previousClose: 110,
  );

  test('uses avg buy when there is no live tick', () {
    final metrics = metricsFor(holding);
    expect(metrics.livePrice, 100);
    expect(metrics.invested, 1000);
    expect(metrics.currentValue, 1000);
    expect(metrics.unrealizedPl, 0);
  });

  test('computes P/L and today change from a live price', () {
    final metrics = metricsFor(holding, livePrice: 120);
    expect(metrics.currentValue, 1200);
    expect(metrics.unrealizedPl, 200);
    expect(metrics.plPercent, closeTo(0.2, 0.0001));
    expect(metrics.todayChange, 100);
  });

  test('zero invested does not divide by zero', () {
    const empty = Holding(
      ticker: 'BBB',
      company: 'Beta',
      exchange: 'NSE',
      monogram: 'BET',
      quantity: 0,
      avgBuyPrice: 0,
      previousClose: 10,
    );
    final metrics = metricsFor(empty, livePrice: 12);
    expect(metrics.plPercent, 0);
    expect(metrics.invested, 0);
  });

  test('summarizePortfolio aggregates holdings', () {
    const other = Holding(
      ticker: 'CCC',
      company: 'Gamma',
      exchange: 'NSE',
      monogram: 'GAM',
      quantity: 2,
      avgBuyPrice: 50,
      previousClose: 40,
    );
    final summary = summarizePortfolio(
      [holding, other],
      {'AAA': 120, 'CCC': 40},
    );
    expect(summary.invested, 1100);
    expect(summary.currentValue, 1280);
    expect(summary.unrealizedPl, 180);
  });

  test('matchesFilter profit and loss', () {
    expect(
      matchesFilter(holding, HoldingsFilter.profit, livePrice: 150),
      isTrue,
    );
    expect(
      matchesFilter(holding, HoldingsFilter.loss, livePrice: 80),
      isTrue,
    );
    expect(
      matchesFilter(holding, HoldingsFilter.invested, livePrice: 150),
      isFalse,
    );
  });
}
