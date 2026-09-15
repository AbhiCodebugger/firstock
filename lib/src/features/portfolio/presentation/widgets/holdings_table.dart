import 'package:flutter/material.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';
import '../../domain/entities/holding.dart';
import 'holding_pl_cell.dart';
import 'holding_price_cell.dart';
import 'target_alert_field.dart';

class HoldingsTable extends StatelessWidget {
  const HoldingsTable({
    super.key,
    required this.holdings,
    required this.expandedTicker,
    required this.onToggle,
  });

  final List<Holding> holdings;
  final String? expandedTicker;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(context),
        for (final holding in holdings) ...[
          _row(context, holding),
          if (expandedTicker == holding.ticker)
            ColoredBox(
              color: context.colors.surfaceContainerLow,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: TargetAlertField(
                  ticker: holding.ticker,
                  savedAlert: holding.targetAlert,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _header(BuildContext context) {
    final style = context.textTheme.labelSmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Company', style: style)),
          Expanded(child: Text('Ticker', style: style)),
          Expanded(child: Text('Qty', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('Avg', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('LTP', style: style, textAlign: TextAlign.end)),
          Expanded(child: Text('P/L', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Holding holding) {
    return InkWell(
      onTap: () => onToggle(holding.ticker),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                holding.company,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Text(
                holding.ticker,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: Text(
                formatIndianNumber(holding.quantity, decimals: 0),
                textAlign: TextAlign.end,
                style: tabularFigures(
                  context.textTheme.bodySmall!.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                formatInr(holding.avgBuyPrice),
                textAlign: TextAlign.end,
                style: tabularFigures(
                  context.textTheme.bodySmall!.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: HoldingPriceCell(
                  ticker: holding.ticker,
                  fallbackPrice: holding.avgBuyPrice,
                ),
              ),
            ),
            Expanded(
              child: HoldingPlCell(holding: holding, compact: false),
            ),
          ],
        ),
      ),
    );
  }
}
