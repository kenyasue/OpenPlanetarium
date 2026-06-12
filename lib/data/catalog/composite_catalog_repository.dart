import '../../domain/models/star.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../database/drift_catalog_store.dart';
import 'asset_catalog_repository.dart';

/// Repository that combines the bundled catalog (BSC) with downloaded
/// catalogs (drift DB) (becomes the implementation of
/// catalogRepositoryProvider in M5).
class CompositeCatalogRepository implements CatalogRepository {
  CompositeCatalogRepository({required this.asset, required this.store});

  final AssetCatalogRepository asset;
  final DriftCatalogStore store;

  @override
  Future<List<Star>> starsInTiles(
    List<int> tiles,
    double limitingMagnitude,
  ) async {
    final results = await Future.wait([
      asset.starsInTiles(tiles, limitingMagnitude),
      store.starsInTiles(tiles, limitingMagnitude),
    ]);
    if (results[1].isEmpty) return results[0];
    return [...results[0], ...results[1]];
  }

  /// Proper-name search covers only the asset catalog (BSC)
  /// (additional catalogs such as Tycho-2 rarely have proper names).
  @override
  Future<List<Star>> namedStars() => asset.namedStars();
}
