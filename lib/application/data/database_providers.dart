import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/drift_catalog_store.dart';

/// Catalog DB (one instance app-wide)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final catalogStoreProvider = Provider<DriftCatalogStore>(
  (ref) => DriftCatalogStore(ref.watch(appDatabaseProvider)),
);
