import '../../imports/imports.dart';

/// Empty filtered / searched holdings (or any short empty list).
///
/// Stays scrollable so a tight holdings pane does not overflow.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon: icon,
              size: 32,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: tt.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.sm),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: ButtonVariant.secondary,
                height: ButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
