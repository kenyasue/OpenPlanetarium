import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/asset_dso_repository.dart';
import '../../domain/models/deep_sky_object.dart';
import '../../domain/repositories/dso_repository.dart';
import '../settings/dso_settings_controller.dart';

/// DI point for the DSO repository
final dsoRepositoryProvider = Provider<DsoRepository>(
  (ref) => AssetDsoRepository(),
);

/// All deep sky objects (loaded once at startup, sorted by brightness). Search covers all entries
final dsoListProvider = FutureProvider<List<DeepSkyObject>>(
  (ref) => ref.watch(dsoRepositoryProvider).loadAll(),
);

/// Deep sky objects filtered by catalog and display magnitude settings (for rendering and on-screen selection).
///
/// Objects with unknown magnitude (common in nebula catalogs such as Sh2/LBN/LDN)
/// pass the magnitude filter and are controlled by the catalog switches only.
final visibleDsosProvider = Provider<List<DeepSkyObject>>((ref) {
  final dsos = ref.watch(dsoListProvider).value ?? const <DeepSkyObject>[];
  final settings = ref.watch(dsoSettingsProvider);
  final enabled = settings.enabled;
  final limitMag = settings.limitingMagnitude;
  return [
    for (final dso in dsos)
      if (dso.catalogs.any(enabled.contains) &&
          (dso.magnitude == null || dso.magnitude! <= limitMag))
        dso,
  ];
});
