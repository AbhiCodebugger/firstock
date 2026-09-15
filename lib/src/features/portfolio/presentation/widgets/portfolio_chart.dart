import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../extensions/date_time_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../theme/app_borders.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';
import '../../domain/entities/chart_point.dart';
import '../cubit/chart_cubit.dart';

class PortfolioChart extends StatelessWidget {
  const PortfolioChart({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChartCubit>().state;
    final points = state.visible;
    final hero = points.isEmpty ? 0.0 : points.last.value;
    final scheme = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: AppCard(
        color: scheme.surfaceContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dashboard.performance'.tr().toUpperCase(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        formatInr(hero),
                        style: tabularFigures(
                          context.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: AppBorders.sm,
                  ),
                  child: Row(
                    children: [
                      for (final range in ChartRange.values)
                        _RangeChip(
                          range: range,
                          selected: state.range == range,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 126,
              child: points.length < 2
                  ? const SizedBox.shrink()
                  : LineChart(
                      LineChartData(
                        minY: _min(points),
                        maxY: _max(points),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: scheme.surfaceContainerHigh,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => scheme.inverseSurface,
                            getTooltipItems: (touched) {
                              return [
                                for (final spot in touched)
                                  LineTooltipItem(
                                    _tooltip(points, spot.x),
                                    tabularFigures(
                                      context.textTheme.labelSmall!.copyWith(
                                        color: scheme.onInverseSurface,
                                      ),
                                    ),
                                  ),
                              ];
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < points.length; i++)
                                FlSpot(i.toDouble(), points[i].value),
                            ],
                            isCurved: true,
                            color: context.appColors.yield,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  context.appColors.yield.withValues(
                                    alpha: 0.35,
                                  ),
                                  context.appColors.yield.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  points.isEmpty ? '' : points.first.date.chartShortDate,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'dashboard.verified_nav'.tr(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.appColors.yield,
                  ),
                ),
                Text(
                  points.isEmpty ? '' : points.last.date.chartShortDate,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _min(List<ChartPoint> points) {
    return points.map((p) => p.value).reduce((a, b) => a < b ? a : b) * 0.98;
  }

  double _max(List<ChartPoint> points) {
    return points.map((p) => p.value).reduce((a, b) => a > b ? a : b) * 1.02;
  }

  String _tooltip(List<ChartPoint> points, double x) {
    final index = x.round().clamp(0, points.length - 1);
    final point = points[index];
    return '${point.date.chartShortDate}\n${formatInr(point.value)}';
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({required this.range, required this.selected});

  final ChartRange range;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ChartCubit>().setRange(range),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : Colors.transparent,
            borderRadius: AppBorders.xs,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              range.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
