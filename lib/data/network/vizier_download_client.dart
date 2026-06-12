import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/catalog_download.dart';
import '../../domain/models/star.dart';
import '../../domain/repositories/download_client.dart';
import '../../domain/spatial/spatial_index.dart';
import '../catalog/tile_binary_codec.dart';

/// CDS VizieR TAP endpoint (official distribution source for Tycho-2)
const String kVizieRTapUrl = 'https://tapvizier.cds.unistra.fr/TAPVizieR/tap';

/// Client that fetches Tycho-2 (I/259) directly from CDS VizieR per tile.
///
/// Requires no self-hosted distribution server; the manifest is generated
/// locally. Each tile is fetched via an ADQL query over an RA/Dec rectangle,
/// converted to Johnson V magnitude and B-V, and encoded in
/// [TileBinaryCodec] format (so the existing import path can be reused
/// as is). Since the server provides no checksums, the manifest sha256 is
/// empty (DownloadController skips verification).
class VizieRDownloadClient implements DownloadClient {
  VizieRDownloadClient({Dio? dio, SpatialIndex? index})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 90),
            ),
          ),
      _index = index ?? SpatialIndex();

  final Dio _dio;
  final SpatialIndex _index;

  static const _codec = TileBinaryCodec();

  /// Supported catalog ID
  static const String catalogId = 'tycho2_m10';

  /// Accepted magnitude range: avoids overlap with the bundled BSC (down to mag 6.5)
  static const double minMagnitudeExclusive = 6.5;
  static const double maxMagnitudeInclusive = 10.0;

  /// VTmag pre-filter for ADQL. Since V = VT - 0.090(BT-VT), allow some
  /// margin so stars whose VT is slightly fainter but whose V is within
  /// magnitude 10.0 are not missed
  static const double _vtPrefilter = 10.6;

  @override
  Future<CatalogManifest> fetchManifest(String id) async {
    if (id != catalogId) {
      throw DownloadUnavailableException('Unsupported catalog: $id');
    }
    return CatalogManifest(
      catalogId: id,
      version: 1,
      totalBytes: 0, // Unknown until fetched (progress is shown by tile count)
      tiles: [
        for (var tile = 0; tile < _index.tileCount; tile++)
          ManifestTile(index: tile, bytes: 0, sha256: ''),
      ],
    );
  }

  @override
  Future<Uint8List> fetchTile(String id, int tileIndex) async {
    if (id != catalogId) {
      throw DownloadUnavailableException('Unsupported catalog: $id');
    }
    final String csv;
    try {
      final response = await _dio.get<String>(
        '$kVizieRTapUrl/sync',
        queryParameters: {
          'REQUEST': 'doQuery',
          'LANG': 'ADQL',
          'FORMAT': 'csv',
          'QUERY': adqlForTile(_index, tileIndex),
        },
        options: Options(responseType: ResponseType.plain),
      );
      csv = response.data ?? '';
    } on DioException catch (e) {
      throw DownloadException(
        'Failed to fetch tile $tileIndex from VizieR: ${e.message}',
        retryable: _isRetryable(e),
      );
    }
    final stars = parseTycho2Csv(csv, tileIndex, _index);
    return _codec.encode({tileIndex: stars});
  }

  /// ADQL query for the tile's RA/Dec rectangle
  @visibleForTesting
  static String adqlForTile(SpatialIndex index, int tileIndex) {
    final b = index.tileBounds(tileIndex);
    // The topmost band includes Dec=+90 (rectangles are half-open intervals)
    final decUpper = b.decMaxDeg >= 90.0
        ? 'DEmdeg<=90'
        : 'DEmdeg<${b.decMaxDeg}';
    return 'SELECT TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag '
        'FROM "I/259/tyc2" '
        'WHERE RAmdeg>=${b.raMinDeg} AND RAmdeg<${b.raMaxDeg} '
        'AND DEmdeg>=${b.decMinDeg} AND $decUpper '
        'AND VTmag<=$_vtPrefilter';
  }

  /// Converts a VizieR TAP CSV response into a list of Stars.
  ///
  /// - V = VT − 0.090×(BT−VT), B−V = 0.850×(BT−VT) (ESA SP-1200 conversion)
  /// - If BT is missing, V = VT and B−V is unknown; rows missing VT are skipped
  /// - Only stars fainter than magnitude 6.5 and at most 10.0 are accepted
  ///   (avoids overlap with the bundled BSC)
  /// - Star ID = TYC1×200000 + TYC2×4 + TYC3 (unique, fits in int32)
  @visibleForTesting
  static List<Star> parseTycho2Csv(
    String csv,
    int tileIndex,
    SpatialIndex index,
  ) {
    final lines = csv.split('\n');
    if (lines.isEmpty) return const [];
    final header = lines.first.trim().split(',');
    final col = {
      for (var i = 0; i < header.length; i++) header[i].trim().toUpperCase(): i,
    };
    final tyc1 = col['TYC1'];
    final tyc2 = col['TYC2'];
    final tyc3 = col['TYC3'];
    final raCol = col['RAMDEG'];
    final decCol = col['DEMDEG'];
    final btCol = col['BTMAG'];
    final vtCol = col['VTMAG'];
    if (tyc1 == null ||
        tyc2 == null ||
        tyc3 == null ||
        raCol == null ||
        decCol == null ||
        vtCol == null) {
      throw const CatalogCorruptedException(
        'Unexpected column layout in VizieR response',
      );
    }

    final stars = <Star>[];
    for (final line in lines.skip(1)) {
      final fields = line.trim().split(',');
      if (fields.length < header.length) continue;
      final ra = double.tryParse(fields[raCol]);
      final dec = double.tryParse(fields[decCol]);
      final vt = double.tryParse(fields[vtCol]);
      final t1 = int.tryParse(fields[tyc1]);
      final t2 = int.tryParse(fields[tyc2]);
      final t3 = int.tryParse(fields[tyc3]);
      if (ra == null || dec == null || vt == null) continue;
      if (t1 == null || t2 == null || t3 == null) continue;

      final bt = btCol == null ? null : double.tryParse(fields[btCol]);
      final double magnitude;
      final double? bv;
      if (bt == null) {
        magnitude = vt;
        bv = null;
      } else {
        final btVt = bt - vt;
        magnitude = vt - 0.090 * btVt;
        bv = 0.850 * btVt;
      }
      if (magnitude <= minMagnitudeExclusive ||
          magnitude > maxMagnitudeInclusive) {
        continue;
      }
      // Tile boundary consistency: follow the app-side tile assignment
      if (index.tileIndexOf(ra, dec) != tileIndex) continue;

      stars.add(
        Star(
          id: t1 * 200000 + t2 * 4 + t3,
          raDeg: ra,
          decDeg: dec,
          magnitude: magnitude,
          tileIndex: tileIndex,
          colorIndexBV: bv,
        ),
      );
    }
    return stars;
  }

  static bool _isRetryable(DioException e) {
    final status = e.response?.statusCode;
    return status == null || status >= 500;
  }
}
