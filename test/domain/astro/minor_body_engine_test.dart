import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/ephemeris_engine.dart';
import 'package:open_planetarium/domain/models/minor_body.dart';
import 'package:open_planetarium/domain/models/solar_system.dart';

void main() {
  const engine = EphemerisEngine();

  /// Standish Mars elements (J2000 epoch) converted to minor-body orbital element form.
  /// a=1.52371034, e=0.09339410, i=1.84969142,
  /// L=-4.55343205, ϖ=-23.94362959, Ω=49.55953891
  /// → M0 = L−ϖ = 19.39019754, ω = ϖ−Ω = -73.50316850
  const marsAsOrbit = OrbitalElements(
    epochJd: 2451545.0, // J2000
    aAu: 1.52371034,
    e: 0.09339410,
    iDeg: 1.84969142,
    nodeDeg: 49.55953891,
    argPeriDeg: -73.50316850,
    meanAnomalyDeg: 19.39019754,
  );

  group('EphemerisEngine.minorBodyGeocentric', () {
    test('matches existing Mars position calculation at J2000 epoch', () {
      final utc = DateTime.utc(2000, 1, 1, 12); // JD 2451545.0
      final expected = engine.position(SolarBodyId.mars, utc);
      final actual = engine.minorBodyGeocentric(marsAsOrbit, utc);
      expect(
        actual.position.angularDistanceTo(expected),
        lessThan(0.01),
        reason: 'expected=$expected actual=${actual.position}',
      );
      // Mars at J2000: heliocentric distance ~1.39 au, geocentric ~1.85 au (rough check)
      expect(actual.rAu, inInclusiveRange(1.3, 1.7));
      expect(actual.deltaAu, inInclusiveRange(0.4, 2.6));
    });

    test('stays close to Mars position 60 days after epoch via mean-motion propagation (two-body limit)', () {
      final utc = DateTime.utc(2000, 3, 1, 12);
      final expected = engine.position(SolarBodyId.mars, utc);
      final actual = engine.minorBodyGeocentric(marsAsOrbit, utc);
      // Not an exact match since Standish secular terms are excluded (display-grade accuracy)
      expect(actual.position.angularDistanceTo(expected), lessThan(0.5));
    });

    test('Kepler equation converges even for high-eccentricity orbit (e=0.97)', () {
      const halleyLike = OrbitalElements(
        epochJd: 2451545.0,
        aAu: 17.8,
        e: 0.967,
        iDeg: 162.2,
        nodeDeg: 58.4,
        argPeriDeg: 111.3,
        meanAnomalyDeg: 0.5, // just past perihelion (hardest region for convergence)
      );
      final result = engine.minorBodyGeocentric(
        halleyLike,
        DateTime.utc(2000, 1, 1, 12),
      );
      expect(result.rAu, greaterThan(0.5)); // at least perihelion distance q≈0.59 au
      expect(result.rAu, lessThan(36)); // at most aphelion distance
      expect(result.position.raDeg, inInclusiveRange(0, 360));
      expect(result.position.decDeg, inInclusiveRange(-90, 90));
    });
  });

  group('MinorBody.magnitudeAt', () {
    test('asteroid: V = H + 5log10(rΔ)', () {
      const vesta = MinorBody(
        id: '20000004',
        name: '4 Vesta',
        kind: MinorBodyKind.asteroid,
        elements: OrbitalElements(
          epochJd: 0,
          aAu: 2.36,
          e: 0.09,
          iDeg: 7.1,
          nodeDeg: 0,
          argPeriDeg: 0,
          meanAnomalyDeg: 0,
        ),
        mag1: 3.2, // H
        mag2: 0,
      );
      // Typical at opposition: r=2.3, Δ=1.3 → V ≈ 3.2 + 5log10(2.99) ≈ 5.58
      expect(
        vesta.magnitudeAt(rAu: 2.3, deltaAu: 1.3),
        closeTo(3.2 + 5.0 * 0.47567, 0.01),
      );
    });

    test('comet: m = M1 + 5log10(Δ) + 2.5·K1·log10(r)', () {
      const comet = MinorBody(
        id: '1000247',
        name: '2P/Encke',
        kind: MinorBodyKind.comet,
        elements: OrbitalElements(
          epochJd: 0,
          aAu: 2.22,
          e: 0.85,
          iDeg: 11.8,
          nodeDeg: 0,
          argPeriDeg: 0,
          meanAnomalyDeg: 0,
        ),
        mag1: 11.5, // M1
        mag2: 6.0, // K1
      );
      // r=1, Δ=1 → m = M1
      expect(comet.magnitudeAt(rAu: 1.0, deltaAu: 1.0), closeTo(11.5, 1e-9));
      // r=2, Δ=1 → m = 11.5 + 2.5*6*log10(2) ≈ 16.02
      expect(comet.magnitudeAt(rAu: 2.0, deltaAu: 1.0), closeTo(16.016, 0.01));
    });
  });
}
