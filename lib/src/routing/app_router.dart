import 'package:flutter/material.dart';

import '../features/portfolio/presentation/screens/dashboard_page.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );
    }
  }
}
