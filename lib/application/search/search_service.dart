import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/constellation_data.dart';
import '../../domain/models/deep_sky_object.dart';
import '../../domain/models/sky_object.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/solar_system.dart';
import '../../domain/models/star.dart';
import '../sky/constellation_set_provider.dart';
import '../sky/dso_provider.dart';
import '../sky/visible_stars_provider.dart';

/// A single search result.
///
/// When [object] is null, the result is a constellation (centering only, not selectable).
class SearchResult {
  const SearchResult({
    required this.label,
    required this.sublabel,
    required this.target,
    this.object,
    this.suggestedFovDeg,
  });

  final String label;
  final String sublabel;
  final SkyPoint target;
  final SkyObject? object;

  /// Suggested field of view (FOV) when centering (null keeps the current value)
  final double? suggestedFovDeg;
}

/// Celestial object search (F8).
///
/// Supported queries: object names (partial match in Japanese/English), constellation names (3 languages),
/// Messier numbers (M31), NGC/IC numbers (NGC 224), and solar system body names.
class SearchService {
  const SearchService({
    required this.namedStars,
    required this.dsos,
    required this.constellations,
  });

  final List<Star> namedStars;
  final List<DeepSkyObject> dsos;
  final List<ConstellationData> constellations;

  static final _messierPattern = RegExp(
    r'^m\s*(\d{1,3})$',
    caseSensitive: false,
  );
  static final _ngcPattern = RegExp(r'^ngc\s*(\d{1,4})$', caseSensitive: false);
  static final _icPattern = RegExp(r'^ic\s*(\d{1,4})$', caseSensitive: false);

  List<SearchResult> search(String rawQuery, {int limit = 20}) {
    final query = rawQuery.trim();
    if (query.isEmpty) return const [];
    final lower = query.toLowerCase();

    // Catalog numbers (exact match) take top priority
    final messier = _messierPattern.firstMatch(lower);
    if (messier != null) {
      final number = int.parse(messier.group(1)!);
      return [
        for (final dso in dsos)
          if (dso.messierNumber == number) _dsoResult(dso),
      ];
    }
    final ngc = _ngcPattern.firstMatch(lower);
    if (ngc != null) return _byCatalogId('NGC', ngc.group(1)!);
    final ic = _icPattern.firstMatch(lower);
    if (ic != null) return _byCatalogId('IC', ic.group(1)!);

    final results = <SearchResult>[];

    // Solar system bodies (prefix match on Japanese/English names)
    for (final body in SolarBodyId.values) {
      if (body.nameJa.startsWith(query) ||
          body.nameEn.toLowerCase().startsWith(lower)) {
        results.add(
          SearchResult(
            label: body.nameJa,
            sublabel: body.nameEn,
            // Position is time-dependent, so the UI resolves it at centerOn time
            target: SkyPoint(0, 0),
            object: SolarBodyObject(body),
          ),
        );
      }
    }

    // Constellations (partial match in 3 languages)
    for (final c in constellations) {
      if (c.nameJa.contains(query) ||
          c.nameEn.toLowerCase().contains(lower) ||
          c.nameLatin.toLowerCase().contains(lower)) {
        results.add(
          SearchResult(
            label: c.nameJa,
            sublabel: 'Constellation / ${c.nameLatin}',
            target: c.labelAnchor,
            suggestedFovDeg: 50,
          ),
        );
      }
    }

    // Stars (partial match on proper names)
    for (final star in namedStars) {
      final name = star.name!;
      if (name.toLowerCase().contains(lower) || name.contains(query)) {
        results.add(
          SearchResult(
            label: name,
            sublabel: 'Star mag ${star.magnitude.toStringAsFixed(1)}',
            target: SkyPoint(star.raDeg, star.decDeg),
            object: StarObject(star),
          ),
        );
      }
    }

    // DSOs (partial match on Japanese name, common name, or catalog label)
    for (final dso in dsos) {
      final matchesJa = dso.nameJa?.contains(query) ?? false;
      final matchesEn = dso.commonName?.toLowerCase().contains(lower) ?? false;
      final matchesCatalog =
          dso.catalogLabel.toLowerCase().replaceAll(' ', '') ==
          lower.replaceAll(' ', '');
      if (matchesJa || matchesEn || matchesCatalog) {
        results.add(_dsoResult(dso));
      }
    }

    return results.take(limit).toList();
  }

  List<SearchResult> _byCatalogId(String prefix, String number) {
    final padded = number.padLeft(4, '0');
    return [
      for (final dso in dsos)
        if (dso.id == '$prefix$padded') _dsoResult(dso),
    ];
  }

  SearchResult _dsoResult(DeepSkyObject dso) {
    return SearchResult(
      label: dso.displayName,
      sublabel:
          '${dso.objectType.labelJa} / ${dso.catalogLabel}'
          '${dso.magnitude != null ? " mag ${dso.magnitude!.toStringAsFixed(1)}" : ""}',
      target: SkyPoint(dso.raDeg, dso.decDeg),
      object: DsoObject(dso),
      suggestedFovDeg: 10,
    );
  }
}

/// Search query (synced with the UI TextField)
final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// SearchService bundling the searchable data (available after data load completes)
final searchServiceProvider = Provider<SearchService>((ref) {
  final namedStarsAsync = ref.watch(namedStarsProvider);
  final dsosAsync = ref.watch(dsoListProvider);
  final constellationsAsync = ref.watch(constellationSetProvider);
  return SearchService(
    namedStars: namedStarsAsync.value ?? const [],
    dsos: dsosAsync.value ?? const [],
    constellations: constellationsAsync.value?.constellations ?? const [],
  );
});

/// Stars with proper names (for search)
final namedStarsProvider = FutureProvider<List<Star>>(
  (ref) => ref.watch(catalogRepositoryProvider).namedStars(),
);

/// Search results for the current query
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider);
  return ref.watch(searchServiceProvider).search(query);
});
