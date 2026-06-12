import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/settings/dso_settings_controller.dart';
import 'package:open_planetarium/application/settings/settings_persistence.dart';
import 'package:open_planetarium/application/sky/dso_provider.dart';
import 'package:open_planetarium/data/settings/prefs_settings_repository.dart';
import 'package:open_planetarium/domain/models/deep_sky_object.dart';
import 'package:open_planetarium/domain/repositories/dso_repository.dart';

DeepSkyObject _dso(String id, {int? messier, double? mag}) => DeepSkyObject(
  id: id,
  objectType: ObjectType.nebula,
  raDeg: 10,
  decDeg: 10,
  messierNumber: messier,
  magnitude: mag,
);

class _FixedDsoRepository implements DsoRepository {
  _FixedDsoRepository(this.objects);

  final List<DeepSkyObject> objects;

  @override
  Future<List<DeepSkyObject>> loadAll() async => objects;
}

void main() {
  group('DeepSkyObject.catalogs', () {
    test('derives catalog membership from id prefix and Messier number', () {
      expect(_dso('NGC0224', messier: 31).catalogs, {
        DsoCatalog.messier,
        DsoCatalog.ngc,
      });
      expect(_dso('IC0434').catalogs, {DsoCatalog.ic});
      expect(_dso('SH2-155').catalogs, {DsoCatalog.sh2});
      expect(_dso('LBN1111').catalogs, {DsoCatalog.lbn});
      expect(_dso('LDN1773').catalogs, {DsoCatalog.ldn});
      expect(_dso('VDB142').catalogs, {DsoCatalog.vdb});
      expect(_dso('Mel022', messier: 45).catalogs, {DsoCatalog.messier});
      expect(_dso('Mel025').catalogs, {DsoCatalog.other});
    });

    test('catalogLabel is formatted for new catalogs too', () {
      expect(_dso('SH2-155').catalogLabel, 'Sh2-155');
      expect(_dso('LBN0123').catalogLabel, 'LBN 123');
      expect(_dso('LDN1773').catalogLabel, 'LDN 1773');
      expect(_dso('VDB001').catalogLabel, 'vdB 1');
    });
  });

  group('visibleDsosProvider', () {
    ProviderContainer makeContainer(List<DeepSkyObject> objects) {
      final container = ProviderContainer(
        overrides: [
          dsoRepositoryProvider.overrideWithValue(_FixedDsoRepository(objects)),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('by default only Messier/NGC/IC are shown; faint nebula catalogs are hidden', () async {
      final container = makeContainer([
        _dso('NGC0224', messier: 31),
        _dso('IC0434'),
        _dso('SH2-155'),
        _dso('LDN1773'),
      ]);
      await container.read(dsoListProvider.future);

      final visible = container.read(visibleDsosProvider);
      expect(visible.map((d) => d.id), ['NGC0224', 'IC0434']);
    });

    test('catalog on/off is applied; multi-membership objects show if any catalog is enabled', () async {
      final container = makeContainer([
        _dso('NGC0224', messier: 31),
        _dso('NGC0891'),
        _dso('SH2-155'),
      ]);
      await container.read(dsoListProvider.future);
      final controller = container.read(dsoSettingsProvider.notifier);

      // Even with NGC off, M31 stays visible via its Messier membership
      controller.setCatalog(DsoCatalog.ngc, show: false);
      expect(container.read(visibleDsosProvider).map((d) => d.id), ['NGC0224']);

      // Turning Sh2 on makes it visible
      controller.setCatalog(DsoCatalog.sh2, show: true);
      expect(container.read(visibleDsosProvider).map((d) => d.id), [
        'NGC0224',
        'SH2-155',
      ]);
    });

    test('limiting-magnitude filter hides faint DSOs; unknown magnitude is unaffected', () async {
      final container = makeContainer([
        _dso('NGC0001', mag: 5.0),
        _dso('NGC0002', mag: 11.0),
        _dso('NGC0003'), // unknown magnitude
      ]);
      await container.read(dsoListProvider.future);
      final controller = container.read(dsoSettingsProvider.notifier);

      // At the default (mag 20) everything is shown
      expect(container.read(visibleDsosProvider), hasLength(3));

      controller.setLimitingMagnitude(8.0);
      expect(container.read(visibleDsosProvider).map((d) => d.id), [
        'NGC0001',
        'NGC0003', // unknown magnitude follows the catalog switches only
      ]);
    });

    test('nothing is shown when all catalogs are off', () async {
      final container = makeContainer([
        _dso('NGC0224', messier: 31),
        _dso('Mel025'),
      ]);
      await container.read(dsoListProvider.future);
      final controller = container.read(dsoSettingsProvider.notifier);
      for (final c in DsoCatalog.values) {
        controller.setCatalog(c, show: false);
      }
      expect(container.read(visibleDsosProvider), isEmpty);
    });

    test('settings are persisted and restored across a simulated restart', () async {
      final repo = InMemorySettingsRepository();
      final container1 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container1.dispose);
      container1
          .read(dsoSettingsProvider.notifier)
          .setCatalog(DsoCatalog.ldn, show: true);
      await Future<void>.delayed(Duration.zero);

      final container2 = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container2.dispose);
      container2.read(dsoSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      expect(
        container2.read(dsoSettingsProvider).isEnabled(DsoCatalog.ldn),
        isTrue,
      );
      expect(
        container2.read(dsoSettingsProvider).isEnabled(DsoCatalog.sh2),
        isFalse,
      );
    });
  });
}
