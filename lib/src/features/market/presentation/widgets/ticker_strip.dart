import 'package:flutter/material.dart';

import '../../../../theme/app_spacing.dart';
import 'ticker_chip.dart';

class TickerStrip extends StatelessWidget {
  const TickerStrip({super.key, required this.tickers});

  final List<String> tickers;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          itemCount: tickers.length,
          itemBuilder: (context, index) {
            return TickerChip(
              key: ValueKey(tickers[index]),
              ticker: tickers[index],
            );
          },
        ),
      ),
    );
  }
}
