import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/asset_catalog_repository.dart';
import 'package:open_planetarium/data/catalog/tile_binary_codec.dart';
import 'package:open_planetarium/domain/models/star.dart';

void main() {
  // Synthetic catalog: 3 stars in brightness order in tile 1, 1 star in tile 2
  final tiles = <int, List<Star>>{
    1: [
      const Star(
        id: 100,
        raDeg: 10,
        decDeg: 5,
        magnitude: 1.0,
        tileIndex: 1,
        colorIndexBV: 0.5,
      ),
      const Star(id: 101, raDeg: 11, decDeg: 5, magnitude: 4.0, tileIndex: 1),
      const Star(id: 102, raDeg: 12, decDeg: 5, magnitude: 6.2, tileIndex: 1),
    ],
    2: [
      const Star(id: 200, raDeg: 50, decDeg: 40, magnitude: 2.0, tileIndex: 2),
    ],
  };

  AssetCatalogRepository buildRepo() {
    final binBytes = const TileBinaryCodec().encode(tiles);
    final namesBytes = Uint8List.fromList(
      utf8.encode(jsonEncode({'100': 'TestStar'})),
    );
    return AssetCatalogRepository(
      loader: (key) async => key.endsWith('.bin') ? binBytes : namesBytes,
    );
  }

  group('AssetCatalogRepository', () {
    test('returns only stars in the requested tiles (excludes out-of-viewport tiles)', () async {
      final repo = buildRepo();
      final stars = await repo.starsInTiles([1], 6.5);
      expect(stars.map((s) => s.id), [100, 101, 102]);
      expect(stars.any((s) => s.tileIndex == 2), isFalse);
    });

    test('stars fainter than the limiting magnitude are excluded', () async {
      final repo = buildRepo();
      final stars = await repo.starsInTiles([1, 2], 4.5);
      expect(stars.map((s) => s.id).toSet(), {100, 101, 200});
    });

    test('proper names are applied', () async {
      final repo = buildRepo();
      final stars = await repo.starsInTiles([1], 2.0);
      expect(stars.single.name, 'TestStar');
    });

    test('nonexistent tile indices are ignored', () async {
      final repo = buildRepo();
      final stars = await repo.starsInTiles([99], 6.5);
      expect(stars, isEmpty);
    });

    test('consecutive calls load only once (caching)', () async {
      var loadCount = 0;
      final binBytes = const TileBinaryCodec().encode(tiles);
      final namesBytes = Uint8List.fromList(utf8.encode('{}'));
      final repo = AssetCatalogRepository(
        loader: (key) async {
          loadCount++;
          return key.endsWith('.bin') ? binBytes : namesBytes;
        },
      );
      await repo.starsInTiles([1], 6.5);
      await repo.starsInTiles([2], 6.5);
      expect(loadCount, 2); // once each for bin + json
    });
  });
}
