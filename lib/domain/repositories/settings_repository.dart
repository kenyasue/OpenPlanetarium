/// Settings persistence interface (implemented in the data layer).
///
/// Values are stored as JSON strings. On read/write failure the caller falls
/// back to defaults (the app starts even if settings are corrupted).
abstract class SettingsRepository {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}
