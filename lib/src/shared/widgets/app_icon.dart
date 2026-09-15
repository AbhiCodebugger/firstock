import '../../imports/imports.dart';

/// Themed [Icon] used by empty state and other chrome.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  /// The icon to display.
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
