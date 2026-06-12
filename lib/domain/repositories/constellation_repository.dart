import '../models/constellation_data.dart';

/// Access interface for constellation data (implemented in the data layer).
abstract class ConstellationRepository {
  /// Loads all 88 constellations (lines, names in 3 languages, label positions) and IAU boundaries.
  ///
  /// Called once at startup; the result is cached by the provider.
  /// Throws [CatalogCorruptedException] on malformed or missing data.
  /// The caller should continue rendering without the constellation layer
  /// (graceful degradation).
  Future<ConstellationSet> load();
}
