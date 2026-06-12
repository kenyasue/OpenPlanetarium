import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/database/app_database.dart';
import 'package:open_planetarium/data/database/drift_catalog_store.dart';
import 'package:open_planetarium/domain/models/star.dart';

void main() {
  late AppDatabase db;
  late DriftCatalogStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = DriftCatalogStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  const tileStars = [
    Star(id: 1, raDeg: 10, decDeg: 5, magnitude: 7.5, tileIndex: 3),
    Star(
      id: 2,
      raDeg: 11,
      decDeg: 6,
      magnitude: 9.2,
      tileIndex: 3,
      colorIndexBV: 0.8,
    ),
  ];

  group('DriftCatalogStore', () {
    test('importTile → starsInTiles retrieves with a magnitude filter', () async {
      await store.importTile(
        catalog: 'tycho2_m10',
        tileIndex: 3,
        sha256: 'abc',
        stars: tileStars,
      );

      final all = await store.starsInTiles([3], 10.0);
      expect(all, hasLength(2));
      expect(all.first.colorIndexBV, isNull);

      final bright = await store.starsInTiles([3], 8.0);
      expect(bright.single.id, 1);

      final otherTile = await store.starsInTiles([4], 10.0);
      expect(otherTile, isEmpty);
    });

    test('re-importing the same tile replaces it (no duplicates)', () async {
      await store.importTile(
        catalog: 'tycho2_m10',
        tileIndex: 3,
        sha256: 'v1',
        stars: tileStars,
      );
      await store.importTile(
        catalog: 'tycho2_m10',
        tileIndex: 3,
        sha256: 'v2',
        stars: [tileStars.first],
      );
      expect(await store.starsInTiles([3], 10.0), hasLength(1));
      expect((await store.downloadedTiles('tycho2_m10'))[3], 'v2');
    });

    test('deleteCatalog removes stars and tile records', () async {
      await store.importTile(
        catalog: 'tycho2_m10',
        tileIndex: 3,
        sha256: 'abc',
        stars: tileStars,
      );
      await store.deleteCatalog('tycho2_m10');
      expect(await store.starsInTiles([3], 10.0), isEmpty);
      expect(await store.downloadedTiles('tycho2_m10'), isEmpty);
      expect(await store.starCount('tycho2_m10'), 0);
    });
  });
}
