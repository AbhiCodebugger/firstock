import '../../../services/storage_service.dart';
import '../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._storage);

  static const String key = 'theme_mode';

  final StorageService _storage;

  @override
  Future<String?> loadMode() async {
    return _storage.getString(key);
  }

  @override
  Future<void> saveMode(String mode) async {
    await _storage.setString(key, mode);
  }
}
