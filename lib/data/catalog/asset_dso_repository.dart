import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/exceptions.dart';
import '../../domain/models/deep_sky_object.dart';
import '../../domain/repositories/dso_repository.dart';
import 'asset_constellation_repository.dart' show AssetStringLoader;

/// Repository implementation for the bundled deep-sky object catalog.
///
/// Loads and merges dso.json (Messier and NGC/IC from OpenNGC) and
/// dso_extra.json (Sh2/LBN/LDN/vdB from VizieR).
class AssetDsoRepository implements DsoRepository {
  AssetDsoRepository({
    AssetStringLoader? loader,
    this.assetKey = 'assets/catalogs/dso.json',
    this.extraAssetKey = 'assets/catalogs/dso_extra.json',
  }) : _loader = loader ?? rootBundle.loadString;

  final AssetStringLoader _loader;
  final String assetKey;
  final String extraAssetKey;

  @override
  Future<List<DeepSkyObject>> loadAll() async {
    try {
      final objects = await _loadFile(assetKey);
      try {
        objects.addAll(await _loadFile(extraAssetKey));
      } on FlutterError {
        // Builds without the extra catalog continue with the base catalog only
      }
      // Brightest first (missing values last) so label culling during
      // rendering can prioritize bright objects
      objects.sort(
        (a, b) => (a.magnitude ?? 99.0).compareTo(b.magnitude ?? 99.0),
      );
      return objects;
    } on FormatException catch (e) {
      throw CatalogCorruptedException('Invalid celestial object data format: $e');
    } on TypeError catch (e) {
      throw CatalogCorruptedException('Invalid celestial object data format: $e');
    }
  }

  Future<List<DeepSkyObject>> _loadFile(String key) async {
    final json = jsonDecode(await _loader(key)) as Map<String, dynamic>;
    return [
      for (final raw in json['objects'] as List<dynamic>)
        _parse(raw as Map<String, dynamic>),
    ];
  }

  DeepSkyObject _parse(Map<String, dynamic> json) {
    return DeepSkyObject(
      id: json['id'] as String,
      objectType:
          ObjectType.values.asNameMap()[json['type'] as String] ??
          ObjectType.other,
      raDeg: (json['ra'] as num).toDouble(),
      decDeg: (json['dec'] as num).toDouble(),
      commonName: json['name'] as String?,
      nameJa: json['ja'] as String?,
      magnitude: (json['mag'] as num?)?.toDouble(),
      majorAxisArcmin: (json['majAx'] as num?)?.toDouble(),
      minorAxisArcmin: (json['minAx'] as num?)?.toDouble(),
      constellation: json['con'] as String?,
      messierNumber: json['m'] as int?,
    );
  }
}
