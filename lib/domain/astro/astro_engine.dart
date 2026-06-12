import 'dart:math' as math;

import '../models/geo_location.dart';
import '../models/horizontal_coord.dart';
import '../models/sky_point.dart';

/// Astronomical computation engine (pure computation, no I/O dependencies).
///
/// Accuracy policy: for visual display purposes, nutation, atmospheric
/// refraction, and proper motion are not applied
/// (within ±0.1° against Meeus worked examples; see docs/functional-design.md).
class AstroEngine {
  const AstroEngine();

  static const double _d2r = math.pi / 180.0;
  static const double _r2d = 180.0 / math.pi;

  /// Computes the Julian date (JD).
  ///
  /// Meeus "Astronomical Algorithms" 2nd ed., eq. (7.1).
  /// [utc] must be UTC (isUtc required).
  double julianDate(DateTime utc) {
    assert(utc.isUtc, 'julianDate requires UTC DateTime');
    var y = utc.year;
    var m = utc.month;
    final dayFraction =
        (utc.hour +
            utc.minute / 60.0 +
            (utc.second + utc.millisecond / 1000.0) / 3600.0) /
        24.0;
    final d = utc.day + dayFraction;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor(); // Gregorian calendar
    return (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        d +
        b -
        1524.5;
  }

  /// Greenwich mean sidereal time [deg] [0, 360).
  ///
  /// Meeus eq. (12.4): GMST at any instant.
  double gmstDeg(DateTime utc) {
    final jd = julianDate(utc);
    final t = (jd - 2451545.0) / 36525.0;
    final theta =
        280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    return SkyPoint.normalizeRa(theta);
  }

  /// Local sidereal time [deg] [0, 360). Longitude is east-positive (opposite sign of Meeus's west-positive).
  double lstDeg(DateTime utc, double longitudeDeg) =>
      SkyPoint.normalizeRa(gmstDeg(utc) + longitudeDeg);

  /// Equatorial coordinates → horizontal coordinates.
  ///
  /// Meeus eqs. (13.5) and (13.6). Meeus's azimuth is south-based, measured
  /// westward, so it is converted by +180° to north-based, measured eastward
  /// (glossary convention) before returning.
  HorizontalCoord equatorialToHorizontal(
    SkyPoint radec,
    GeoLocation loc,
    DateTime utc,
  ) {
    final lst = lstDeg(utc, loc.longitudeDeg);
    final h = (lst - radec.raDeg) * _d2r; // Hour angle
    final phi = loc.latitudeDeg * _d2r;
    final dec = radec.decDeg * _d2r;

    final sinAlt =
        math.sin(phi) * math.sin(dec) +
        math.cos(phi) * math.cos(dec) * math.cos(h);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));

    // South-based azimuth, measured westward (Meeus 13.5)
    final azSouth = math.atan2(
      math.sin(h),
      math.cos(h) * math.sin(phi) - math.tan(dec) * math.cos(phi),
    );
    final azNorth = SkyPoint.normalizeRa(azSouth * _r2d + 180.0);

    return HorizontalCoord(altDeg: alt * _r2d, azDeg: azNorth);
  }

  /// Horizontal coordinates → equatorial coordinates (inverse of equatorialToHorizontal).
  SkyPoint horizontalToEquatorial(
    HorizontalCoord horizontal,
    GeoLocation loc,
    DateTime utc,
  ) {
    final lst = lstDeg(utc, loc.longitudeDeg);
    final phi = loc.latitudeDeg * _d2r;
    final alt = horizontal.altDeg * _d2r;
    // Convert back to south-based, measured westward
    final azSouth = (horizontal.azDeg - 180.0) * _d2r;

    final sinDec =
        math.sin(phi) * math.sin(alt) -
        math.cos(phi) * math.cos(alt) * math.cos(azSouth);
    final dec = math.asin(sinDec.clamp(-1.0, 1.0));

    final h = math.atan2(
      math.sin(azSouth),
      math.cos(azSouth) * math.sin(phi) + math.tan(alt) * math.cos(phi),
    );

    final ra = SkyPoint.normalizeRa(lst - h * _r2d);
    return SkyPoint(ra, dec * _r2d);
  }
}
