import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/astro/ephemeris_engine.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/solar_system.dart';
import '../time/time_controller.dart';

/// DI point for EphemerisEngine
final ephemerisEngineProvider = Provider<EphemerisEngine>(
  (ref) => const EphemerisEngine(),
);

/// Display snapshot of a solar system body
class SolarBodyPosition {
  const SolarBodyPosition({
    required this.body,
    required this.position,
    required this.angularDiameterDeg,
  });

  final SolarBodyId body;

  /// Geocentric apparent position (RA/Dec)
  final SkyPoint position;

  /// Apparent diameter [degrees] (0 for planets, treated as points)
  final double angularDiameterDeg;
}

/// Positions of the 9 solar system bodies tied to the observation time (F7).
///
/// Recomputed whenever the time changes via the time slider or diurnal motion playback
/// (Kepler/series computation for 9 bodies takes under 1ms — negligible).
final solarSystemProvider = Provider<List<SolarBodyPosition>>((ref) {
  final time = ref.watch(timeControllerProvider);
  final engine = ref.watch(ephemerisEngineProvider);

  return [
    for (final body in SolarBodyId.values)
      SolarBodyPosition(
        body: body,
        position: engine.position(body, time),
        angularDiameterDeg: switch (body) {
          SolarBodyId.sun => 0.533,
          // Moon's apparent diameter: 2 asin(lunar radius 1737.4km / distance) ≈ 3475/dist [rad]
          SolarBodyId.moon =>
            3475.0 / engine.moonDistanceKm(time) * 180.0 / 3.14159265,
          _ => 0.0,
        },
      ),
  ];
});

/// Moon phase (used for the lunar age display in the bottom bar and rendering the moon's phases)
final moonPhaseProvider = Provider<MoonPhase>((ref) {
  final time = ref.watch(timeControllerProvider);
  return ref.watch(ephemerisEngineProvider).moonPhase(time);
});
