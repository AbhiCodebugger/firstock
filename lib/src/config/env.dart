import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../flavors.dart';

/// Loads the flavor `.env.*` file. Token stays out of [FlavorConfig].
abstract final class Env {
  static Future<void> load(Flavor flavor) async {
    await dotenv.load(fileName: flavor.envFile);
  }

  static String get(String key, {String fallback = ''}) {
    return dotenv.get(key, fallback: fallback);
  }

  static bool flag(String key, {bool fallback = false}) {
    final raw = dotenv.get(key, fallback: fallback ? 'true' : 'false');
    return raw.toLowerCase() == 'true' || raw == '1';
  }

  static int integer(String key, {required int fallback}) {
    return int.tryParse(dotenv.get(key, fallback: '$fallback')) ?? fallback;
  }

  static double decimal(String key, {required double fallback}) {
    return double.tryParse(dotenv.get(key, fallback: '$fallback')) ?? fallback;
  }

  /// Prod token comes from `--dart-define=FINNHUB_TOKEN=...`. Env is a placeholder.
  static String get finnhubToken {
    const fromDefine = String.fromEnvironment(
      'FINNHUB_TOKEN',
      defaultValue: '',
    );
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.get('FINNHUB_TOKEN', fallback: '');
  }
}
