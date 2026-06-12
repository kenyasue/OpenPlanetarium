import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/settings_repository.dart';

/// Settings persistence backed by shared_preferences.
class PrefsSettingsRepository implements SettingsRepository {
  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> _instance() =>
      _prefs ??= SharedPreferences.getInstance();

  @override
  Future<String?> read(String key) async => (await _instance()).getString(key);

  @override
  Future<void> write(String key, String value) async {
    await (await _instance()).setString(key, value);
  }
}

/// In-memory implementation for tests.
class InMemorySettingsRepository implements SettingsRepository {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
