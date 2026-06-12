// JPL SBDB → asteroid/comet asset (assets/catalogs/minor_bodies.json) conversion script
//
// Usage:
//   dart run tool/catalog_converter/convert_minor_bodies.dart
//
// Data source: JPL Small-Body Database Query API (official, no auth)
//   https://ssd-api.jpl.nasa.gov/doc/sbdb_query.html
//   - Asteroids: H<8 and a<6au (bright major asteroids, TNOs excluded)
//   - Comets: M1<13, e<0.99, epoch>JD2459000 (periodic comets with current orbital elements)
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _api = 'https://ssd-api.jpl.nasa.gov/sbdb_query.api';

Future<void> main() async {
  final asteroids = await _fetchAsteroids();
  final comets = await _fetchComets();
  final bodies = [...asteroids, ...comets];

  final out = File('assets/catalogs/minor_bodies.json');
  out.writeAsStringSync(jsonEncode({'bodies': bodies}));
  stdout.writeln(
    'Conversion complete: ${asteroids.length} asteroids + ${comets.length} comets '
    '/ ${out.lengthSync()} bytes',
  );
}

Future<Map<String, dynamic>> _queryJson(Map<String, String> params) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(_api).replace(queryParameters: params);
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('SBDB error ${response.statusCode}');
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

double? _toDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());

Future<List<Map<String, dynamic>>> _fetchAsteroids() async {
  final json = await _queryJson({
    'fields': 'spkid,full_name,e,a,i,om,w,ma,epoch,H',
    'sb-kind': 'a',
    'sb-cdata': '{"AND":["H|LT|8","a|LT|6"]}',
  });
  final bodies = <Map<String, dynamic>>[];
  for (final row in json['data'] as List<dynamic>) {
    final r = row as List<dynamic>;
    final name = (r[1] as String).trim().replaceAll(RegExp(r'\s+'), ' ');
    final e = _toDouble(r[2]);
    final a = _toDouble(r[3]);
    final h = _toDouble(r[9]);
    if (e == null || a == null || h == null) continue;
    // Strip the provisional designation ('1 Ceres (A801 AA)' → '1 Ceres')
    final cleanName = name.replaceAll(RegExp(r'\s*\([^)]*\)$'), '');
    bodies.add({
      'kind': 'asteroid',
      'id': r[0].toString(),
      'name': cleanName,
      if (_jaNames[cleanName] != null) 'ja': _jaNames[cleanName],
      'a': a,
      'e': e,
      'i': _toDouble(r[4]),
      'om': _toDouble(r[5]),
      'w': _toDouble(r[6]),
      'ma': _toDouble(r[7]),
      'epoch': _toDouble(r[8]),
      'mag1': h,
      'mag2': 0,
    });
  }
  return bodies;
}

Future<List<Map<String, dynamic>>> _fetchComets() async {
  final json = await _queryJson({
    'fields': 'spkid,full_name,e,q,i,om,w,tp,epoch,M1,K1',
    'sb-kind': 'c',
    'sb-cdata': '{"AND":["M1|LT|13","e|LT|0.99","epoch|GT|2459000"]}',
  });
  final bodies = <Map<String, dynamic>>[];
  for (final row in json['data'] as List<dynamic>) {
    final r = row as List<dynamic>;
    final name = (r[1] as String).trim().replaceAll(RegExp(r'\s+'), ' ');
    final e = _toDouble(r[2]);
    final q = _toDouble(r[3]);
    final tp = _toDouble(r[7]);
    final epoch = _toDouble(r[8]);
    final m1 = _toDouble(r[9]);
    if (e == null || q == null || tp == null || epoch == null || m1 == null) {
      continue;
    }
    // Just in case (near-parabolic orbits are not propagated)
    if (e >= 0.99) continue;
    final a = q / (1.0 - e);
    // Mean anomaly at epoch: M0 = n × (epoch − tp)
    final n = 0.9856076686 / math.pow(a, 1.5);
    var ma = (n * (epoch - tp)) % 360.0;
    if (ma < 0) ma += 360.0;
    bodies.add({
      'kind': 'comet',
      'id': r[0].toString(),
      'name': name,
      if (_jaNames[name] != null) 'ja': _jaNames[name],
      'a': _round6(a),
      'e': e,
      'i': _toDouble(r[4]),
      'om': _toDouble(r[5]),
      'w': _toDouble(r[6]),
      'ma': _round6(ma),
      'epoch': epoch,
      'mag1': m1,
      // When K1 is missing, assume the standard brightness slope of 8
      'mag2': _toDouble(r[10]) ?? 8.0,
    });
  }
  return bodies;
}

double _round6(double v) => (v * 1e6).roundToDouble() / 1e6;

/// Japanese names of well-known minor bodies.
/// The values are Japanese object-name DATA written to the 'ja' field;
/// they must remain in Japanese.
const Map<String, String> _jaNames = {
  '1 Ceres': 'ケレス',
  '2 Pallas': 'パラス',
  '3 Juno': 'ジュノー',
  '4 Vesta': 'ベスタ',
  '2P/Encke': 'エンケ彗星',
  '12P/Pons-Brooks': 'ポン・ブルックス彗星',
  '19P/Borrelly': 'ボレリー彗星',
  '67P/Churyumov-Gerasimenko': 'チュリュモフ・ゲラシメンコ彗星',
};
