// Stellarium modern sky culture + HYG → constellation asset conversion script
//
// Usage:
//   1. Place the following in tool/catalog_converter/cache/
//      - modern_skyculture.json (https://github.com/Stellarium/stellarium
//        skycultures/modern/index.json)
//      - hygdata_v41.csv (used to resolve HIP → J2000 coordinates)
//
// Data sources and licenses:
//   - Constellation lines: Stellarium modern sky culture (GPL-2.0+). The line
//     connections are a common star-chart representation, used as HIP number sequences
//   - IAU constellation boundaries: official determination by Delporte (1930)
//     (factual data). The edges are boundary coordinates at epoch B1875
//   - HYG Database v4.1 (David Nash, astronexus.com): CC BY-SA 4.0
//   - B1875.0 = JD 2405889.25858 is the Besselian year epoch definition
//     (Lieske 1979, A&A 73, 282; B = 1900.0 + (JD-2415020.31352)/365.242198781)
//   2. dart run tool/catalog_converter/convert_constellations.dart
//
// Output: assets/catalogs/constellations.json
//   { constellations: [{iau, la, en, ja, labelRa, labelDec, lines: [[[ra,dec],..],..]}],
//     boundaries: [[[ra,dec],..], ...] }   All coordinates are J2000 [deg]
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _d2r = math.pi / 180.0;
const _r2d = 180.0 / math.pi;

void main() {
  final skyculture =
      jsonDecode(
            File(
              'tool/catalog_converter/cache/modern_skyculture.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final hipPositions = _loadHipPositions(
    'tool/catalog_converter/cache/hygdata_v41.csv',
  );

  final constellations = <Map<String, dynamic>>[];
  var missingHip = 0;

  for (final raw in skyculture['constellations'] as List<dynamic>) {
    final con = raw as Map<String, dynamic>;
    final id = con['id'] as String; // 'CON modern Aql'
    final iau = id.split(' ').last;
    final commonName = con['common_name'] as Map<String, dynamic>?;
    final latin = (commonName?['native'] ?? iau) as String;
    final english = (commonName?['english'] ?? latin) as String;
    final japanese = _japaneseNames[iau];
    if (japanese == null) {
      stderr.writeln('Warning: no Japanese name defined for $iau');
    }

    final lines = <List<List<double>>>[];
    final vertices = <List<double>>[]; // For label position calculation
    for (final lineRaw in (con['lines'] ?? const []) as List<dynamic>) {
      final polyline = <List<double>>[];
      for (final hipRaw in lineRaw as List<dynamic>) {
        final pos = hipPositions[hipRaw as int];
        if (pos == null) {
          missingHip++;
          continue;
        }
        polyline.add([_round4(pos.$1), _round4(pos.$2)]);
        vertices.add([pos.$1, pos.$2]);
      }
      if (polyline.length >= 2) lines.add(polyline);
    }

    final label = _meanDirection(vertices);
    constellations.add({
      'iau': iau,
      'la': latin,
      'en': english,
      'ja': japanese ?? latin,
      'labelRa': _round4(label.$1),
      'labelDec': _round4(label.$2),
      'lines': lines,
    });
  }

  final boundaries = _convertBoundaries(
    (skyculture['edges'] as List<dynamic>).cast<String>(),
  );

  final out = File('assets/catalogs/constellations.json')
    ..parent.createSync(recursive: true);
  out.writeAsStringSync(
    jsonEncode({'constellations': constellations, 'boundaries': boundaries}),
  );

  stdout.writeln(
    'Conversion complete: ${constellations.length} constellations / '
    '${boundaries.length} boundary polylines / $missingHip unresolved HIP / '
    '${out.lengthSync()} bytes',
  );
}

/// Loads HIP → (raDeg, decDeg) from the HYG CSV
Map<int, (double, double)> _loadHipPositions(String path) {
  final result = <int, (double, double)>{};
  final lines = File(path).readAsLinesSync();
  for (final line in lines.skip(1)) {
    // Lightweight parse of only the needed columns: id(0), hip(1), ra(7), dec(8).
    // Quoted fields could appear before column 7 (proper etc. is column 6),
    // so the first 9 fields are not guaranteed safe with a plain comma split;
    // use quote-aware splitting in case proper contains a quoted comma.
    final fields = _splitCsvLine(line);
    final hipStr = fields[1];
    if (hipStr.isEmpty) continue;
    final hip = int.tryParse(hipStr);
    if (hip == null) continue;
    final ra = double.tryParse(fields[7]);
    final dec = double.tryParse(fields[8]);
    if (ra == null || dec == null) continue;
    result[hip] = (ra * 15.0, dec); // hours → degrees
  }
  return result;
}

/// Converts IAU boundary edges (B1875) to J2000 polylines.
///
/// Edge format: "001:002 M+ 22:52:00 +34:30:00 22:52:00 +52:30:00 AND LAC"
/// Each edge is interpolated in B1875 at intervals of at most 1°, and each
/// point is precessed.
List<List<List<double>>> _convertBoundaries(List<String> edges) {
  final result = <List<List<double>>>[];
  for (final edge in edges) {
    final tokens = edge.split(RegExp(r'\s+'));
    if (tokens.length < 6) continue;
    final ra1 = _parseHms(tokens[2]);
    final dec1 = _parseDms(tokens[3]);
    final ra2 = _parseHms(tokens[4]);
    final dec2 = _parseDms(tokens[5]);

    // Interpolate the RA difference along the shortest direction (wrap-aware)
    var dRa = ra2 - ra1;
    if (dRa > 180) dRa -= 360;
    if (dRa < -180) dRa += 360;
    final dDec = dec2 - dec1;
    final span = math.max(dRa.abs(), dDec.abs());
    final steps = math.max(1, (span / 1.0).ceil());

    final polyline = <List<double>>[];
    for (var i = 0; i <= steps; i++) {
      final f = i / steps;
      final p = _precessB1875ToJ2000(ra1 + dRa * f, dec1 + dDec * f);
      polyline.add([_round4(p.$1), _round4(p.$2)]);
    }
    result.add(polyline);
  }
  return result;
}

/// Coordinate transform B1875.0 → J2000.0 using IAU 1976 precession
/// (Meeus chapter 21, eqs. 21.2/21.3/21.4).
(double, double) _precessB1875ToJ2000(double raDeg, double decDeg) {
  // B1875.0 = JD 2405889.25858 (Besselian year epoch)
  const jd1 = 2405889.25858;
  const jd2 = 2451545.0; // J2000.0
  const bigT = (jd1 - 2451545.0) / 36525.0;
  const t = (jd2 - jd1) / 36525.0;

  // [arcsec] → [rad]
  const zeta =
      ((2306.2181 + 1.39656 * bigT - 0.000139 * bigT * bigT) * t +
          (0.30188 - 0.000344 * bigT) * t * t +
          0.017998 * t * t * t) /
      3600.0 *
      _d2r;
  const z =
      ((2306.2181 + 1.39656 * bigT - 0.000139 * bigT * bigT) * t +
          (1.09468 + 0.000066 * bigT) * t * t +
          0.018203 * t * t * t) /
      3600.0 *
      _d2r;
  const theta =
      ((2004.3109 - 0.85330 * bigT - 0.000217 * bigT * bigT) * t -
          (0.42665 + 0.000217 * bigT) * t * t -
          0.041833 * t * t * t) /
      3600.0 *
      _d2r;

  final ra = raDeg * _d2r;
  final dec = decDeg * _d2r;
  final a = math.cos(dec) * math.sin(ra + zeta);
  final b =
      math.cos(theta) * math.cos(dec) * math.cos(ra + zeta) -
      math.sin(theta) * math.sin(dec);
  final c =
      math.sin(theta) * math.cos(dec) * math.cos(ra + zeta) +
      math.cos(theta) * math.sin(dec);

  var newRa = (math.atan2(a, b) + z) * _r2d;
  newRa %= 360.0;
  if (newRa < 0) newRa += 360.0;
  final newDec = math.asin(c.clamp(-1.0, 1.0)) * _r2d;
  return (newRa, newDec);
}

/// 'hh:mm:ss' → degrees
double _parseHms(String hms) {
  final parts = hms.split(':').map(double.parse).toList();
  return (parts[0] + parts[1] / 60.0 + parts[2] / 3600.0) * 15.0;
}

/// '±dd:mm:ss' → degrees
double _parseDms(String dms) {
  final sign = dms.startsWith('-') ? -1.0 : 1.0;
  final parts = dms
      .replaceFirst(RegExp(r'^[+-]'), '')
      .split(':')
      .map(double.parse)
      .toList();
  return sign * (parts[0] + parts[1] / 60.0 + parts[2] / 3600.0);
}

/// Mean direction of a set of vertices (unit-vector average, RA wrap-safe)
(double, double) _meanDirection(List<List<double>> vertices) {
  if (vertices.isEmpty) return (0, 0);
  var x = 0.0, y = 0.0, z = 0.0;
  for (final v in vertices) {
    final ra = v[0] * _d2r;
    final dec = v[1] * _d2r;
    x += math.cos(dec) * math.cos(ra);
    y += math.cos(dec) * math.sin(ra);
    z += math.sin(dec);
  }
  final norm = math.sqrt(x * x + y * y + z * z);
  if (norm < 1e-9) return (0, 0);
  var ra = math.atan2(y, x) * _r2d;
  if (ra < 0) ra += 360.0;
  final dec = math.asin((z / norm).clamp(-1.0, 1.0)) * _r2d;
  return (ra, dec);
}

double _round4(double v) => (v * 10000).roundToDouble() / 10000;

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

/// Japanese names of the 88 constellations (IAU abbreviation → Japanese).
/// The values are Japanese constellation-name DATA written to the 'ja' field;
/// they must remain in Japanese.
const Map<String, String> _japaneseNames = {
  'And': 'アンドロメダ座',
  'Ant': 'ポンプ座',
  'Aps': 'ふうちょう座',
  'Aqr': 'みずがめ座',
  'Aql': 'わし座',
  'Ara': 'さいだん座',
  'Ari': 'おひつじ座',
  'Aur': 'ぎょしゃ座',
  'Boo': 'うしかい座',
  'Cae': 'ちょうこくぐ座',
  'Cam': 'きりん座',
  'Cnc': 'かに座',
  'CVn': 'りょうけん座',
  'CMa': 'おおいぬ座',
  'CMi': 'こいぬ座',
  'Cap': 'やぎ座',
  'Car': 'りゅうこつ座',
  'Cas': 'カシオペヤ座',
  'Cen': 'ケンタウルス座',
  'Cep': 'ケフェウス座',
  'Cet': 'くじら座',
  'Cha': 'カメレオン座',
  'Cir': 'コンパス座',
  'Col': 'はと座',
  'Com': 'かみのけ座',
  'CrA': 'みなみのかんむり座',
  'CrB': 'かんむり座',
  'Crv': 'からす座',
  'Crt': 'コップ座',
  'Cru': 'みなみじゅうじ座',
  'Cyg': 'はくちょう座',
  'Del': 'いるか座',
  'Dor': 'かじき座',
  'Dra': 'りゅう座',
  'Equ': 'こうま座',
  'Eri': 'エリダヌス座',
  'For': 'ろ座',
  'Gem': 'ふたご座',
  'Gru': 'つる座',
  'Her': 'ヘルクレス座',
  'Hor': 'とけい座',
  'Hya': 'うみへび座',
  'Hyi': 'みずへび座',
  'Ind': 'インディアン座',
  'Lac': 'とかげ座',
  'Leo': 'しし座',
  'LMi': 'こじし座',
  'Lep': 'うさぎ座',
  'Lib': 'てんびん座',
  'Lup': 'おおかみ座',
  'Lyn': 'やまねこ座',
  'Lyr': 'こと座',
  'Men': 'テーブルさん座',
  'Mic': 'けんびきょう座',
  'Mon': 'いっかくじゅう座',
  'Mus': 'はえ座',
  'Nor': 'じょうぎ座',
  'Oct': 'はちぶんぎ座',
  'Oph': 'へびつかい座',
  'Ori': 'オリオン座',
  'Pav': 'くじゃく座',
  'Peg': 'ペガスス座',
  'Per': 'ペルセウス座',
  'Phe': 'ほうおう座',
  'Pic': 'がか座',
  'Psc': 'うお座',
  'PsA': 'みなみのうお座',
  'Pup': 'とも座',
  'Pyx': 'らしんばん座',
  'Ret': 'レチクル座',
  'Sge': 'や座',
  'Sgr': 'いて座',
  'Sco': 'さそり座',
  'Scl': 'ちょうこくしつ座',
  'Sct': 'たて座',
  'Ser': 'へび座',
  'Sex': 'ろくぶんぎ座',
  'Tau': 'おうし座',
  'Tel': 'ぼうえんきょう座',
  'Tri': 'さんかく座',
  'TrA': 'みなみのさんかく座',
  'Tuc': 'きょしちょう座',
  'UMa': 'おおぐま座',
  'UMi': 'こぐま座',
  'Vel': 'ほ座',
  'Vir': 'おとめ座',
  'Vol': 'とびうお座',
  'Vul': 'こぎつね座',
};
