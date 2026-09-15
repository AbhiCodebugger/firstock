import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/connection_status.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../theme/app_borders.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';
import '../cubit/connection_cubit.dart';

class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (ConnectionCubit cubit) => cubit.state.status,
    );
    final colors = context.appColors;
    final scheme = context.colors;
    final isLive = status == FeedConnectionStatus.live;
    final isOffline = status == FeedConnectionStatus.offline;
    final color = isOffline
        ? colors.loss
        : isLive
            ? colors.yield
            : scheme.tertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: AppBorders.sm,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              status.label,
              style: tabularFigures(
                context.textTheme.labelSmall!.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
