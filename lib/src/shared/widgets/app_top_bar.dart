import '../../imports/imports.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.centerTitle = true,
    this.onPressed,
    this.isTransparent = false,
    this.showLeading = true,
  });

  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onPressed;
  final bool? centerTitle;
  final bool isTransparent;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final canPop = Navigator.canPop(context);

    void handleBack() {
      if (onPressed != null) {
        onPressed!();
      } else if (canPop) {
        Navigator.maybePop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    }

    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      automaticallyImplyLeading: showLeading,
      backgroundColor: isTransparent ? Colors.transparent : null,
      shadowColor: Colors.transparent,
      title: titleWidget ??
          Text(
            title,
            style: theme.appBarTheme.titleTextStyle?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ) ??
                theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
          ),
      leadingWidth: showLeading ? 40.w : 0,
      leading: showLeading
          ? GestureDetector(
              onTap: handleBack,
              child: ColoredBox(
                color: Colors.transparent,
                child: Icon(
                  Icons.arrow_back,
                  color: theme.appBarTheme.iconTheme?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
            )
          : null,
      iconTheme: theme.appBarTheme.iconTheme,
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
