import 'package:shared_preferences/shared_preferences.dart';
import '../utils/utils.dart';

/// SharedPreferences wrapper used for theme mode only.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late final SharedPreferences _prefs;

  /// Initialize SharedPreferences instance.
  FutureEitherVoid init() async {
    return runTask(() async {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.success('StorageService initialized');
    });
  }

  FutureEither<bool> setString(String key, String value) async =>
      runTask(() => _prefs.setString(key, value));

  FutureEither<bool> setBool(String key, bool value) async =>
      runTask(() => _prefs.setBool(key, value));

  FutureEither<bool> setInt(String key, int value) async =>
      runTask(() => _prefs.setInt(key, value));

  FutureEither<bool> setDouble(String key, double value) async =>
      runTask(() => _prefs.setDouble(key, value));

  FutureEither<bool> setStringList(String key, List<String> value) async =>
      runTask(() => _prefs.setStringList(key, value));

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  bool containsKey(String key) => _prefs.containsKey(key);

  FutureEither<bool> remove(String key) async =>
      runTask(() => _prefs.remove(key));

  FutureEither<bool> clear() async => runTask(() => _prefs.clear());
}
