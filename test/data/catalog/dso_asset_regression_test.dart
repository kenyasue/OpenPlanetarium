import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/asset_dso_repository.dart';
import 'package:open_planetarium/domain/models/deep_sky_object.dart';

/// Regression checks for the generated assets (dso.json + dso_extra.json).
void main() {
  late List<DeepSkyObject> dsos;

  setUpAll(() async {
    dsos = await AssetDsoRepository(
      loader: (key) => File(key).readAsString(),
    ).loadAll();
  });

  group('dso.json (generated asset)', () {
    test('all 110 Messier objects are included', () {
      final messiers = {
        for (final dso in dsos)
          if (dso.messierNumber != null) dso.messierNumber!,
      };
      final missing = [
        for (var m = 1; m <= 110; m++)
          if (!messiers.contains(m)) m,
      ];
      expect(missing, isEmpty, reason: 'missing: $missing');
    });

    // nameJa is Japanese asset data; the expected value stays in Japanese.
    test('M31 (Andromeda Galaxy) has correct coordinates and type', () {
      final m31 = dsos.firstWhere((d) => d.messierNumber == 31);
      expect(m31.raDeg, closeTo(10.685, 0.05));
      expect(m31.decDeg, closeTo(41.269, 0.05));
      expect(m31.objectType, ObjectType.galaxy);
      expect(m31.nameJa, 'アンドロメダ銀河');
    });

    test('M42 (Orion Nebula) and M45 (Pleiades) have correct types', () {
      final m42 = dsos.firstWhere((d) => d.messierNumber == 42);
      expect(m42.objectType, ObjectType.nebula);
      final m45 = dsos.firstWhere((d) => d.messierNumber == 45);
      expect(m45.objectType, ObjectType.openCluster);
      expect(m45.nameJa, contains('すばる'));
    });

    test('all coordinates are in the normalized range and sorted by brightness', () {
      double? prevMag;
      for (final dso in dsos) {
        expect(dso.raDeg, inInclusiveRange(0, 360), reason: dso.id);
        expect(dso.decDeg, inInclusiveRange(-90, 90), reason: dso.id);
        final mag = dso.magnitude ?? 99.0;
        if (prevMag != null) {
          expect(mag, greaterThanOrEqualTo(prevMag), reason: dso.id);
        }
        prevMag = mag;
      }
    });

    test('extra catalogs (Sh2/LBN/LDN/vdB) are merged in', () {
      bool has(DsoCatalog c) => dsos.any((d) => d.catalogs.contains(c));
      expect(has(DsoCatalog.sh2), isTrue);
      expect(has(DsoCatalog.lbn), isTrue);
      expect(has(DsoCatalog.ldn), isTrue);
      expect(has(DsoCatalog.vdb), isTrue);

      // Sh2-155 (Cave Nebula): verifies galactic → J2000 conversion (22h56.8m, +62°37')
      final sh155 = dsos.firstWhere((d) => d.id == 'SH2-155');
      expect(sh155.raDeg, closeTo(344.3, 0.5));
      expect(sh155.decDeg, closeTo(62.6, 0.5));

      // LDN entries have the dark nebula type
      final ldn = dsos.firstWhere((d) => d.id == 'LDN1773');
      expect(ldn.objectType, ObjectType.darkNebula);
    });

    test('catalogLabel notation (M/NGC/IC) is formatted correctly', () {
      final m31 = dsos.firstWhere((d) => d.messierNumber == 31);
      expect(m31.catalogLabel, 'M31');
      final ngc891 = dsos.firstWhere((d) => d.id == 'NGC0891');
      expect(ngc891.catalogLabel, 'NGC 891');
    });
  });
}
