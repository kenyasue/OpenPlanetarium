import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/asset_catalog_repository.dart';
import '../../data/catalog/composite_catalog_repository.dart';
import '../../domain/models/star.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/spatial/spatial_index.dart';
import '../data/database_providers.dart';
import '../settings/appearance_settings_controller.dart';
import '../viewport/lod_policy.dart';
import '../viewport/viewport_controller.dart';

/// Spatial index (one instance app-wide)
final spatialIndexProvider = Provider<SpatialIndex>((ref) => SpatialIndex());

/// Catalog repository: composite of the asset BSC + downloaded catalogs (drift)
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CompositeCatalogRepository(
    asset: AssetCatalogRepository(),
    store: ref.watch(catalogStoreProvider),
  ),
);

/// Stars visible in the current viewport (F2).
///
/// Automatically re-evaluated when the viewportState or settings change. Riverpod
/// keeps the last settled value during re-evaluation (AsyncValue's copyWithPrevious),
/// so results from an old viewport never leak into the new display — generation
/// management is achieved through the provider's re-evaluation semantics.
final visibleStarsProvider = FutureProvider<List<Star>>((ref) async {
  final state = ref.watch(viewportStateProvider);
  final settings = ref.watch(appearanceSettingsProvider);

  final aspect = state.screenSize.height <= 0
      ? 1.0
      : state.screenSize.width / state.screenSize.height;
  final tiles = ref
      .watch(spatialIndexProvider)
      .tilesInViewport(
        center: state.center,
        fovDeg: state.fovDeg,
        aspectRatio: aspect,
      );
  final limitMag = effectiveLimitingMagnitude(state.fovDeg, settings);
  return ref.watch(catalogRepositoryProvider).starsInTiles(tiles, limitMag);
});
