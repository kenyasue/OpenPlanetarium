import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/asset_minor_body_repository.dart';
import '../../domain/models/minor_body.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/repositories/minor_body_repository.dart';
import '../settings/solar_system_settings_controller.dart';
import '../time/time_controller.dart';
import 'solar_system_provider.dart';

/// Limiting magnitude for minor bodies to display.
///
/// Asteroids are rendered down to mag 12 because their magnitude formula is conservative
/// (no phase correction); comets, being faint and diffuse, are rendered down to mag 13.
const double kAsteroidDisplayLimitMag = 12.0;
const double kCometDisplayLimitMag = 13.0;

/// DI point for the minor body repository
final minorBodyRepositoryProvider = Provider<MinorBodyRepository>(
  (ref) => AssetMinorBodyRepository(),
);

/// All minor bodies (loaded once at startup)
final minorBodyListProvider = FutureProvider<List<MinorBody>>(
  (ref) => ref.watch(minorBodyRepositoryProvider).loadAll(),
);

/// Display snapshot of a minor body
class MinorBodyPosition {
  const MinorBodyPosition({
    required this.body,
    required this.position,
    required this.magnitude,
  });

  final MinorBody body;
  final SkyPoint position;
  final double magnitude;
}

/// Minor bodies to display, with position and magnitude computed for the observation time (F7 extension).
///
/// Kepler propagation takes under 1ms for about 250 bodies, so recomputing on
/// every time tick is fine (tracks the time slider and diurnal playback).
final visibleMinorBodiesProvider = Provider<List<MinorBodyPosition>>((ref) {
  final settings = ref.watch(solarSystemSettingsProvider);
  if (!settings.showAsteroids && !settings.showComets) return const [];

  final bodies = ref.watch(minorBodyListProvider).value ?? const <MinorBody>[];
  final time = ref.watch(timeControllerProvider);
  final engine = ref.watch(ephemerisEngineProvider);

  final result = <MinorBodyPosition>[];
  for (final body in bodies) {
    final show = switch (body.kind) {
      MinorBodyKind.asteroid => settings.showAsteroids,
      MinorBodyKind.comet => settings.showComets,
    };
    if (!show) continue;

    final geo = engine.minorBodyGeocentric(body.elements, time);
    final magnitude = body.magnitudeAt(rAu: geo.rAu, deltaAu: geo.deltaAu);
    final limit = switch (body.kind) {
      MinorBodyKind.asteroid => kAsteroidDisplayLimitMag,
      MinorBodyKind.comet => kCometDisplayLimitMag,
    };
    if (magnitude > limit) continue;

    result.add(
      MinorBodyPosition(
        body: body,
        position: geo.position,
        magnitude: magnitude,
      ),
    );
  }
  return result;
});
