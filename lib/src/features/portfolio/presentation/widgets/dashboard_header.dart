import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/connection_status.dart';
import '../../../../core/rebuild/rebuild_counters.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../extensions/date_time_extension.dart';
import '../../../../flavors.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../market/presentation/cubit/connection_cubit.dart';
import '../../../market/presentation/cubit/live_prices_cubit.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../../../market/presentation/widgets/connection_chip.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final flavor = FlavorConfig.isLoaded ? FlavorConfig.current : null;
    final status = context.select(
      (ConnectionCubit cubit) => cubit.state.status,
    );

    return AppTopBar(
      title: 'dashboard.app_name'.tr(),
      showLeading: false,
      centerTitle: false,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'dashboard.app_name'.tr(),
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          Text(
            DateTime.now().dashboardLongDate,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (flavor?.showKillSocket ?? false)
          TextButton(
            onPressed: () => context.read<LivePricesCubit>().killForDemo(),
            child: Text('dashboard.kill_socket'.tr()),
          ),
        if (status == FeedConnectionStatus.offline)
          TextButton(
            onPressed: () => context.read<LivePricesCubit>().retry(),
            child: Text('dashboard.retry'.tr()),
          ),
        const ConnectionChip(),
        IconButton(
          tooltip: 'Theme',
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: Icon(
            context.watch<ThemeCubit>().state.mode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
        if (flavor?.showRebuildCounters ?? false)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${RebuildCounters.counts.length}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ),
      ],
    );
  }
}
