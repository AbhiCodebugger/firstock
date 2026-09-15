import '../../imports/imports.dart';

/// A themed card widget with consistent padding, radius, and optional header.
///
/// Usage:
/// ```dart
/// AppCard(
///   child: Text('Card content'),
/// )
///
/// // With a header
/// AppCard(
///   title: 'Recent Transactions',
///   trailing: TextButton(onPressed: _seeAll, child: const Text('See all')),
///   child: TransactionList(),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    final cardColor = color ?? cs.surfaceContainerLow;

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || leading != null || trailing != null)
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.cardPadding,
              right: AppSpacing.cardPadding,
              top: AppSpacing.cardPadding,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, SizedBox(width: 12.w)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        Padding(
          padding: padding ??
              EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                title == null ? AppSpacing.cardPadding : 0,
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
              ),
          child: child,
        ),
      ],
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppBorders.card,
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: AppBorders.card,
              child: content,
            )
          : content,
    );
  }
}
