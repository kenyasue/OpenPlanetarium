// VizieR → additional nebula catalog asset (assets/catalogs/dso_extra.json) conversion script
//
// Usage:
//   dart run tool/catalog_converter/convert_dso_extra.dart
//
// Fetched catalogs (CDS VizieR TAP):
//   - Sh2: VII/20  (Sharpless 1959, 313 HII regions; galactic → J2000 conversion)
//   - LBN: VII/9   (Lynds 1965, 1,125 bright nebulae)
//   - LDN: VII/7A  (Lynds 1962, about 1,800 dark nebulae)
//   - vdB: VII/21  (van den Bergh 1966, 158 reflection nebulae)
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _tap = 'https://tapvizier.cds.unistra.fr/TAPVizieR/tap/sync';
const _d2r = math.pi / 180.0;
const _r2d = 180.0 / math.pi;

Future<void> main() async {
  final objects = <Map<String, dynamic>>[
    ...await _fetchSh2(),
    ...await _fetchLbn(),
    ...await _fetchLdn(),
    ...await _fetchVdb(),
  ];

  final out = File('assets/catalogs/dso_extra.json');
  out.writeAsStringSync(jsonEncode({'objects': objects}));
  stdout.writeln(
    'Conversion complete: ${objects.length} objects / ${out.lengthSync()} bytes',
  );
}

/// Returns SELECT results as a list of rows mapping header name → value.
///
/// VizieR computed columns (_RA_icrs etc.) cannot be referenced by name in
/// ADQL, so we fetch with SELECT * and resolve column positions from the header.
Future<List<Map<String, String>>> _queryMaps(String adql) async {
  final rows = await _query(adql);
  final header = rows.first;
  return [
    for (final row in rows.skip(1))
      if (row.length >= header.length)
        {for (var i = 0; i < header.length; i++) header[i]: row[i]},
  ];
}

Future<List<List<String>>> _query(String adql) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(_tap).replace(
      queryParameters: {
        'REQUEST': 'doQuery',
        'LANG': 'ADQL',
        'FORMAT': 'csv',
        'MAXREC': '100000',
        'QUERY': adql,
      },
    );
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('TAP error ${response.statusCode}: $adql');
    }
    final body = await response.transform(utf8.decoder).join();
    final lines = body
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return [for (final line in lines) line.split(',')];
  } finally {
    client.close();
  }
}

/// Galactic coordinates (IAU definition, J2000 system) → equatorial J2000 [deg]
(double, double) _galacticToEquatorial(double lDeg, double bDeg) {
  const raNgp = 192.85948 * _d2r;
  const decNgp = 27.12825 * _d2r;
  const lNcp = 122.93192 * _d2r;
  final l = lDeg * _d2r;
  final b = bDeg * _d2r;

  final sinDec =
      math.sin(decNgp) * math.sin(b) +
      math.cos(decNgp) * math.cos(b) * math.cos(lNcp - l);
  final dec = math.asin(sinDec.clamp(-1.0, 1.0));
  final ra =
      raNgp +
      math.atan2(
        math.cos(b) * math.sin(lNcp - l),
        math.cos(decNgp) * math.sin(b) -
            math.sin(decNgp) * math.cos(b) * math.cos(lNcp - l),
      );
  var raDeg = ra * _r2d % 360.0;
  if (raDeg < 0) raDeg += 360.0;
  return (raDeg, dec * _r2d);
}

double _round4(double v) => (v * 10000).roundToDouble() / 10000;

Future<List<Map<String, dynamic>>> _fetchSh2() async {
  final rows = await _query('SELECT Sh2,GLon,GLat,Diam FROM "VII/20/catalog"');
  final objects = <Map<String, dynamic>>[];
  for (final row in rows.skip(1)) {
    final num_ = int.tryParse(row[0]);
    final l = double.tryParse(row[1]);
    final b = double.tryParse(row[2]);
    final diam = double.tryParse(row[3]);
    if (num_ == null || l == null || b == null) continue;
    final (ra, dec) = _galacticToEquatorial(l, b);
    objects.add({
      'id': 'SH2-$num_',
      'type': 'nebula',
      'ra': _round4(ra),
      'dec': _round4(dec),
      if (diam != null && diam > 0) 'majAx': diam,
    });
  }
  stdout.writeln('Sh2: ${objects.length}');
  return objects;
}

Future<List<Map<String, dynamic>>> _fetchLbn() async {
  final rows = await _queryMaps('SELECT * FROM "VII/9/catalog"');
  final objects = <Map<String, dynamic>>[];
  for (final row in rows) {
    final num_ = int.tryParse(row['Seq'] ?? '');
    final d1 = double.tryParse(row['Diam1'] ?? '');
    final d2 = double.tryParse(row['Diam2'] ?? '');
    final ra = double.tryParse(row['_RA_icrs'] ?? '');
    final dec = double.tryParse(row['_DE_icrs'] ?? '');
    if (num_ == null || ra == null || dec == null) continue;
    objects.add({
      'id': 'LBN$num_',
      'type': 'nebula',
      'ra': _round4(ra),
      'dec': _round4(dec),
      if (d1 != null && d1 > 0) 'majAx': d1,
      if (d2 != null && d2 > 0) 'minAx': d2,
    });
  }
  stdout.writeln('LBN: ${objects.length}');
  return objects;
}

Future<List<Map<String, dynamic>>> _fetchLdn() async {
  final rows = await _queryMaps('SELECT * FROM "VII/7A/ldn"');
  final objects = <Map<String, dynamic>>[];
  final seen = <int>{};
  for (final row in rows) {
    final num_ = int.tryParse(row['LDN'] ?? '');
    final areaSqDeg = double.tryParse(row['Area'] ?? '');
    final ra = double.tryParse(row['_RA_icrs'] ?? '');
    final dec = double.tryParse(row['_DE_icrs'] ?? '');
    if (num_ == null || ra == null || dec == null) continue;
    // For numbers split across rows, keep only the first
    if (!seen.add(num_)) continue;
    // Area [sq deg] → diameter of the equivalent circle [arcmin]
    final diamArcmin = areaSqDeg == null || areaSqDeg <= 0
        ? null
        : 2.0 * math.sqrt(areaSqDeg / math.pi) * 60.0;
    objects.add({
      'id': 'LDN$num_',
      'type': 'darkNebula',
      'ra': _round4(ra),
      'dec': _round4(dec),
      if (diamArcmin != null) 'majAx': _round4(diamArcmin),
    });
  }
  stdout.writeln('LDN: ${objects.length}');
  return objects;
}

Future<List<Map<String, dynamic>>> _fetchVdb() async {
  final rows = await _queryMaps('SELECT * FROM "VII/21/catalog"');
  final objects = <Map<String, dynamic>>[];
  for (final row in rows) {
    final num_ = int.tryParse(row['VdB'] ?? '');
    final vmag = double.tryParse(row['Vmag'] ?? '');
    final radArcmin = double.tryParse(row['BRadMax'] ?? '');
    // For VII/21, VizieR computed columns return ICRS coordinates as _RA/_DE
    // (equivalent to _RA_icrs in other tables)
    final ra = double.tryParse(row['_RA'] ?? '');
    final dec = double.tryParse(row['_DE'] ?? '');
    if (num_ == null || ra == null || dec == null) continue;
    objects.add({
      'id': 'VDB$num_',
      'type': 'nebula',
      'ra': _round4(ra),
      'dec': _round4(dec),
      // V magnitude of the illuminating star (used as a rough display gate)
      if (vmag != null) 'mag': vmag,
      if (radArcmin != null && radArcmin > 0) 'majAx': radArcmin * 2,
    });
  }
  stdout.writeln('vdB: ${objects.length}');
  return objects;
}
