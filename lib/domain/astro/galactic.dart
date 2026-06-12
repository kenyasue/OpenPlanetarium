import 'dart:math' as math;

import '../models/sky_point.dart';

/// Conversion from galactic to equatorial (J2000) coordinates.
///
/// Constants are the J2000 values of the IAU 1958 galactic coordinate system:
/// north galactic pole αG=192.85948°, δG=27.12825°, galactic longitude of the
/// north celestial pole lNCP=122.93192°
/// (Perryman & ESA 1997, Hipparcos Catalogue Vol.1 §1.5.3).
class Galactic {
  const Galactic._();

  static const _d2r = math.pi / 180.0;
  static const _r2d = 180.0 / math.pi;

  static const _alphaG = 192.85948 * _d2r;
  static const _deltaG = 27.12825 * _d2r;
  static const _lNcp = 122.93192 * _d2r;

  /// Galactic longitude l and latitude b [deg] → equatorial coordinates (J2000)
  static SkyPoint toEquatorial(double lDeg, double bDeg) {
    final l = lDeg * _d2r;
    final b = bDeg * _d2r;
    final dl = _lNcp - l;

    final sinDec =
        math.sin(_deltaG) * math.sin(b) +
        math.cos(_deltaG) * math.cos(b) * math.cos(dl);
    final dec = math.asin(sinDec.clamp(-1.0, 1.0));

    final ra =
        _alphaG +
        math.atan2(
          math.cos(b) * math.sin(dl),
          math.sin(b) * math.cos(_deltaG) -
              math.cos(b) * math.sin(_deltaG) * math.cos(dl),
        );

    return SkyPoint(ra * _r2d, dec * _r2d);
  }
}
