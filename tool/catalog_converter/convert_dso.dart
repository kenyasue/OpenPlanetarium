// OpenNGC → deep-sky object asset (assets/catalogs/dso.json) conversion script
//
// Usage:
//   1. Place the following in tool/catalog_converter/cache/
//      - openngc.csv / openngc_addendum.csv
//        (https://github.com/mattiaverga/OpenNGC database_files/, CC-BY-SA-4.0)
//   2. dart run tool/catalog_converter/convert_dso.dart
//
// Extraction criteria: all Messier objects + major objects (galaxies,
// clusters, nebulae) with V magnitude 10 or brighter
import 'dart:convert';
import 'dart:io';

void main() {
  final rows = <Map<String, String>>[];
  for (final path in [
    'tool/catalog_converter/cache/openngc.csv',
    'tool/catalog_converter/cache/openngc_addendum.csv',
  ]) {
    final lines = File(path).readAsLinesSync();
    final header = lines.first.split(';');
    for (final line in lines.skip(1)) {
      final fields = line.split(';');
      if (fields.length < header.length) continue;
      rows.add({for (var i = 0; i < header.length; i++) header[i]: fields[i]});
    }
  }

  final objects = <Map<String, dynamic>>[];
  var messierCount = 0;

  for (final row in rows) {
    final type = row['Type'] ?? '';
    var messier = int.tryParse(row['M'] ?? '');
    // M102: OpenNGC leaves the Messier assignment for NGC5866 open, but we
    // adopt the common identification (NGC5866 = M102) to complete 110 objects
    if (row['Name'] == 'NGC5866' && messier == null) messier = 102;

    // Exclude duplicates and non-existent entries. 'Other' (e.g. M73 = asterism)
    // is accepted only for Messier objects
    if (type == 'Dup' || type == 'NonEx') continue;
    if (type == 'Other' && messier == null) continue;
    final vMag = double.tryParse(row['V-Mag'] ?? '');
    final bMag = double.tryParse(row['B-Mag'] ?? '');
    final mag = vMag ?? bMag;
    final mappedType = _typeMap[type];

    // All Messier objects; others must be magnitude 10.5 or brighter with a
    // supported type (10.5: threshold chosen to include well-known objects
    // around V≈10.0 such as NGC891)
    final isMessier = messier != null;
    final isBright = mag != null && mag <= 10.5 && mappedType != null;
    if (!isMessier && !isBright) continue;

    final ra = _parseHms(row['RA'] ?? '');
    final dec = _parseDms(row['Dec'] ?? '');
    if (ra == null || dec == null) continue;

    final id = row['Name'] ?? '';
    final commonNames = (row['Common names'] ?? '').split(',');
    final commonName = commonNames.first.trim();

    if (isMessier) messierCount++;
    objects.add({
      'id': id,
      'type': (mappedType ?? 'other'),
      'ra': _round4(ra),
      'dec': _round4(dec),
      if (commonName.isNotEmpty) 'name': commonName,
      if (_japaneseNames[messier != null ? 'M$messier' : id] != null)
        'ja': _japaneseNames[messier != null ? 'M$messier' : id],
      if (mag != null) 'mag': mag,
      if ((row['MajAx'] ?? '').isNotEmpty)
        'majAx': double.tryParse(row['MajAx']!),
      if ((row['MinAx'] ?? '').isNotEmpty)
        'minAx': double.tryParse(row['MinAx']!),
      if ((row['Const'] ?? '').isNotEmpty) 'con': row['Const'],
      if (messier != null) 'm': messier,
    });
  }

  // Sort by magnitude (brightest first, missing values last)
  objects.sort((a, b) {
    final ma = (a['mag'] as double?) ?? 99.0;
    final mb = (b['mag'] as double?) ?? 99.0;
    return ma.compareTo(mb);
  });

  final out = File('assets/catalogs/dso.json');
  out.writeAsStringSync(jsonEncode({'objects': objects}));
  stdout.writeln(
    'Conversion complete: ${objects.length} objects '
    '(including $messierCount Messier) / ${out.lengthSync()} bytes',
  );
}

/// OpenNGC type → app ObjectType name
const Map<String, String> _typeMap = {
  'G': 'galaxy',
  'GPair': 'galaxy',
  'GTrpl': 'galaxy',
  'GGroup': 'galaxy',
  'OCl': 'openCluster',
  'GCl': 'globularCluster',
  'PN': 'planetaryNebula',
  'SNR': 'supernovaRemnant',
  'Neb': 'nebula',
  'EmN': 'nebula',
  'RfN': 'nebula',
  'HII': 'nebula',
  'Cl+N': 'nebula',
  'DrkN': 'nebula',
  'Nova': 'other',
  '*Ass': 'openCluster',
  'Cl*': 'openCluster',
};

/// 'hh:mm:ss.s' → degrees
double? _parseHms(String hms) {
  final parts = hms.split(':');
  if (parts.length != 3) return null;
  final h = double.tryParse(parts[0]);
  final m = double.tryParse(parts[1]);
  final s = double.tryParse(parts[2]);
  if (h == null || m == null || s == null) return null;
  return (h + m / 60.0 + s / 3600.0) * 15.0;
}

/// '±dd:mm:ss.s' → degrees
double? _parseDms(String dms) {
  if (dms.isEmpty) return null;
  final sign = dms.startsWith('-') ? -1.0 : 1.0;
  final parts = dms.replaceFirst(RegExp(r'^[+-]'), '').split(':');
  if (parts.length != 3) return null;
  final d = double.tryParse(parts[0]);
  final m = double.tryParse(parts[1]);
  final s = double.tryParse(parts[2]);
  if (d == null || m == null || s == null) return null;
  return sign * (d + m / 60.0 + s / 3600.0);
}

double _round4(double v) => (v * 10000).roundToDouble() / 10000;

/// Japanese names of famous objects (Messier number or ID → Japanese).
/// The values are Japanese object-name DATA written to the 'ja' field;
/// they must remain in Japanese.
const Map<String, String> _japaneseNames = {
  'M1': 'かに星雲',
  'M8': '干潟星雲',
  'M13': 'ヘルクレス座球状星団',
  'M16': 'わし星雲',
  'M17': 'オメガ星雲',
  'M20': '三裂星雲',
  'M27': 'あれい状星雲',
  'M31': 'アンドロメダ銀河',
  'M33': 'さんかく座銀河',
  'M42': 'オリオン大星雲',
  'M44': 'プレセペ星団',
  'M45': 'プレアデス星団(すばる)',
  'M51': '子持ち銀河',
  'M57': '環状星雲',
  'M63': 'ひまわり銀河',
  'M64': '黒眼銀河',
  'M81': 'ボーデの銀河',
  'M82': '葉巻銀河',
  'M97': 'ふくろう星雲',
  'M101': '回転花火銀河',
  'M104': 'ソンブレロ銀河',
  'NGC0869': '二重星団h',
  'NGC0884': '二重星団χ',
  'NGC2070': 'タランチュラ星雲',
  'NGC7293': 'らせん星雲',
  'B033': '馬頭星雲',
};
