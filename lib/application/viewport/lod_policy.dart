import 'dart:math' as math;

import '../../domain/appearance/star_appearance.dart';

/// LOD cap mapping zoom level (field of view) to limiting magnitude (functional design A2).
///
/// A performance guard that limits data volume at wide fields of view. The user-configured
/// display limiting magnitude ("show stars down to mag N", max 20) is applied as a further cap.
double lodLimitingMagnitude(double fovDeg) {
  if (fovDeg > 60) return 8.0;
  if (fovDeg > 20) return 10.5;
  if (fovDeg > 5) return 14.0;
  return 20.0;
}

/// Effective limiting magnitude = min(LOD cap, user-configured display limiting magnitude)
double effectiveLimitingMagnitude(double fovDeg, AppearanceSettings settings) {
  return math.min(lodLimitingMagnitude(fovDeg), settings.userLimitingMagnitude);
}
