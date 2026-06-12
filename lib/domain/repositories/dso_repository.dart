import '../models/deep_sky_object.dart';

/// Access interface for the deep-sky object catalog (implemented in the data layer).
abstract class DsoRepository {
  /// Loads all objects (Messier 110 + major NGC/IC, pre-sorted brightest first).
  ///
  /// Called once at startup; the result is cached by the provider.
  /// Throws [CatalogCorruptedException] on malformed data.
  Future<List<DeepSkyObject>> loadAll();
}
