import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/app_scope.dart';
import 'features/portfolio/presentation/screens/dashboard_page.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';
import 'imports/core_imports.dart';

class App extends StatelessWidget {
  const App({super.key, required this.scope});

  final AppScope scope;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: scope.providers,
      child: const ScreenUtilWrapper(child: _AppView()),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Mindorigin Portfolio',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: context.watch<ThemeCubit>().state.mode,
      home: const DashboardPage(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
