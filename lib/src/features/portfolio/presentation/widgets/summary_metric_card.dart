import 'package:flutter/material.dart';

import '../../../../extensions/context_extension.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';

class SummaryMetricCard extends StatelessWidget {
  const SummaryMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: context.colors.surfaceContainer,
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: tabularFigures(
              context.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.colors.onSurface,
              ),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle!,
              style: tabularFigures(
                context.textTheme.labelSmall!.copyWith(
                  color: valueColor ?? context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
