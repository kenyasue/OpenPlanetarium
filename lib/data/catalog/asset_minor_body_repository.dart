import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/exceptions.dart';
import '../../domain/models/minor_body.dart';
import '../../domain/repositories/minor_body_repository.dart';
import 'asset_constellation_repository.dart' show AssetStringLoader;

/// Bundled minor body catalog (minor_bodies.json, derived from JPL SBDB).
class AssetMinorBodyRepository implements MinorBodyRepository {
  AssetMinorBodyRepository({
    AssetStringLoader? loader,
    this.assetKey = 'assets/catalogs/minor_bodies.json',
  }) : _loader = loader ?? rootBundle.loadString;

  final AssetStringLoader _loader;
  final String assetKey;

  @override
  Future<List<MinorBody>> loadAll() async {
    try {
      final json = jsonDecode(await _loader(assetKey)) as Map<String, dynamic>;
      return [
        for (final raw in json['bodies'] as List<dynamic>)
          _parse(raw as Map<String, dynamic>),
      ];
    } on FormatException catch (e) {
      throw CatalogCorruptedException('Invalid minor body data format: $e');
    } on TypeError catch (e) {
      throw CatalogCorruptedException('Invalid minor body data format: $e');
    }
  }

  MinorBody _parse(Map<String, dynamic> json) {
    return MinorBody(
      id: json['id'] as String,
      name: json['name'] as String,
      nameJa: json['ja'] as String?,
      kind: json['kind'] == 'comet'
          ? MinorBodyKind.comet
          : MinorBodyKind.asteroid,
      elements: OrbitalElements(
        epochJd: (json['epoch'] as num).toDouble(),
        aAu: (json['a'] as num).toDouble(),
        e: (json['e'] as num).toDouble(),
        iDeg: (json['i'] as num).toDouble(),
        nodeDeg: (json['om'] as num).toDouble(),
        argPeriDeg: (json['w'] as num).toDouble(),
        meanAnomalyDeg: (json['ma'] as num).toDouble(),
      ),
      mag1: (json['mag1'] as num).toDouble(),
      mag2: (json['mag2'] as num).toDouble(),
    );
  }
}
