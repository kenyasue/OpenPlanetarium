import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/star.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'tile_binary_codec.dart';

/// Loader for asset byte data (replaceable in tests)
typedef AssetBytesLoader = Future<Uint8List> Function(String key);

Future<Uint8List> _rootBundleLoader(String key) async {
  final data = await rootBundle.load(key);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// Repository implementation for the bundled catalog (BSC equivalent, mag<=6.5).
///
/// Loads all tiles into memory on first access (about 9,000 stars / 180KB,
/// so keeping everything is light enough). Replaced by the drift + partial
/// download implementation in M5.
class AssetCatalogRepository implements CatalogRepository {
  AssetCatalogRepository({
    AssetBytesLoader? loader,
    this.tilesAssetKey = 'assets/catalogs/bsc_tiles.bin',
    this.namesAssetKey = 'assets/catalogs/star_names.json',
  }) : _loader = loader ?? _rootBundleLoader;

  final AssetBytesLoader _loader;
  final String tilesAssetKey;
  final String namesAssetKey;

  Future<Map<int, List<Star>>>? _loading;

  Future<Map<int, List<Star>>> _ensureLoaded() {
    // Load only once even under concurrent access.
    // Caching a failed Future would make all subsequent requests keep
    // failing, so on error discard the cache to allow a retry next time
    return _loading ??= _load().catchError((Object e, StackTrace st) {
      _loading = null;
      return Future<Map<int, List<Star>>>.error(e, st);
    });
  }

  Future<Map<int, List<Star>>> _load() async {
    final namesBytes = await _loader(namesAssetKey);
    final namesJson =
        jsonDecode(utf8.decode(namesBytes)) as Map<String, dynamic>;
    final names = <int, String>{
      for (final entry in namesJson.entries)
        int.parse(entry.key): entry.value as String,
    };
    final tileBytes = await _loader(tilesAssetKey);
    return const TileBinaryCodec().decode(tileBytes, names: names);
  }

  @override
  Future<List<Star>> namedStars() async {
    final all = await _ensureLoaded();
    return [
      for (final stars in all.values)
        for (final star in stars)
          if (star.name != null) star,
    ];
  }

  /// Precondition: stars within each tile are sorted by ascending magnitude
  /// (guaranteed by the conversion script tool/catalog_converter).
  @override
  Future<List<Star>> starsInTiles(
    List<int> tiles,
    double limitingMagnitude,
  ) async {
    final all = await _ensureLoaded();
    final result = <Star>[];
    for (final tile in tiles) {
      final stars = all[tile];
      if (stars == null) continue;
      // Tiles are pre-sorted brightest first (conversion script), so we can break early
      for (final star in stars) {
        if (star.magnitude > limitingMagnitude) break;
        result.add(star);
      }
    }
    return result;
  }
}
