import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/exceptions.dart';
import '../../domain/models/constellation_data.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/repositories/constellation_repository.dart';

/// Loader for asset strings (replaceable in tests)
typedef AssetStringLoader = Future<String> Function(String key);

/// Repository implementation for the bundled constellation data (constellations.json).
class AssetConstellationRepository implements ConstellationRepository {
  AssetConstellationRepository({
    AssetStringLoader? loader,
    this.assetKey = 'assets/catalogs/constellations.json',
  }) : _loader = loader ?? rootBundle.loadString;

  final AssetStringLoader _loader;
  final String assetKey;

  @override
  Future<ConstellationSet> load() async {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await _loader(assetKey)) as Map<String, dynamic>;
      final constellations = [
        for (final raw in json['constellations'] as List<dynamic>)
          _parseConstellation(raw as Map<String, dynamic>),
      ];
      final boundaries = [
        for (final raw in json['boundaries'] as List<dynamic>)
          _parsePolyline(raw as List<dynamic>),
      ];
      return ConstellationSet(
        constellations: constellations,
        boundaries: boundaries,
      );
    } on FormatException catch (e) {
      throw CatalogCorruptedException('Invalid constellation data format: $e');
    } on TypeError catch (e) {
      throw CatalogCorruptedException('Invalid constellation data format: $e');
    }
  }

  ConstellationData _parseConstellation(Map<String, dynamic> json) {
    return ConstellationData(
      iau: json['iau'] as String,
      nameLatin: json['la'] as String,
      nameEn: json['en'] as String,
      nameJa: json['ja'] as String,
      labelAnchor: SkyPoint(
        (json['labelRa'] as num).toDouble(),
        (json['labelDec'] as num).toDouble(),
      ),
      lines: [
        for (final line in json['lines'] as List<dynamic>)
          _parsePolyline(line as List<dynamic>),
      ],
    );
  }

  List<SkyPoint> _parsePolyline(List<dynamic> points) {
    return [
      for (final p in points)
        SkyPoint(
          ((p as List<dynamic>)[0] as num).toDouble(),
          (p[1] as num).toDouble(),
        ),
    ];
  }
}
