import 'dart:ui';

import '../../domain/astro/projection.dart';
import '../../domain/models/deep_sky_object.dart';
import '../../domain/models/sky_object.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/solar_system.dart';
import '../../domain/models/star.dart';
import '../sky/solar_system_provider.dart';

/// Finds the celestial object (star, DSO, or solar system) nearest to the tap/click position.
///
/// Within the screen distance [thresholdPx], returns the object with the lowest score,
/// where a magnitude bonus (1.5px per magnitude difference, about 6% of the threshold)
/// is added to the distance.
SkyObject? pickObjectAtPoint({
  required List<Star> stars,
  required List<DeepSkyObject> dsos,
  required List<SolarBodyPosition> solarBodies,
  required ViewProjection projection,
  required Offset point,
  double thresholdPx = 24.0,
}) {
  SkyObject? best;
  var bestScore = double.infinity;

  void consider(SkyObject object, SkyPoint position, double magnitude) {
    final screen = projection.project(position);
    if (screen == null) return;
    final distance = (screen - point).distance;
    if (distance > thresholdPx) return;
    final score = distance + magnitude * 1.5;
    if (score < bestScore) {
      bestScore = score;
      best = object;
    }
  }

  for (final solar in solarBodies) {
    consider(
      SolarBodyObject(solar.body),
      solar.position,
      solar.body.representativeMagnitude,
    );
  }
  for (final dso in dsos) {
    consider(
      DsoObject(dso),
      SkyPoint(dso.raDeg, dso.decDeg),
      dso.magnitude ?? 12.0,
    );
  }
  for (final star in stars) {
    consider(
      StarObject(star),
      SkyPoint(star.raDeg, star.decDeg),
      star.magnitude,
    );
  }
  return best;
}
