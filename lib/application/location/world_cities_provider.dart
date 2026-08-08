import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/world_map_loader.dart';
import '../../domain/models/land_ring.dart';
import '../../domain/models/world_city.dart';
import '../../domain/repositories/world_map_repository.dart';

/// DI point for the world map repository (overridable in tests).
final worldMapLoaderProvider = Provider<WorldMapRepository>(
  (ref) => WorldMapLoader(),
);

/// Bundled city catalog with country grouping for the location pickers.
class WorldCityCatalog {
  WorldCityCatalog(this.cities)
    : countries = _sortedCountries(cities),
      _byCountry = _groupByCountry(cities);

  /// All cities (sorted by country, then name — asset generation order)
  final List<WorldCity> cities;

  /// Distinct country names, alphabetically sorted
  final List<String> countries;

  final Map<String, List<WorldCity>> _byCountry;

  /// Cities of [country] (empty list for an unknown country)
  List<WorldCity> citiesOf(String country) => _byCountry[country] ?? const [];

  static List<String> _sortedCountries(List<WorldCity> cities) {
    final set = {for (final c in cities) c.country};
    return set.toList()..sort();
  }

  static Map<String, List<WorldCity>> _groupByCountry(List<WorldCity> cities) {
    final map = <String, List<WorldCity>>{};
    for (final city in cities) {
      map.putIfAbsent(city.country, () => []).add(city);
    }
    return map;
  }
}

/// City catalog loaded from the bundled asset (loaded on first use)
final worldCityCatalogProvider = FutureProvider<WorldCityCatalog>((ref) async {
  final cities = await ref.watch(worldMapLoaderProvider).loadCities();
  return WorldCityCatalog(cities);
});

/// Land polygon rings for the world map background
final worldLandRingsProvider = FutureProvider<List<LandRing>>(
  (ref) => ref.watch(worldMapLoaderProvider).loadLandRings(),
);
