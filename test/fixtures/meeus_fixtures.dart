import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';

/// Fixtures based on the worked examples in Meeus "Astronomical Algorithms" 2nd ed.
///
/// These are known values with explicit sources, used as the reference for
/// AstroEngine accuracy verification
/// (docs/development-guidelines.md test strategy).
class MeeusFixtures {
  /// Example 12.b: 1987-04-10 19:21:00 UT
  static final example12bUtc = DateTime.utc(1987, 4, 10, 19, 21, 0);

  /// Example 12.b: Julian date for the time above
  static const example12bJd = 2446896.30625;

  /// Example 12.b: Greenwich mean sidereal time 8h34m57.0896s = 128.737873°
  static const example12bGmstDeg = 128.737873;

  /// Example 12.a: GMST at 1987-04-10 0h UT, 13h10m46.3668s = 197.693195°
  static final example12aUtc = DateTime.utc(1987, 4, 10);
  static const example12aGmstDeg = 197.693195;

  /// Example 13.b: apparent position of Venus (1987-04-10 19:21:00 UT)
  /// α = 23h09m16.641s, δ = -6°43'11.61"
  static final venusApparent = SkyPoint(
    (23 + 9 / 60.0 + 16.641 / 3600.0) * 15.0, // 347.319288°
    -(6 + 43 / 60.0 + 11.61 / 3600.0), // -6.719892°
  );

  /// Example 13.b: observing site = U.S. Naval Observatory (Washington)
  /// Longitude 77°03'56" W (negative in east-longitude convention), latitude 38°55'17" N
  static const usno = GeoLocation(
    latitudeDeg: 38 + 55 / 60.0 + 17 / 3600.0,
    longitudeDeg: -(77 + 3 / 60.0 + 56 / 3600.0),
    name: 'USNO',
  );

  /// Example 13.b: expected horizontal coordinates
  /// Meeus original: A = 68.0337° (measured westward from south) → 248.0337° measured eastward from north
  /// h = 15.1249°
  static const venusExpectedAzNorthDeg = 248.0337;
  static const venusExpectedAltDeg = 15.1249;

  /// Tolerance [deg]: 0.1° because the implementation omits nutation and parallax
  static const toleranceDeg = 0.1;
}
