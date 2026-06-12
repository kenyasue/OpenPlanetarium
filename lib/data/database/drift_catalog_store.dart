import 'package:drift/drift.dart';

import '../../domain/models/star.dart' as domain;
import 'app_database.dart';

/// Access to the drift catalog DB (storing and querying downloaded catalogs).
class DriftCatalogStore {
  DriftCatalogStore(this._db);

  final AppDatabase _db;

  /// Imports the stars of one tile (replacing existing rows for that tile).
  Future<void> importTile({
    required String catalog,
    required int tileIndex,
    required String sha256,
    required List<domain.Star> stars,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(_db.stars)..where(
            (t) => t.catalog.equals(catalog) & t.tileIndex.equals(tileIndex),
          ))
          .go();
      await _db.batch((batch) {
        batch.insertAll(_db.stars, [
          for (final star in stars)
            StarsCompanion.insert(
              catalog: catalog,
              starId: star.id,
              tileIndex: star.tileIndex,
              raDeg: star.raDeg,
              decDeg: star.decDeg,
              magnitude: star.magnitude,
              colorIndexBV: Value(star.colorIndexBV),
              name: Value(star.name),
            ),
        ], mode: InsertMode.insertOrReplace);
      });
      await _db
          .into(_db.downloadedTiles)
          .insertOnConflictUpdate(
            DownloadedTilesCompanion.insert(
              catalog: catalog,
              tileIndex: tileIndex,
              sha256: sha256,
            ),
          );
    });
  }

  /// Fetches stars at or below the limiting magnitude from the given tiles
  /// (across all downloaded catalogs)
  Future<List<domain.Star>> starsInTiles(
    List<int> tiles,
    double limitingMagnitude,
  ) async {
    if (tiles.isEmpty) return const [];
    final rows =
        await (_db.select(_db.stars)..where(
              (t) =>
                  t.tileIndex.isIn(tiles) &
                  t.magnitude.isSmallerOrEqualValue(limitingMagnitude),
            ))
            .get();
    return [
      for (final row in rows)
        domain.Star(
          id: row.starId,
          raDeg: row.raDeg,
          decDeg: row.decDeg,
          magnitude: row.magnitude,
          tileIndex: row.tileIndex,
          colorIndexBV: row.colorIndexBV,
          name: row.name,
        ),
    ];
  }

  /// Tiles whose download has completed (tileIndex → sha256)
  Future<Map<int, String>> downloadedTiles(String catalog) async {
    final rows = await (_db.select(
      _db.downloadedTiles,
    )..where((t) => t.catalog.equals(catalog))).get();
    return {for (final row in rows) row.tileIndex: row.sha256};
  }

  /// Deletes all data of a catalog
  Future<void> deleteCatalog(String catalog) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.stars,
      )..where((t) => t.catalog.equals(catalog))).go();
      await (_db.delete(
        _db.downloadedTiles,
      )..where((t) => t.catalog.equals(catalog))).go();
    });
  }

  /// Number of stars stored per catalog
  Future<int> starCount(String catalog) async {
    final count = _db.stars.starId.count();
    final query = _db.selectOnly(_db.stars)
      ..addColumns([count])
      ..where(_db.stars.catalog.equals(catalog));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
