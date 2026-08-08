import '../models/land_ring.dart';
import '../models/world_city.dart';

/// Provides the world map data (land silhouettes and major cities) for the
/// observing-location picker.
abstract class WorldMapRepository {
  /// Loads the bundled major-city catalog.
  ///
  /// Throws `CatalogCorruptedException` when the bundled data is malformed.
  Future<List<WorldCity>> loadCities();

  /// Loads the land polygon rings for the world map background.
  ///
  /// Throws `CatalogCorruptedException` when the bundled data is malformed.
  Future<List<LandRing>> loadLandRings();
}
