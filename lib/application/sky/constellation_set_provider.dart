import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/asset_constellation_repository.dart';
import '../../domain/models/constellation_data.dart';
import '../../domain/repositories/constellation_repository.dart';

/// DI point for the constellation repository
final constellationRepositoryProvider = Provider<ConstellationRepository>(
  (ref) => AssetConstellationRepository(),
);

/// All-sky constellation data (loaded once at startup)
final constellationSetProvider = FutureProvider<ConstellationSet>(
  (ref) => ref.watch(constellationRepositoryProvider).load(),
);
