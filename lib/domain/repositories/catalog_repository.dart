import '../models/star.dart';

/// Access interface for the star catalog (implemented in the data layer).
///
/// M2: bundled asset catalog (AssetCatalogRepository)
/// M5: planned replacement with drift (SQLite) + partial downloads
abstract class CatalogRepository {
  /// Fetches stars in the given tiles at or below the limiting magnitude (brighter side).
  Future<List<Star>> starsInTiles(List<int> tiles, double limitingMagnitude);

  /// List of stars with proper names (for search, F8).
  Future<List<Star>> namedStars();
}
