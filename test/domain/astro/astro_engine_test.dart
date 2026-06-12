import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/horizontal_coord.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';

import '../../fixtures/meeus_fixtures.dart';

void main() {
  const engine = AstroEngine();

  group('julianDate', () {
    test('yields JD 2446896.30625 for the Meeus example 12.b time', () {
      expect(
        engine.julianDate(MeeusFixtures.example12bUtc),
        closeTo(MeeusFixtures.example12bJd, 1e-6),
      );
    });

    test('yields JD 2451545.0 at the J2000.0 epoch (2000-01-01 12:00 UT)', () {
      expect(
        engine.julianDate(DateTime.utc(2000, 1, 1, 12)),
        closeTo(2451545.0, 1e-6),
      );
    });
  });

  group('gmstDeg', () {
    test('Meeus example 12.b: GMST at 1987-04-10 19:21 UT is 128.737873°', () {
      expect(
        engine.gmstDeg(MeeusFixtures.example12bUtc),
        closeTo(MeeusFixtures.example12bGmstDeg, 0.001),
      );
    });

    test('Meeus example 12.a: GMST at 1987-04-10 0h UT is 197.693195°', () {
      expect(
        engine.gmstDeg(MeeusFixtures.example12aUtc),
        closeTo(MeeusFixtures.example12aGmstDeg, 0.001),
      );
    });

    test('returns to nearly the same GMST after 23h 56m 4s (one sidereal day)', () {
      final t0 = DateTime.utc(2026, 6, 11);
      final t1 = t0.add(const Duration(hours: 23, minutes: 56, seconds: 4));
      final diff = (engine.gmstDeg(t1) - engine.gmstDeg(t0)).abs();
      expect(diff < 0.01 || diff > 359.99, isTrue);
    });
  });

  group('lstDeg', () {
    test('at an eastern longitude LST is ahead of GMST by the longitude', () {
      final utc = MeeusFixtures.example12bUtc;
      final lst = engine.lstDeg(utc, 139.7671);
      expect(
        lst,
        closeTo(
          SkyPoint.normalizeRa(MeeusFixtures.example12bGmstDeg + 139.7671),
          0.001,
        ),
      );
    });
  });

  group('equatorialToHorizontal', () {
    test('Meeus example 13.b: Venus altitude/azimuth match within tolerance', () {
      final result = engine.equatorialToHorizontal(
        MeeusFixtures.venusApparent,
        MeeusFixtures.usno,
        MeeusFixtures.example12bUtc,
      );
      expect(
        result.altDeg,
        closeTo(MeeusFixtures.venusExpectedAltDeg, MeeusFixtures.toleranceDeg),
      );
      expect(
        result.azDeg,
        closeTo(
          MeeusFixtures.venusExpectedAzNorthDeg,
          MeeusFixtures.toleranceDeg,
        ),
      );
    });

    test('altitude of the north celestial pole (dec=+90°) equals the observer latitude', () {
      const loc = GeoLocation.tokyo;
      final result = engine.equatorialToHorizontal(
        SkyPoint(0, 90),
        loc,
        DateTime.utc(2026, 6, 11, 12),
      );
      expect(result.altDeg, closeTo(loc.latitudeDeg, 1e-6));
      expect(result.azDeg, closeTo(0.0, 0.5)); // nearly due north
    });

    test('an object at transit (hour angle 0) is due south (az=180°)', () {
      const loc = GeoLocation.tokyo;
      final utc = DateTime.utc(2026, 6, 11, 12);
      final lst = engine.lstDeg(utc, loc.longitudeDeg);
      // RA equal to LST and Dec below the latitude → transit, due south
      final result = engine.equatorialToHorizontal(SkyPoint(lst, 0), loc, utc);
      expect(result.azDeg, closeTo(180.0, 1e-6));
      expect(result.altDeg, closeTo(90.0 - loc.latitudeDeg, 1e-6));
    });
  });

  group('horizontalToEquatorial (round-trip consistency)', () {
    test('equatorial→horizontal→equatorial round trip returns the original coordinates (all-sky samples)', () {
      const loc = GeoLocation.tokyo;
      final utc = DateTime.utc(2026, 6, 11, 14, 30);
      for (var ra = 0.0; ra < 360.0; ra += 30.0) {
        for (var dec = -85.0; dec <= 85.0; dec += 17.0) {
          final original = SkyPoint(ra, dec);
          final horizontal = engine.equatorialToHorizontal(original, loc, utc);
          final back = engine.horizontalToEquatorial(horizontal, loc, utc);
          expect(
            back.angularDistanceTo(original),
            lessThan(1e-6),
            reason: 'round-trip mismatch at ra=$ra dec=$dec',
          );
        }
      }
    });

    test('round trip also matches for a southern hemisphere observer', () {
      const loc = GeoLocation(latitudeDeg: -33.87, longitudeDeg: 151.21);
      final utc = DateTime.utc(2026, 1, 15, 10);
      final original = SkyPoint(83.82, -5.39); // near the Orion Nebula
      final horizontal = engine.equatorialToHorizontal(original, loc, utc);
      final back = engine.horizontalToEquatorial(horizontal, loc, utc);
      expect(back.angularDistanceTo(original), lessThan(1e-6));
    });

    test('converting horizontal→equatorial then back returns the original horizontal coordinates', () {
      const loc = GeoLocation.tokyo;
      final utc = DateTime.utc(2026, 6, 11, 14, 30);
      const horizontal = HorizontalCoord(altDeg: 45.0, azDeg: 120.0);
      final radec = engine.horizontalToEquatorial(horizontal, loc, utc);
      final back = engine.equatorialToHorizontal(radec, loc, utc);
      expect(back.altDeg, closeTo(horizontal.altDeg, 1e-6));
      expect(back.azDeg, closeTo(horizontal.azDeg, 1e-6));
    });
  });
}
