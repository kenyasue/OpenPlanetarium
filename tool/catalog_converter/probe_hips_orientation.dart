// Probe for verifying the orientation of HiPS tile images.
//
// Prints the tile containing the Pleiades (M45) and its in-tile coordinates
// (fx, fy). Compare against the position of M45 (image coordinates) in the
// downloaded tile image to pin down the SurveyRenderer UV mapping.
//
// Usage: dart run tool/catalog_converter/probe_hips_orientation.dart
import 'dart:io';

import 'package:open_planetarium/domain/spatial/healpix.dart';

void main() {
  // M45 (Pleiades): RA 56.85°, Dec 24.12°
  const ra = 56.85;
  const dec = 24.12;

  for (final order in [4, 5]) {
    final pix = Healpix.ang2pixNest(order, ra, dec);
    // Numerically search for (fx, fy) within the tile (nearest on a 64×64 grid)
    var bestFx = 0.0, bestFy = 0.0, bestDist = 999.0;
    for (var i = 0; i <= 64; i++) {
      for (var j = 0; j <= 64; j++) {
        final p = Healpix.pixGridPoint(order, pix, i / 64, j / 64);
        final d = _dist(p.raDeg, p.decDeg, ra, dec);
        if (d < bestDist) {
          bestDist = d;
          bestFx = i / 64;
          bestFy = j / 64;
        }
      }
    }
    final dir = (pix ~/ 10000) * 10000;
    stdout.writeln(
      'order=$order pix=$pix fx=${bestFx.toStringAsFixed(3)} '
      'fy=${bestFy.toStringAsFixed(3)} (dist=${bestDist.toStringAsFixed(4)}°)',
    );
    stdout.writeln(
      '  URL: https://alasky.cds.unistra.fr/DSS/DSSColor/'
      'Norder$order/Dir$dir/Npix$pix.jpg',
    );
    // Reference: celestial coordinates of the tile's 4 corners (to check corner orientation)
    final corners = Healpix.pixBoundary(order, pix);
    for (var c = 0; c < 4; c++) {
      final labels = ['(0,0)', '(1,0)', '(1,1)', '(0,1)'];
      stdout.writeln(
        '  corner f${labels[c]}: RA=${corners[c].raDeg.toStringAsFixed(2)} '
        'Dec=${corners[c].decDeg.toStringAsFixed(2)}',
      );
    }
  }
}

double _dist(double ra1, double dec1, double ra2, double dec2) {
  final dra = (ra1 - ra2).abs();
  final ddec = (dec1 - dec2).abs();
  return dra * 0.9 + ddec; // Rough distance (for searching)
}
