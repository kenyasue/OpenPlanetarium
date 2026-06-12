import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings/prefs_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';

/// DI point for settings persistence (replaced with InMemory in tests)
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => PrefsSettingsRepository(),
);
