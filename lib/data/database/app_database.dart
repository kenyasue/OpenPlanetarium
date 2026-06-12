import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Stars from downloaded catalogs (the BSC is bundled as an asset and is not stored here).
@DataClassName('CatalogStarRow')
class Stars extends Table {
  TextColumn get catalog => text()(); // e.g. 'tycho2_m10'
  IntColumn get starId => integer()();
  IntColumn get tileIndex => integer()();
  RealColumn get raDeg => real()();
  RealColumn get decDeg => real()();
  RealColumn get magnitude => real()();
  RealColumn get colorIndexBV => real().nullable()();
  TextColumn get name => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {catalog, starId};
}

/// Per-tile download completion records (used to skip tiles on resume).
class DownloadedTiles extends Table {
  TextColumn get catalog => text()();
  IntColumn get tileIndex => integer()();
  TextColumn get sha256 => text()();

  @override
  Set<Column<Object>> get primaryKey => {catalog, tileIndex};
}

/// Catalog DB (see docs/architecture.md, data persistence strategy).
///
/// Has a composite index for tile + magnitude queries (F2).
@DriftDatabase(tables: [Stars, DownloadedTiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  static QueryExecutor _openDefault() =>
      driftDatabase(name: 'catalogs', native: const DriftNativeOptions());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_stars_tile_mag '
        'ON stars (tile_index, magnitude)',
      );
    },
  );
}
