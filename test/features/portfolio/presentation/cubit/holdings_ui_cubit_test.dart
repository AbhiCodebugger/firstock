import 'package:flutter_test/flutter_test.dart';
import 'package:mindorigin/src/features/portfolio/data/holdings_seed.dart';
import 'package:mindorigin/src/features/portfolio/domain/entities/holdings_view.dart';
import 'package:mindorigin/src/features/portfolio/presentation/cubit/holdings_ui_cubit.dart';

void main() {
  test('ticks cannot change a pinned sort order', () {
    final cubit = HoldingsUiCubit()..hydrate(HoldingsSeed.holdings);
    cubit.applySort(
      sort: HoldingsSort.plDesc,
      holdings: HoldingsSeed.holdings,
      livePrices: {
        for (final h in HoldingsSeed.holdings) h.ticker: h.previousClose,
      },
    );
    final pinned = List<String>.from(cubit.state.pinnedOrder);
    cubit.setQuery('rel');
    expect(cubit.state.pinnedOrder, pinned);
    cubit.close();
  });

  test('search only updates the query', () {
    final cubit = HoldingsUiCubit()..hydrate(HoldingsSeed.holdings);
    final order = cubit.state.pinnedOrder;
    cubit.setQuery('zom');
    expect(cubit.state.query, 'zom');
    expect(cubit.state.pinnedOrder, order);
    cubit.close();
  });
}
