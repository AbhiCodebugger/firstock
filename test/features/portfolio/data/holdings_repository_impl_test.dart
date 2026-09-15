import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_repository_impl.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_seed.dart';

void main() {
  test('load returns the seeded book', () async {
    final repo = HoldingsRepositoryImpl();
    final holdings = await repo.load();
    expect(holdings.map((h) => h.ticker), HoldingsSeed.holdingTickers);
  });
}
