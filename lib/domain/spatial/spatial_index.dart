import 'dart:math' as math;

import '../models/sky_point.dart';

/// Spatial index of the celestial sphere (RA/Dec grid scheme, functional design A1).
///
/// Splits declination into 12 bands of 15° each, and sets the number of RA
/// divisions per band to `max(1, round(24cos(decCenter)))` to roughly equalize
/// tile areas. 184 tiles over the whole sky. Tile numbers are treated as opaque
/// integers outside this class so a future HEALPix implementation can replace it.
class SpatialIndex {
  SpatialIndex() {
    _raDivisions = List.generate(bandCount, (band) {
      final decCenterDeg = -90.0 + bandHeightDeg * band + bandHeightDeg / 2;
      final divisions = (24 * math.cos(decCenterDeg * _d2r)).round();
      return math.max(1, divisions);
    });
    _bandOffsets = List.filled(bandCount, 0);
    var offset = 0;
    for (var band = 0; band < bandCount; band++) {
      _bandOffsets[band] = offset;
      offset += _raDivisions[band];
    }
    _tileCount = offset;
  }

  static const double _d2r = math.pi / 180.0;
  static const int bandCount = 12;
  static const double bandHeightDeg = 15.0;

  late final List<int> _raDivisions;
  late final List<int> _bandOffsets;
  late final int _tileCount;

  /// Total number of tiles over the whole sky
  int get tileCount => _tileCount;

  /// Tile number containing the given coordinates
  int tileIndexOf(double raDeg, double decDeg) {
    final band = _bandOf(decDeg);
    final divisions = _raDivisions[band];
    final ra = SkyPoint.normalizeRa(raDeg);
    final raIdx = (ra / 360.0 * divisions).floor() % divisions;
    return _bandOffsets[band] + raIdx;
  }

  /// Celestial coordinates of the tile center
  SkyPoint tileCenter(int tileIndex) {
    final (band, raIdx) = _decompose(tileIndex);
    final decCenter = -90.0 + bandHeightDeg * band + bandHeightDeg / 2;
    final raWidth = 360.0 / _raDivisions[band];
    return SkyPoint(raWidth * raIdx + raWidth / 2, decCenter);
  }

  /// RA/Dec rectangle of a tile (for range queries against external catalogs).
  ///
  /// RA: [raMinDeg, raMaxDeg), Dec: [decMinDeg, decMaxDeg).
  /// Tiles never straddle the RA 0°/360° boundary.
  ({double raMinDeg, double raMaxDeg, double decMinDeg, double decMaxDeg})
  tileBounds(int tileIndex) {
    final (band, raIdx) = _decompose(tileIndex);
    final raWidth = 360.0 / _raDivisions[band];
    return (
      raMinDeg: raWidth * raIdx,
      raMaxDeg: raWidth * (raIdx + 1),
      decMinDeg: -90.0 + bandHeightDeg * band,
      decMaxDeg: -90.0 + bandHeightDeg * (band + 1),
    );
  }

  /// Angular radius of a tile [deg] (conservative upper bound from center to farthest point)
  double tileAngularRadiusDeg(int tileIndex) {
    final (band, _) = _decompose(tileIndex);
    final raHalfDeg = 180.0 / _raDivisions[band];
    // Declination within the band closest to the equator (where the angular distance along RA is greatest)
    final decEdge1 = (-90.0 + bandHeightDeg * band).abs();
    final decEdge2 = (-90.0 + bandHeightDeg * (band + 1)).abs();
    final cosMax = math.cos(math.min(decEdge1, decEdge2) * _d2r);
    final raExtent = raHalfDeg * cosMax;
    const decHalf = bandHeightDeg / 2;
    return math.sqrt(decHalf * decHalf + raExtent * raExtent);
  }

  /// Enumerates tile numbers intersecting the viewport.
  ///
  /// Angular-distance scheme: include tiles closer than the sum of the FOV
  /// diagonal radius (+15% margin) and the tile's angular radius. No special
  /// cases needed at the RA 0°/360° boundary or the celestial poles.
  /// Takes primitives to stay dart:ui-independent (also used by conversion scripts).
  List<int> tilesInViewport({
    required SkyPoint center,
    required double fovDeg,
    required double aspectRatio,
  }) {
    final halfV = fovDeg / 2;
    final halfH = halfV * (aspectRatio <= 0 ? 1.0 : aspectRatio);
    final halfDiag = math.min(
      180.0,
      math.sqrt(halfV * halfV + halfH * halfH) * 1.15,
    );

    final result = <int>[];
    for (var tile = 0; tile < _tileCount; tile++) {
      final distance = center.angularDistanceTo(tileCenter(tile));
      if (distance <= halfDiag + tileAngularRadiusDeg(tile)) {
        result.add(tile);
      }
    }
    return result;
  }

  int _bandOf(double decDeg) =>
      ((decDeg + 90.0) / bandHeightDeg).floor().clamp(0, bandCount - 1);

  (int, int) _decompose(int tileIndex) {
    assert(tileIndex >= 0 && tileIndex < _tileCount, 'invalid tile index');
    var band = bandCount - 1;
    while (_bandOffsets[band] > tileIndex) {
      band--;
    }
    return (band, tileIndex - _bandOffsets[band]);
  }
}
