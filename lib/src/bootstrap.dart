import 'package:mindorigin/src/imports/core_imports.dart';

import 'app.dart';
import 'config/env.dart';
import 'di/app_scope.dart';
import 'flavors.dart';

Future<void> bootstrap(Flavor flavor) async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();

  await Env.load(flavor);
  FlavorConfig.loadFromEnv(flavor);
  await AppConfig.init();
  await StorageService.instance.init();

  final scope = await AppScope.create();

  FlutterNativeSplash.remove();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  runApp(LocalizationWrapper(child: App(scope: scope)));
}
