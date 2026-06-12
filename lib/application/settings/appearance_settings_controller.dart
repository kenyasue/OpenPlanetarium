import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/appearance/star_appearance.dart';
import 'settings_persistence.dart';

/// Controller managing star appearance settings (F5). Persisted.
class AppearanceSettingsController extends Notifier<AppearanceSettings> {
  static const _key = 'settings.appearance';

  @override
  AppearanceSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    // Prevent delayed writes to a disposed provider
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          state = _fromJson(jsonDecode(value) as Map<String, dynamic>);
        } on FormatException {
          // Continue with defaults if the settings are corrupted (settings must not break the app)
        }
      }),
    );
    return const AppearanceSettings();
  }

  void _save() {
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(_key, jsonEncode(_toJson(state))),
    );
  }

  /// Sets the display limiting magnitude ("show stars down to mag N")
  void setLimitingMagnitude(double magnitude) {
    state = state.copyWith(
      userLimitingMagnitude: magnitude.clamp(
        AppearanceSettings.minLimitingMagnitude,
        AppearanceSettings.maxLimitingMagnitude,
      ),
    );
    _save();
  }

  void setSizeScale(double scale) {
    state = state.copyWith(sizeScale: scale.clamp(0.3, 3.0));
    _save();
  }

  void setGlowIntensity(double intensity) {
    state = state.copyWith(glowIntensity: intensity.clamp(0.0, 3.0));
    _save();
  }

  void setSaturation(double saturation) {
    state = state.copyWith(saturation: saturation.clamp(0.0, 2.0));
    _save();
  }

  void setShowMilkyWay(bool show) {
    state = state.copyWith(showMilkyWay: show);
    _save();
  }

  static Map<String, dynamic> _toJson(AppearanceSettings s) => {
    'sizeScale': s.sizeScale,
    'glowIntensity': s.glowIntensity,
    'saturation': s.saturation,
    'userLimitingMagnitude': s.userLimitingMagnitude,
    'showMilkyWay': s.showMilkyWay,
  };

  static AppearanceSettings _fromJson(Map<String, dynamic> json) {
    // The legacy 'bortle' key is discarded (consolidated into the display limiting magnitude)
    return AppearanceSettings(
      sizeScale: (json['sizeScale'] as num?)?.toDouble() ?? 1.0,
      glowIntensity: (json['glowIntensity'] as num?)?.toDouble() ?? 1.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
      userLimitingMagnitude:
          (json['userLimitingMagnitude'] as num?)?.toDouble() ?? 6.5,
      showMilkyWay: json['showMilkyWay'] as bool? ?? true,
    );
  }
}

final appearanceSettingsProvider =
    NotifierProvider<AppearanceSettingsController, AppearanceSettings>(
      AppearanceSettingsController.new,
    );
