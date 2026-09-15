import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/connection_status.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../theme/app_spacing.dart';
import '../cubit/connection_cubit.dart';

/// Reconnect / offline strip. Hidden while the feed is live.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select(
      (ConnectionCubit cubit) => cubit.state.status,
    );
    if (status == FeedConnectionStatus.live) {
      return const SizedBox.shrink();
    }

    final offline = status == FeedConnectionStatus.offline;
    final accent = offline ? context.appColors.loss : context.colors.tertiary;
    final message = offline
        ? 'dashboard.offline_toast'.tr()
        : 'dashboard.reconnect_toast'.tr();

    return Material(
      color: accent.withValues(alpha: 0.16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.ms,
        ),
        child: Row(
          children: [
            Icon(
              offline ? Icons.cloud_off_outlined : Icons.sync,
              size: 16,
              color: accent,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.labelSmall?.copyWith(
                  color: accent,
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
