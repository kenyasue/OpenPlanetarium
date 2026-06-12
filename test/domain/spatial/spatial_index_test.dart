import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';
import 'package:open_planetarium/domain/spatial/spatial_index.dart';

const double _aspect = 1280 / 720;

void main() {
  final index = SpatialIndex();

  List<int> tilesAt(SkyPoint center, double fovDeg) => index.tilesInViewport(
    center: center,
    fovDeg: fovDeg,
    aspectRatio: _aspect,
  );

  group('tileIndexOf', () {
    test('every all-sky sample point maps to a valid tile index', () {
      for (var ra = 0.0; ra < 360.0; ra += 7.3) {
        for (var dec = -89.9; dec <= 89.9; dec += 5.1) {
          final tile = index.tileIndexOf(ra, dec);
          expect(tile, inInclusiveRange(0, index.tileCount - 1));
        }
      }
    });

    test('tile centers map back to their own tile (round-trip consistency)', () {
      for (var tile = 0; tile < index.tileCount; tile++) {
        final center = index.tileCenter(tile);
        expect(
          index.tileIndexOf(center.raDeg, center.decDeg),
          tile,
          reason: 'tile=$tile center=$center',
        );
      }
    });

    test('RA 360° and 0° map to the same tile', () {
      expect(index.tileIndexOf(360.0, 20.0), index.tileIndexOf(0.0, 20.0));
      expect(index.tileIndexOf(-10.0, 20.0), index.tileIndexOf(350.0, 20.0));
    });

    test('poles (dec=±90°) also map to valid tiles', () {
      expect(
        index.tileIndexOf(123.0, 90.0),
        inInclusiveRange(0, index.tileCount - 1),
      );
      expect(
        index.tileIndexOf(0.0, -90.0),
        inInclusiveRange(0, index.tileCount - 1),
      );
    });
  });

  group('tilesInViewport', () {
    test('always includes the tile containing the view center', () {
      final samples = [
        SkyPoint(0, 0),
        SkyPoint(359.9, 45),
        SkyPoint(180, -60),
        SkyPoint(90, 88), // near the pole
      ];
      for (final center in samples) {
        final tiles = tilesAt(center, 60);
        final centerTile = index.tileIndexOf(center.raDeg, center.decDeg);
        expect(tiles, contains(centerTile), reason: 'center=$center');
      }
    });

    test('a view spanning the RA 0°/360° boundary includes tiles on both sides', () {
      final tiles = tilesAt(SkyPoint(0, 30), 40);
      final eastTile = index.tileIndexOf(10, 30); // RA 10° side
      final westTile = index.tileIndexOf(350, 30); // RA 350° side
      expect(tiles, contains(eastTile));
      expect(tiles, contains(westTile));
    });

    test('zooming in reduces the tile count', () {
      final wide = tilesAt(SkyPoint(180, 30), 100);
      final narrow = tilesAt(SkyPoint(180, 30), 5);
      expect(narrow.length, lessThan(wide.length));
      expect(narrow, isNotEmpty);
    });

    test('a narrow FOV covers only part of the sky (excludes off-screen tiles)', () {
      final tiles = tilesAt(SkyPoint(180, 0), 10);
      expect(tiles.length, lessThan(index.tileCount ~/ 4));
      // Tiles on the opposite side of the sky are excluded
      final oppositeTile = index.tileIndexOf(0, 0);
      expect(tiles, isNot(contains(oppositeTile)));
    });
  });

  group('tileCenter / tileAngularRadiusDeg', () {
    test('any point inside a tile lies within the angular radius of its center', () {
      // Verify sample points inside representative tiles of each band
      for (var dec = -82.0; dec <= 82.0; dec += 15.0) {
        for (var ra = 5.0; ra < 360.0; ra += 60.0) {
          final tile = index.tileIndexOf(ra, dec);
          final center = index.tileCenter(tile);
          final radius = index.tileAngularRadiusDeg(tile);
          final point = SkyPoint(ra, dec);
          expect(
            point.angularDistanceTo(center),
            lessThanOrEqualTo(radius + 1e-9),
            reason: 'tile=$tile point=$point center=$center r=$radius',
          );
        }
      }
    });
  });
}
