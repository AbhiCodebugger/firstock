abstract class ThemeRepository {
  Future<String?> loadMode();

  Future<void> saveMode(String mode);
}
