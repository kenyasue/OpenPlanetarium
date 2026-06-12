import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_persistence.dart';

/// Display settings for solar system bodies (F7 extension).
///
/// The Sun and Moon remain visible even when planets are turned off (they are basic elements of the sky).
class SolarSystemSettings {
  const SolarSystemSettings({
    this.showPlanets = true,
    this.showAsteroids = true,
    this.showComets = true,
  });

  final bool showPlanets;
  final bool showAsteroids;
  final bool showComets;

  SolarSystemSettings copyWith({
    bool? showPlanets,
    bool? showAsteroids,
    bool? showComets,
  }) {
    return SolarSystemSettings(
      showPlanets: showPlanets ?? this.showPlanets,
      showAsteroids: showAsteroids ?? this.showAsteroids,
      showComets: showComets ?? this.showComets,
    );
  }
}

/// Controller managing solar system display settings. Persisted.
class SolarSystemSettingsController extends Notifier<SolarSystemSettings> {
  static const _key = 'settings.solarSystem';

  @override
  SolarSystemSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          state = SolarSystemSettings(
            showPlanets: json['showPlanets'] as bool? ?? true,
            showAsteroids: json['showAsteroids'] as bool? ?? true,
            showComets: json['showComets'] as bool? ?? true,
          );
        } on FormatException {
          // Continue with defaults if the settings are corrupted
        }
      }),
    );
    return const SolarSystemSettings();
  }

  void setShowPlanets(bool show) => _update(state.copyWith(showPlanets: show));

  void setShowAsteroids(bool show) =>
      _update(state.copyWith(showAsteroids: show));

  void setShowComets(bool show) => _update(state.copyWith(showComets: show));

  void _update(SolarSystemSettings next) {
    state = next;
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(
            _key,
            jsonEncode({
              'showPlanets': next.showPlanets,
              'showAsteroids': next.showAsteroids,
              'showComets': next.showComets,
            }),
          ),
    );
  }
}

final solarSystemSettingsProvider =
    NotifierProvider<SolarSystemSettingsController, SolarSystemSettings>(
      SolarSystemSettingsController.new,
    );
