import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/astro/ephemeris_engine.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';
import 'package:open_planetarium/domain/models/solar_system.dart';

void main() {
  const engine = EphemerisEngine();

  group('Sun position', () {
    test('Meeus example 25.a: apparent Sun position at 1992-10-13 0h TD (±0.05°)', () {
      // TD-UT difference (ΔT≈59s) is below the accuracy requirement, so approximate with UTC
      final pos = engine.position(SolarBodyId.sun, DateTime.utc(1992, 10, 13));
      // Expected: apparent RA 198.38082° / apparent Dec -7.78507° (from Meeus)
      expect(pos.raDeg, closeTo(198.38082, 0.05));
      expect(pos.decDeg, closeTo(-7.78507, 0.05));
    });

    test('around the vernal equinox (March 20) the Sun is near RA≈0°', () {
      final pos = engine.position(
        SolarBodyId.sun,
        DateTime.utc(2026, 3, 20, 12),
      );
      final distToZero = pos.raDeg > 180 ? 360 - pos.raDeg : pos.raDeg;
      expect(distToZero, lessThan(1.0));
    });
  });

  group('Moon position', () {
    test('Meeus example 47.a: Moon position at 1992-04-12 0h TD (±0.3°)', () {
      final pos = engine.position(SolarBodyId.moon, DateTime.utc(1992, 4, 12));
      // Expected: apparent RA 134.688470° / apparent Dec 13.768368° (from Meeus, including nutation)
      expect(pos.raDeg, closeTo(134.688470, 0.3));
      expect(pos.decDeg, closeTo(13.768368, 0.3));
    });

    test('Moon distance stays in the realistic Earth-Moon range (356,000-407,000 km)', () {
      for (var day = 0; day < 30; day += 3) {
        final dist = engine.moonDistanceKm(
          DateTime.utc(2026, 6, 1).add(Duration(days: day)),
        );
        expect(dist, inInclusiveRange(350000, 410000));
      }
    });
  });

  group('Planet positions', () {
    test('Meeus example 33.a: Venus at 1992-12-20 0h TD (±0.3°)', () {
      final pos = engine.position(
        SolarBodyId.venus,
        DateTime.utc(1992, 12, 20),
      );
      // Expected: apparent RA 316.17291° / apparent Dec -18.88801° (from Meeus, including aberration)
      // This implementation omits aberration, so the tolerance is set to 0.3°
      expect(pos.raDeg, closeTo(316.17291, 0.3));
      expect(pos.decDeg, closeTo(-18.88801, 0.3));
    });

    test('all planets have realistic ecliptic latitude (|β|<9°) (near-ecliptic invariant)', () {
      const planets = [
        SolarBodyId.mercury,
        SolarBodyId.venus,
        SolarBodyId.mars,
        SolarBodyId.jupiter,
        SolarBodyId.saturn,
        SolarBodyId.uranus,
        SolarBodyId.neptune,
      ];
      for (var month = 1; month <= 12; month += 2) {
        final utc = DateTime.utc(2026, month, 15);
        final sun = engine.position(SolarBodyId.sun, utc);
        for (final planet in planets) {
          final pos = engine.position(planet, utc);
          // Proxy for separation from the ecliptic: Dec within obliquity + 9°
          expect(
            pos.decDeg.abs(),
            lessThan(23.5 + 9.0),
            reason: '$planet month $month',
          );
          expect(pos.raDeg, inInclusiveRange(0, 360));
          // Also confirm the Sun position is valid
          expect(sun.raDeg, inInclusiveRange(0, 360));
        }
      }
    });

    test('inner planet elongation from the Sun stays below maximum (Mercury<28.5°, Venus<48°)', () {
      for (var month = 1; month <= 12; month++) {
        final utc = DateTime.utc(2026, month, 1);
        final sun = engine.position(SolarBodyId.sun, utc);
        final mercury = engine.position(SolarBodyId.mercury, utc);
        final venus = engine.position(SolarBodyId.venus, utc);
        expect(
          sun.angularDistanceTo(mercury),
          lessThan(28.5),
          reason: 'Mercury month $month',
        );
        expect(
          sun.angularDistanceTo(venus),
          lessThan(48.0),
          reason: 'Venus month $month',
        );
      }
    });
  });

  group('moonPhase', () {
    test('illuminated fraction is 0-1 and lunar age is within 0 to one synodic month', () {
      for (var day = 0; day < 30; day++) {
        final phase = engine.moonPhase(
          DateTime.utc(2026, 6, 1).add(Duration(days: day)),
        );
        expect(phase.illuminatedFraction, inInclusiveRange(0, 1));
        expect(
          phase.ageDays,
          inInclusiveRange(0, EphemerisEngine.synodicMonthDays),
        );
      }
    });

    test('near age 0 is new moon (fraction≈0), near age 15 is full moon (fraction≈1)', () {
      // Scan one month and check the illuminated fraction near minimum/maximum lunar age
      MoonPhase? newMoon, fullMoon;
      for (var hour = 0; hour < 24 * 30; hour += 6) {
        final phase = engine.moonPhase(
          DateTime.utc(2026, 6, 1).add(Duration(hours: hour)),
        );
        if (newMoon == null || phase.ageDays < newMoon.ageDays) {
          newMoon = phase;
        }
        if (fullMoon == null ||
            (phase.ageDays - EphemerisEngine.synodicMonthDays / 2).abs() <
                (fullMoon.ageDays - EphemerisEngine.synodicMonthDays / 2)
                    .abs()) {
          fullMoon = phase;
        }
      }
      expect(newMoon!.illuminatedFraction, lessThan(0.05));
      expect(fullMoon!.illuminatedFraction, greaterThan(0.95));
    });
  });

  group('riseSetTimes', () {
    test('at Sirius transit time in Tokyo the azimuth is nearly due south', () {
      const astro = AstroEngine();
      final sirius = SkyPoint(101.2872, -16.7161);
      final times = engine.riseSetTimes(
        sirius,
        GeoLocation.tokyo,
        DateTime(2026, 1, 15),
      );
      expect(times.transit, isNotNull);
      final hor = astro.equatorialToHorizontal(
        sirius,
        GeoLocation.tokyo,
        times.transit!.toUtc(),
      );
      expect(hor.azDeg, closeTo(180.0, 2.0));
    });

    test('altitude at rise/set times is close to the rise/set criterion (-0.5667°)', () {
      const astro = AstroEngine();
      final sirius = SkyPoint(101.2872, -16.7161);
      final times = engine.riseSetTimes(
        sirius,
        GeoLocation.tokyo,
        DateTime(2026, 1, 15),
      );
      for (final t in [times.rise, times.set]) {
        expect(t, isNotNull);
        final hor = astro.equatorialToHorizontal(
          sirius,
          GeoLocation.tokyo,
          t!.toUtc(),
        );
        expect(hor.altDeg, closeTo(-0.5667, 0.5));
      }
    });

    test('Polaris is circumpolar (never sets) in Tokyo', () {
      final polaris = SkyPoint(37.95, 89.26);
      final times = engine.riseSetTimes(
        polaris,
        GeoLocation.tokyo,
        DateTime(2026, 6, 11),
      );
      expect(times.circumpolar, isTrue);
      expect(times.rise, isNull);
      expect(times.transit, isNotNull);
    });

    test('objects near the south celestial pole never rise in Tokyo', () {
      final southern = SkyPoint(100, -85);
      final times = engine.riseSetTimes(
        southern,
        GeoLocation.tokyo,
        DateTime(2026, 6, 11),
      );
      expect(times.neverRises, isTrue);
    });
  });
}
