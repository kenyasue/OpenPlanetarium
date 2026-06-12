import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/spatial/healpix.dart';

void main() {
  group('Healpix.ang2pixNest', () {
    test('at order 0 the whole sky splits into 12 tiles', () {
      final pixels = <int>{};
      for (var ra = 0.0; ra < 360.0; ra += 5.0) {
        for (var dec = -87.5; dec <= 87.5; dec += 5.0) {
          final pix = Healpix.ang2pixNest(0, ra, dec);
          expect(pix, inInclusiveRange(0, 11));
          pixels.add(pix);
        }
      }
      expect(pixels, hasLength(12));
    });

    test('all-sky samples map to valid tile indices (order 3)', () {
      for (var ra = 0.0; ra < 360.0; ra += 11.3) {
        for (var dec = -89.0; dec <= 89.0; dec += 7.1) {
          final pix = Healpix.ang2pixNest(3, ra, dec);
          expect(pix, inInclusiveRange(0, Healpix.npix(3) - 1));
        }
      }
    });
  });

  group('Healpix.pixCenter / pixBoundary (round-trip consistency)', () {
    test('tile centers map back to their own tile (samples for orders 0-6)', () {
      for (var order = 0; order <= 6; order++) {
        final total = Healpix.npix(order);
        // Too many tiles at high orders, so verify a thinned-out subset
        final step = (total / 48).ceil();
        for (var pix = 0; pix < total; pix += step) {
          final center = Healpix.pixCenter(order, pix);
          expect(
            Healpix.ang2pixNest(order, center.raDeg, center.decDeg),
            pix,
            reason: 'order=$order pix=$pix center=$center',
          );
        }
      }
    });

    test('boundary points lie within a reasonable angular distance of the tile center', () {
      const order = 4;
      final tileRadiusDeg = 58.6 / (1 << order) * 1.5; // conservative upper bound
      for (var pix = 0; pix < Healpix.npix(order); pix += 37) {
        final center = Healpix.pixCenter(order, pix);
        for (final corner in Healpix.pixBoundary(order, pix)) {
          expect(
            center.angularDistanceTo(corner),
            lessThan(tileRadiusDeg),
            reason: 'order=$order pix=$pix',
          );
        }
      }
    });

    test('boundary point count is steps×4', () {
      expect(Healpix.pixBoundary(2, 5), hasLength(4));
      expect(Healpix.pixBoundary(2, 5, steps: 3), hasLength(12));
    });
  });

  group('Healpix.ancestor', () {
    test('child tile centers fall within the ancestor tile', () {
      const order = 6;
      const ancestorOrder = 3;
      for (var pix = 100; pix < Healpix.npix(order); pix += 997) {
        final (ancestorPix, _, _, _) = Healpix.ancestor(
          order,
          pix,
          ancestorOrder,
        );
        final center = Healpix.pixCenter(order, pix);
        expect(
          Healpix.ang2pixNest(ancestorOrder, center.raDeg, center.decDeg),
          ancestorPix,
          reason: 'pix=$pix',
        );
      }
    });

    test('grid position is within the sub-quadrant range', () {
      final (_, subX, subY, gridSize) = Healpix.ancestor(5, 12345, 3);
      expect(gridSize, 4);
      expect(subX, inInclusiveRange(0, 3));
      expect(subY, inInclusiveRange(0, 3));
    });

    test('returns itself at the same order', () {
      final (ancestorPix, subX, subY, gridSize) = Healpix.ancestor(4, 777, 4);
      expect(ancestorPix, 777);
      expect((subX, subY, gridSize), (0, 0, 1));
    });
  });

  group('chooseHipsOrder', () {
    test('higher resolution (zoomed in) raises the order', () {
      final wide = chooseHipsOrder(720 / 90); // wide FOV: 8px/°
      final narrow = chooseHipsOrder(720 / 2); // narrow FOV: 360px/°
      expect(narrow, greaterThan(wide));
    });

    test('is clamped to the valid range', () {
      expect(chooseHipsOrder(0.01), 0);
      expect(chooseHipsOrder(1e9, maxOrder: 9), 9);
    });
  });
}
