import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/constellation_data.dart';
import 'package:open_planetarium/domain/models/deep_sky_object.dart';
import 'package:open_planetarium/domain/models/minor_body.dart';
import 'package:open_planetarium/domain/models/solar_system.dart';

const _m31 = DeepSkyObject(
  id: 'NGC0224',
  objectType: ObjectType.galaxy,
  raDeg: 10.68,
  decDeg: 41.27,
  commonName: 'Andromeda Galaxy',
  nameJa: 'アンドロメダ銀河',
  messierNumber: 31,
);

/// Japanese name only (like M101 in the bundled data)
const _jaOnly = DeepSkyObject(
  id: 'NGC5457',
  objectType: ObjectType.galaxy,
  raDeg: 210.8,
  decDeg: 54.35,
  nameJa: '回転花火銀河',
  messierNumber: 101,
);

/// No common names at all
const _anonymous = DeepSkyObject(
  id: 'NGC6231',
  objectType: ObjectType.openCluster,
  raDeg: 253.55,
  decDeg: -41.82,
);

void main() {
  group('DeepSkyObject.displayNameIn', () {
    test('japanese prefers the Japanese name', () {
      expect(_m31.displayNameIn(NameLanguage.japanese), 'アンドロメダ銀河');
    });

    test('english uses the English common name, never Japanese', () {
      expect(_m31.displayNameIn(NameLanguage.english), 'Andromeda Galaxy');
      expect(_m31.displayNameIn(NameLanguage.latin), 'Andromeda Galaxy');
    });

    test(
      'english falls back to the catalog label when no English name exists',
      () {
        expect(_jaOnly.displayNameIn(NameLanguage.english), 'M101');
        expect(_jaOnly.displayNameIn(NameLanguage.japanese), '回転花火銀河');
      },
    );

    test('japanese falls back to English then catalog label', () {
      const enOnly = DeepSkyObject(
        id: 'NGC7000',
        objectType: ObjectType.nebula,
        raDeg: 314.8,
        decDeg: 44.5,
        commonName: 'North America Nebula',
      );
      expect(
        enOnly.displayNameIn(NameLanguage.japanese),
        'North America Nebula',
      );
      expect(_anonymous.displayNameIn(NameLanguage.japanese), 'NGC 6231');
    });
  });

  group('MinorBody.displayNameIn', () {
    const elements = OrbitalElements(
      epochJd: 2460000.5,
      aAu: 2.77,
      e: 0.08,
      iDeg: 10.6,
      nodeDeg: 80.3,
      argPeriDeg: 73.6,
      meanAnomalyDeg: 0,
    );
    const ceres = MinorBody(
      id: '2000001',
      name: '1 Ceres',
      nameJa: 'ケレス',
      kind: MinorBodyKind.asteroid,
      elements: elements,
      mag1: 3.3,
      mag2: 0,
    );

    test('follows the language and never shows Japanese in English', () {
      expect(ceres.displayNameIn(NameLanguage.japanese), 'ケレス');
      expect(ceres.displayNameIn(NameLanguage.english), '1 Ceres');
      expect(ceres.displayNameIn(NameLanguage.latin), '1 Ceres');
    });
  });

  group('SolarBodyId.nameIn', () {
    test('selects per language', () {
      expect(
        SolarBodyId.saturn.nameIn(NameLanguage.japanese),
        SolarBodyId.saturn.nameJa,
      );
      expect(SolarBodyId.saturn.nameIn(NameLanguage.english), 'Saturn');
      expect(SolarBodyId.saturn.nameIn(NameLanguage.latin), 'Saturn');
    });
  });
}
