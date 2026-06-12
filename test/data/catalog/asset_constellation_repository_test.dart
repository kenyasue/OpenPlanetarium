import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/asset_constellation_repository.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/constellation_data.dart';

void main() {
  const sampleJson = '''
{
  "constellations": [
    {
      "iau": "Ori",
      "la": "Orion",
      "en": "Orion",
      "ja": "オリオン座",
      "labelRa": 83.0,
      "labelDec": 2.0,
      "lines": [[[88.79, 7.41], [85.19, -1.94], [78.63, -8.2]]]
    }
  ],
  "boundaries": [[[10.0, 20.0], [11.0, 21.0]]]
}
''';

  group('AssetConstellationRepository', () {
    // The "ja" fixture value stays in Japanese: it exercises the Japanese-name field.
    test('parses JSON and returns a ConstellationSet', () async {
      final repo = AssetConstellationRepository(
        loader: (_) async => sampleJson,
      );
      final set = await repo.load();
      expect(set.constellations, hasLength(1));
      final orion = set.constellations.single;
      expect(orion.iau, 'Ori');
      expect(orion.nameJa, 'オリオン座');
      expect(orion.lines.single, hasLength(3));
      expect(orion.labelAnchor.raDeg, 83.0);
      expect(set.boundaries.single, hasLength(2));
    });

    test('corrupted JSON throws CatalogCorruptedException', () async {
      final repo = AssetConstellationRepository(
        loader: (_) async => '{"constellations": "broken"}',
      );
      expect(repo.load, throwsA(isA<CatalogCorruptedException>()));
    });
  });

  group('ConstellationData.nameIn', () {
    test('returns the name for the requested language', () async {
      final repo = AssetConstellationRepository(
        loader: (_) async => sampleJson,
      );
      final orion = (await repo.load()).constellations.single;
      expect(orion.nameIn(NameLanguage.japanese), 'オリオン座');
      expect(orion.nameIn(NameLanguage.english), 'Orion');
      expect(orion.nameIn(NameLanguage.latin), 'Orion');
    });
  });
}
