import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/search/search_service.dart';
import 'package:open_planetarium/data/catalog/asset_constellation_repository.dart';
import 'package:open_planetarium/data/catalog/asset_dso_repository.dart';
import 'package:open_planetarium/domain/models/sky_object.dart';
import 'package:open_planetarium/domain/models/solar_system.dart';
import 'package:open_planetarium/domain/models/star.dart';

/// Search acceptance tests using the real assets (dso.json / constellations.json)
/// (PRD F8: search hit-rate verification set).
void main() {
  late SearchService service;

  setUpAll(() async {
    final dsos = await AssetDsoRepository(
      loader: (key) => File(key).readAsString(),
    ).loadAll();
    final constellations = (await AssetConstellationRepository(
      loader: (_) => File('assets/catalogs/constellations.json').readAsString(),
    ).load()).constellations;
    service = SearchService(
      namedStars: [
        const Star(
          id: 32349,
          raDeg: 101.2872,
          decDeg: -16.7161,
          magnitude: -1.44,
          tileIndex: 0,
          name: 'Sirius',
        ),
      ],
      dsos: dsos,
      constellations: constellations,
    );
  });

  group('SearchService (acceptance-criteria search set)', () {
    test('M31 hits the Andromeda Galaxy', () {
      final results = service.search('M31');
      expect(results, isNotEmpty);
      expect(results.first.label, 'アンドロメダ銀河');
      expect(results.first.object, isA<DsoObject>());
    });

    test('NGC 891 hits (whitespace tolerated)', () {
      expect(service.search('NGC 891'), isNotEmpty);
      expect(service.search('ngc891'), isNotEmpty);
    });

    test('Sirius (English proper name) hits', () {
      final results = service.search('Sirius');
      expect(results.any((r) => r.object is StarObject), isTrue);
    });

    // Japanese-name search feature: query and expected label stay in Japanese.
    test('Orion (Japanese name) hits and has centering coordinates', () {
      final results = service.search('オリオン');
      expect(results, isNotEmpty);
      final orion = results.firstWhere((r) => r.label == 'オリオン座');
      // Orion's label position is around RA 80-90°
      expect(orion.target.raDeg, inInclusiveRange(75, 95));
    });

    test('Saturn hits a solar system body', () {
      final results = service.search('Saturn');
      expect(results, isNotEmpty);
      final saturn = results.first.object;
      expect(saturn, isA<SolarBodyObject>());
      expect((saturn! as SolarBodyObject).body, SolarBodyId.saturn);
    });

    // Japanese-name search feature: query and expected label stay in Japanese.
    test('Subaru (Japanese name of the Pleiades) hits', () {
      final results = service.search('すばる');
      expect(results, isNotEmpty);
      expect(results.first.label, contains('プレアデス'));
    });

    test('M101 and M1 are not confused (exact number match)', () {
      final m1 = service.search('M1');
      expect(m1.single.label, 'かに星雲');
      final m101 = service.search('M101');
      expect(m101.single.label, '回転花火銀河');
    });

    test('empty or whitespace-only query returns an empty list', () {
      expect(service.search(''), isEmpty);
      expect(service.search('   '), isEmpty);
    });
  });
}
