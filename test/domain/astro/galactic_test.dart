import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/galactic.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';

void main() {
  group('Galactic.toEquatorial', () {
    test('galactic center (l=0, b=0) points toward Sagittarius, RA≈266.40°/Dec≈-28.94°', () {
      final center = Galactic.toEquatorial(0, 0);
      expect(center.raDeg, closeTo(266.405, 0.05));
      expect(center.decDeg, closeTo(-28.936, 0.05));
    });

    test('north galactic pole (b=90) is RA≈192.86°/Dec≈27.13° by definition', () {
      final ngp = Galactic.toEquatorial(0, 90);
      expect(ngp.decDeg, closeTo(27.128, 0.01));
      expect(ngp.raDeg, closeTo(192.859, 0.05));
    });

    test('points on the galactic plane (b=0) are 90° from the north galactic pole', () {
      final ngp = Galactic.toEquatorial(0, 90);
      for (var l = 0.0; l < 360.0; l += 45.0) {
        final point = Galactic.toEquatorial(l, 0);
        expect(
          point.angularDistanceTo(ngp),
          closeTo(90.0, 0.01),
          reason: 'l=$l',
        );
      }
    });

    test('Deneb in Cygnus (l≈84°, b≈2°) lies near the galactic plane', () {
      // Deneb: RA 310.36°, Dec 45.28° (famous star on the galactic plane)
      final deneb = SkyPoint(310.36, 45.28);
      var minDist = 180.0;
      for (var l = 0.0; l < 360.0; l += 1.0) {
        final point = Galactic.toEquatorial(l, 0);
        final dist = point.angularDistanceTo(deneb);
        if (dist < minDist) minDist = dist;
      }
      expect(minDist, lessThan(3.0)); // about 2° from the galactic plane
    });
  });
}
