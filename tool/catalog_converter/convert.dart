// HYG v4.1 CSV → tiled binary (assets/catalogs/bsc_tiles.bin) conversion script
//
// Usage:
//   1. Place tool/catalog_converter/cache/hygdata_v41.csv
//      (obtained from https://github.com/astronexus/HYG-Database)
//   2. dart run tool/catalog_converter/convert.dart
//
// Output:
//   - assets/catalogs/bsc_tiles.bin   (stars with mag <= 6.5, split into tiles)
//   - assets/catalogs/star_names.json (proper names, id → name)
//
// The HYG database is CC BY-SA 4.0 (David Nash, astronexus.com).
// Attribution is shown in the app's settings screen (M5).
import 'dart:convert';
import 'dart:io';

import 'package:open_planetarium/data/catalog/tile_binary_codec.dart';
import 'package:open_planetarium/domain/models/star.dart';
import 'package:open_planetarium/domain/spatial/spatial_index.dart';

const double limitingMagnitude = 6.5;

void main() {
  final csvFile = File('tool/catalog_converter/cache/hygdata_v41.csv');
  if (!csvFile.existsSync()) {
    stderr.writeln('Input CSV not found: ${csvFile.path}');
    exit(1);
  }

  final lines = csvFile.readAsLinesSync();
  final header = _splitCsvLine(lines.first);
  final col = {for (var i = 0; i < header.length; i++) header[i]: i};

  final index = SpatialIndex();
  final tiles = <int, List<Star>>{};
  final names = <int, String>{};
  var total = 0;
  var skipped = 0;

  for (final line in lines.skip(1)) {
    final fields = _splitCsvLine(line);
    try {
      final id = int.parse(fields[col['id']!]);
      // id=0 is the Sun (solar system objects are handled in M4)
      if (id == 0) continue;

      final mag = double.parse(fields[col['mag']!]);
      if (mag > limitingMagnitude) continue;

      final raDeg = double.parse(fields[col['ra']!]) * 15.0; // hours → degrees
      final decDeg = double.parse(fields[col['dec']!]);
      final ciRaw = fields[col['ci']!];
      final bv = ciRaw.isEmpty ? null : double.tryParse(ciRaw);
      final proper = fields[col['proper']!];

      final tileIndex = index.tileIndexOf(raDeg, decDeg);
      tiles
          .putIfAbsent(tileIndex, () => [])
          .add(
            Star(
              id: id,
              raDeg: raDeg,
              decDeg: decDeg,
              magnitude: mag,
              tileIndex: tileIndex,
              colorIndexBV: bv,
            ),
          );
      if (proper.isNotEmpty) names[id] = proper;
      total++;
    } on FormatException {
      skipped++; // Skip rows with missing data (count only)
    } on RangeError {
      skipped++;
    }
  }

  // Sort stars within each tile by brightness (for rendering and filtering efficiency)
  for (final stars in tiles.values) {
    stars.sort((a, b) => a.magnitude.compareTo(b.magnitude));
  }

  final outDir = Directory('assets/catalogs')..createSync(recursive: true);
  final binFile = File('${outDir.path}/bsc_tiles.bin');
  binFile.writeAsBytesSync(const TileBinaryCodec().encode(tiles));

  final namesFile = File('${outDir.path}/star_names.json');
  namesFile.writeAsStringSync(
    const JsonEncoder.withIndent(
      null,
    ).convert(names.map((k, v) => MapEntry(k.toString(), v))),
  );

  stdout.writeln(
    'Conversion complete: $total stars / ${tiles.length} tiles / '
    '${names.length} proper names / $skipped rows skipped',
  );
  stdout.writeln('Output: ${binFile.path} (${binFile.lengthSync()} bytes)');
}

/// Minimal CSV parser (HYG occasionally has quoted fields containing commas)
List<String> _splitCsvLine(String line) {
  final result = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
    } else if (ch == ',' && !inQuotes) {
      result.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(ch);
    }
  }
  result.add(buffer.toString());
  return result;
}
