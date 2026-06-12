import 'dart:math' as math;

import '../models/sky_point.dart';

/// HEALPix (NESTED) geometry computations (for HiPS tiles, functional design A6).
///
/// Sources: Górski et al. (2005) ApJ 622, 759 and implementations equivalent to
/// ang2pix_nest / xyf2loc of healpix_base (healpix_cxx).
/// Independent of the star catalog's spatial index (RA/Dec grid) (docs/glossary.md).
class Healpix {
  const Healpix._();

  static const _d2r = math.pi / 180.0;
  static const _r2d = 180.0 / math.pi;

  /// Ring reference values for each base face (healpix_base jrll)
  static const _jrll = [2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4];

  /// Longitude reference values for each base face (healpix_base jpll)
  static const _jpll = [1, 3, 5, 7, 0, 2, 4, 6, 1, 3, 5, 7];

  /// Total number of tiles at the given order (12 × 4^order)
  static int npix(int order) => 12 << (2 * order);

  /// Celestial coordinates → NESTED tile number
  static int ang2pixNest(int order, double raDeg, double decDeg) {
    final nside = 1 << order;
    final z = math.sin(decDeg * _d2r); // z = cosθ = sin(dec)
    final phi = SkyPoint.normalizeRa(raDeg) * _d2r;
    final tt = (phi / (math.pi / 2)) % 4.0; // [0, 4)

    int face, ix, iy;
    if (z.abs() <= 2.0 / 3.0) {
      // Equatorial belt
      final temp1 = nside * (0.5 + tt);
      final temp2 = nside * (z * 0.75);
      final jp = (temp1 - temp2).floor();
      final jm = (temp1 + temp2).floor();
      final ifp = jp >> order;
      final ifm = jm >> order;
      if (ifp == ifm) {
        face = (ifp & 3) + 4;
      } else if (ifp < ifm) {
        face = ifp & 3;
      } else {
        face = (ifm & 3) + 8;
      }
      ix = jm & (nside - 1);
      iy = nside - (jp & (nside - 1)) - 1;
    } else {
      // Polar cap
      final ntt = math.min(3, tt.floor());
      final tp = tt - ntt;
      final tmp = nside * math.sqrt(3.0 * (1.0 - z.abs()));
      var jp = (tp * tmp).floor();
      var jm = ((1.0 - tp) * tmp).floor();
      jp = math.min(jp, nside - 1);
      jm = math.min(jm, nside - 1);
      if (z >= 0) {
        face = ntt;
        ix = nside - jm - 1;
        iy = nside - jp - 1;
      } else {
        face = ntt + 8;
        ix = jp;
        iy = jm;
      }
    }
    return (face << (2 * order)) + _interleave(ix, iy);
  }

  /// Boundary points of a tile (inverse projection from a NESTED tile's continuous face coordinates to the sphere).
  ///
  /// [steps]=1 returns the 4 corners only; >1 also returns points subdividing each edge (counterclockwise).
  static List<SkyPoint> pixBoundary(int order, int pix, {int steps = 1}) {
    final nside = 1 << order;
    final face = pix >> (2 * order);
    final inner = pix & ((1 << (2 * order)) - 1);
    final ix = _deinterleaveEven(inner);
    final iy = _deinterleaveEven(inner >> 1);

    SkyPoint at(double dx, double dy) =>
        _faceToSky(face, (ix + dx) / nside, (iy + dy) / nside);

    final points = <SkyPoint>[];
    for (var i = 0; i < steps; i++) {
      points.add(at(i / steps, 0));
    }
    for (var i = 0; i < steps; i++) {
      points.add(at(1, i / steps));
    }
    for (var i = 0; i < steps; i++) {
      points.add(at(1 - i / steps, 1));
    }
    for (var i = 0; i < steps; i++) {
      points.add(at(0, 1 - i / steps));
    }
    return points;
  }

  /// Maps a grid point within a tile (face coordinates (fx, fy) ∈ [0,1]²) to spherical coordinates.
  /// For SurveyRenderer's subdivided quad rendering.
  static SkyPoint pixGridPoint(int order, int pix, double fx, double fy) {
    final nside = 1 << order;
    final face = pix >> (2 * order);
    final inner = pix & ((1 << (2 * order)) - 1);
    final ix = _deinterleaveEven(inner);
    final iy = _deinterleaveEven(inner >> 1);
    return _faceToSky(face, (ix + fx) / nside, (iy + fy) / nside);
  }

  /// Celestial coordinates of the tile center
  static SkyPoint pixCenter(int order, int pix) =>
      pixGridPoint(order, pix, 0.5, 0.5);

  /// Returns the ancestor tile number and the child tile's grid position within the ancestor tile.
  ///
  /// Returns: (ancestor pix, child grid x, child grid y, grid size 2^k).
  /// In NESTED, the lower 2k bits are the bit-interleaved (x,y) within the ancestor.
  static (int, int, int, int) ancestor(int order, int pix, int ancestorOrder) {
    assert(ancestorOrder <= order, 'ancestorOrder must be <= order');
    final k = order - ancestorOrder;
    final ancestorPix = pix >> (2 * k);
    final subBits = pix & ((1 << (2 * k)) - 1);
    final subX = _deinterleaveEven(subBits);
    final subY = _deinterleaveEven(subBits >> 1);
    return (ancestorPix, subX, subY, 1 << k);
  }

  /// Face number and continuous face coordinates (x, y ∈ [0,1]) → celestial coordinates.
  /// Equivalent to healpix_base xyf2loc (continuous inverse HEALPix projection).
  static SkyPoint _faceToSky(int face, double x, double y) {
    final jr = _jrll[face] - x - y; // Ring coordinate (in nside=1 units)
    double z, nr;
    if (jr < 1) {
      nr = jr;
      z = 1.0 - nr * nr / 3.0;
    } else if (jr > 3) {
      nr = 4.0 - jr;
      z = nr * nr / 3.0 - 1.0;
    } else {
      nr = 1.0;
      z = (2.0 - jr) * 2.0 / 3.0;
    }
    var tmp = _jpll[face] * nr + x - y;
    if (tmp < 0) tmp += 8.0;
    if (tmp >= 8) tmp -= 8.0;
    final phi = nr < 1e-15 ? 0.0 : (0.5 * (math.pi / 2) * tmp) / nr;

    final decDeg = math.asin(z.clamp(-1.0, 1.0)) * _r2d;
    return SkyPoint(phi * _r2d, decDeg);
  }

  /// Spreads the low bits into even bit positions (z-order interleave)
  static int _interleave(int x, int y) {
    var result = 0;
    for (var i = 0; i < 16; i++) {
      result |= ((x >> i) & 1) << (2 * i);
      result |= ((y >> i) & 1) << (2 * i + 1);
    }
    return result;
  }

  /// Gathers even bit positions back into a value
  static int _deinterleaveEven(int v) {
    var result = 0;
    for (var i = 0; i < 16; i++) {
      result |= ((v >> (2 * i)) & 1) << i;
    }
    return result;
  }
}

/// Selects a HiPS order from the field of view (FOV) and screen resolution (functional design A6).
///
/// Picks the smallest order whose tile (512px) angular size ≈ 58.6° / 2^order
/// does not fall below the tile resolution on screen.
int chooseHipsOrder(double pxPerDeg, {int minOrder = 0, int maxOrder = 9}) {
  // Smallest order such that 58.6° × pxPerDeg ≤ 512 × 2^order
  final required = (math.log(58.6 * pxPerDeg / 512.0) / math.ln2).ceil();
  return required.clamp(minOrder, maxOrder);
}
