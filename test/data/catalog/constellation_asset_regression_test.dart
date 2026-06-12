import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/asset_constellation_repository.dart';
import 'package:open_planetarium/domain/models/constellation_data.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';

/// Regression checks for the generated asset (assets/catalogs/constellations.json).
/// Guards the conversion script output quality (counts, names, coordinate ranges,
/// and the shapes of representative constellations).
void main() {
  group('constellations.json (generated asset)', () {
    late final ConstellationSet set;

    setUpAll(() async {
      final repo = AssetConstellationRepository(
        loader: (_) =>
            File('assets/catalogs/constellations.json').readAsString(),
      );
      set = await repo.load();
    });

    test('all 88 constellations are included and every name is non-empty', () {
      expect(set.constellations, hasLength(88));
      for (final c in set.constellations) {
        expect(c.nameLatin, isNotEmpty, reason: c.iau);
        expect(c.nameEn, isNotEmpty, reason: c.iau);
        expect(c.nameJa, isNotEmpty, reason: c.iau);
        expect(c.nameJa, isNot(c.nameLatin), reason: '${c.iau} Japanese name not translated');
        expect(c.lines, isNotEmpty, reason: c.iau);
      }
    });

    test('all coordinates are in the normalized range (RA [0,360), Dec [-90,90])', () {
      void check(SkyPoint p) {
        expect(p.raDeg, inInclusiveRange(0, 360));
        expect(p.decDeg, inInclusiveRange(-90, 90));
      }

      for (final c in set.constellations) {
        check(c.labelAnchor);
        for (final line in c.lines) {
          line.forEach(check);
        }
      }
      for (final boundary in set.boundaries) {
        boundary.forEach(check);
      }
    });

    test('Orion lines include vertices near Betelgeuse and Rigel', () {
      final orion = set.constellations.firstWhere((c) => c.iau == 'Ori');
      final betelgeuse = SkyPoint(88.79, 7.41);
      final rigel = SkyPoint(78.63, -8.20);

      bool hasVertexNear(SkyPoint target) {
        for (final line in orion.lines) {
          for (final p in line) {
            if (p.angularDistanceTo(target) < 0.5) return true;
          }
        }
        return false;
      }

      expect(hasVertexNear(betelgeuse), isTrue, reason: 'Betelgeuse not found');
      expect(hasVertexNear(rigel), isTrue, reason: 'Rigel not found');
    });

    test('boundary polylines exist and precession did not produce extreme coordinates', () {
      expect(set.boundaries.length, greaterThan(700)); // IAU boundaries have 781 edges
      // B1875→J2000 precession is at most about 2°. Roughly confirm that boundaries
      // near Crux exist (approximately RA 175-190°, Dec -55 to -65°)
      final hasCruxRegion = set.boundaries.any(
        (b) => b.any(
          (p) =>
              p.decDeg < -55 &&
              p.decDeg > -65 &&
              p.raDeg > 170 &&
              p.raDeg < 195,
        ),
      );
      expect(hasCruxRegion, isTrue);
    });
  });
}
