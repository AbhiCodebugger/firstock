import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money/inr_format.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../shared/enums/button_enums.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../theme/app_borders.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/text_theme.dart';
import '../../../../utils/input_formatters.dart';
import '../cubit/holdings_cubit.dart';
import '../cubit/target_alert_edit_cubit.dart';

class TargetAlertField extends StatefulWidget {
  const TargetAlertField({
    super.key,
    required this.ticker,
    required this.savedAlert,
  });

  final String ticker;
  final double? savedAlert;

  @override
  State<TargetAlertField> createState() => _TargetAlertFieldState();
}

class _TargetAlertFieldState extends State<TargetAlertField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.savedAlert?.toString() ?? '',
    );
    context
        .read<TargetAlertEditCubit>()
        .begin(widget.ticker, widget.savedAlert);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final edit = context.watch<TargetAlertEditCubit>().state;
    final hasActive = (edit.snapshot ?? 0) > 0;
    final snapshotLabel = formatInr(edit.snapshot ?? 0, decimals: 0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: AppBorders.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs + AppSpacing.xxs,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 14,
                  color: scheme.tertiary,
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'dashboard.target_alert'.tr(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: hasActive
                        ? scheme.tertiary.withValues(alpha: 0.10)
                        : scheme.primary.withValues(alpha: 0.20),
                    borderRadius: AppBorders.full,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      'dashboard.active_alert'.tr(
                        namedArgs: {'value': snapshotLabel},
                      ),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: hasActive ? scheme.tertiary : scheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [DecimalInputFormatter()],
                    style: tabularFigures(
                      context.textTheme.titleSmall!.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    cursorColor: scheme.primary,
                    onChanged: context.read<TargetAlertEditCubit>().setDraft,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      hintText: snapshotLabel,
                      hintStyle: tabularFigures(
                        context.textTheme.titleSmall!.copyWith(
                          color: scheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      prefix: Padding(
                        padding: EdgeInsets.only(right: AppSpacing.xxs),
                        child: Text(
                          '₹',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs + AppSpacing.xxs,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppBorders.input,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppBorders.input,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppBorders.input,
                        borderSide: BorderSide(color: scheme.primary),
                      ),
                    ),
                  ),
                ),
                AppButton(
                  label: 'dashboard.save_alert'.tr(),
                  onPressed: _save,
                  height: ButtonSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    context.hideKeyboard();
    final edit = context.read<TargetAlertEditCubit>().state;
    await context.read<HoldingsCubit>().saveAlert(
          ticker: widget.ticker,
          value: edit.parsed,
          snapshot: edit.snapshot,
        );
    if (!mounted) {
      return;
    }
    context.read<TargetAlertEditCubit>().begin(widget.ticker, edit.parsed);
  }
}
