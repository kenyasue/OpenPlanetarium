import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/data/database_providers.dart';
import 'package:open_planetarium/application/download/download_controller.dart';
import 'package:open_planetarium/application/settings/download_settings_controller.dart';
import 'package:open_planetarium/data/catalog/tile_binary_codec.dart';
import 'package:open_planetarium/data/database/app_database.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/catalog_download.dart';
import 'package:open_planetarium/domain/models/star.dart';
import 'package:open_planetarium/domain/repositories/download_client.dart';

/// Test settings that bypass the Wi-Fi check (always auto)
class _AutoDownloadSettings extends DownloadSettingsController {
  @override
  DownloadMode build() => DownloadMode.auto;
}

/// Wi-Fi-only settings (for Wi-Fi restriction tests)
class _WifiOnlyDownloadSettings extends DownloadSettingsController {
  @override
  DownloadMode build() => DownloadMode.wifiOnly;
}

/// Fake that serves in-memory download data (supports injecting failures/corruption)
class FakeDownloadClient implements DownloadClient {
  FakeDownloadClient(this.tiles);

  /// tileIndex → correct byte sequence
  final Map<int, Uint8List> tiles;

  /// When true, the manifest sha256 is left empty (simulates unverified delivery such as VizieR)
  bool emptySha = false;

  /// tileIndex → remaining failure count (retryable errors)
  final Map<int, int> failuresRemaining = {};

  /// Tiles that return corrupted data exactly once
  final Set<int> corruptOnce = {};

  int tileFetchCount = 0;

  /// Hook called on every tile fetch (for cancellation tests)
  void Function(int tileIndex)? onFetchTile;

  @override
  Future<CatalogManifest> fetchManifest(String catalogId) async {
    return CatalogManifest(
      catalogId: catalogId,
      version: 1,
      totalBytes: tiles.values.fold(0, (sum, b) => sum + b.length),
      tiles: [
        for (final entry in tiles.entries)
          ManifestTile(
            index: entry.key,
            bytes: entry.value.length,
            sha256: emptySha ? '' : sha256.convert(entry.value).toString(),
          ),
      ],
    );
  }

  @override
  Future<Uint8List> fetchTile(String catalogId, int tileIndex) async {
    tileFetchCount++;
    onFetchTile?.call(tileIndex);
    final remaining = failuresRemaining[tileIndex] ?? 0;
    if (remaining > 0) {
      failuresRemaining[tileIndex] = remaining - 1;
      throw const DownloadException('injected failure');
    }
    if (corruptOnce.remove(tileIndex)) {
      return Uint8List.fromList([1, 2, 3]); // corrupted data
    }
    return tiles[tileIndex]!;
  }
}

Uint8List _tileBytes(int tileIndex, List<Star> stars) =>
    const TileBinaryCodec().encode({tileIndex: stars});

void main() {
  late AppDatabase db;
  late FakeDownloadClient client;
  late ProviderContainer container;

  const starsTile0 = [
    Star(id: 100, raDeg: 10, decDeg: 5, magnitude: 8.0, tileIndex: 0),
  ];
  const starsTile1 = [
    Star(id: 200, raDeg: 50, decDeg: 40, magnitude: 9.0, tileIndex: 1),
    Star(id: 201, raDeg: 51, decDeg: 41, magnitude: 9.5, tileIndex: 1),
  ];

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    client = FakeDownloadClient({
      0: _tileBytes(0, starsTile0),
      1: _tileBytes(1, starsTile1),
    });
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(db.close);
          return db;
        }),
        downloadClientProvider.overrideWithValue(client),
        downloadSettingsProvider.overrideWith(_AutoDownloadSettings.new),
      ],
    );
    addTearDown(container.dispose);
  });

  group('DownloadController', () {
    test('happy path: manifest → fetch all tiles → store in DB → status downloaded', () async {
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');

      final state = container.read(downloadControllerProvider)['test_catalog'];
      expect(state?.status, DownloadStatus.downloaded);
      expect(state?.completedTiles, 2);

      final store = container.read(catalogStoreProvider);
      expect(await store.starsInTiles([0, 1], 10.0), hasLength(3));
    });

    test('resume: completed tiles are skipped', () async {
      final controller = container.read(downloadControllerProvider.notifier);
      // Only tile 0 is pre-imported (hash matches)
      final store = container.read(catalogStoreProvider);
      final manifest = await client.fetchManifest('test_catalog');
      await store.importTile(
        catalog: 'test_catalog',
        tileIndex: 0,
        sha256: manifest.tiles.firstWhere((t) => t.index == 0).sha256,
        stars: starsTile0,
      );
      client.tileFetchCount = 0;

      await controller.startDownload('test_catalog');

      expect(client.tileFetchCount, 1); // only tile 1 is fetched
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('SHA-256 mismatch triggers one re-fetch and succeeds with correct data', () async {
      client.corruptOnce.add(1);
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');

      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
      // tile 0 = 1 fetch; tile 1 = 1 corrupted + 1 re-fetch
      expect(client.tileFetchCount, 3);
    });

    test('retryable failures are retried with exponential backoff and succeed', () async {
      client.failuresRemaining[0] = 2; // fails twice, succeeds on the 3rd attempt
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('exceeding the retry limit yields failed status without affecting the sky view', () async {
      client.failuresRemaining[0] = 10;
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');
      final state = container.read(downloadControllerProvider)['test_catalog'];
      expect(state?.status, DownloadStatus.failed);
      expect(state?.error, isNotNull);
    });

    test('cancelling mid-download stops while incomplete and can be resumed', () async {
      final controller = container.read(downloadControllerProvider.notifier);
      // Request cancellation on the first tile fetch
      client.onFetchTile = (_) {
        controller.cancel('test_catalog');
        client.onFetchTile = null;
      };
      await controller.startDownload('test_catalog');

      final state = container.read(downloadControllerProvider)['test_catalog'];
      expect(state?.status, DownloadStatus.notDownloaded);
      expect(state!.completedTiles, lessThan(2));

      // Resuming fetches only the remaining tiles and completes
      await controller.startDownload('test_catalog');
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('a second startDownload while downloading is ignored', () async {
      final controller = container.read(downloadControllerProvider.notifier);
      Future<void>? second;
      client.onFetchTile = (_) {
        // Start a second download while the first is in progress (rejected by the guard)
        second ??= controller.startDownload('test_catalog');
      };
      await controller.startDownload('test_catalog');
      await second;

      // Without duplicate execution, only 2 tile fetches occur
      expect(client.tileFetchCount, 2);
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('manifest with empty sha256 downloads without verification, and resume still skips', () async {
      client.emptySha = true;
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
      final store = container.read(catalogStoreProvider);
      expect(await store.starsInTiles([0, 1], 10.0), hasLength(3));

      // Re-downloading skips completed tiles (empty sha matches empty sha)
      client.tileFetchCount = 0;
      await controller.startDownload('test_catalog');
      expect(client.tileFetchCount, 0);
    });

    test('Wi-Fi restriction: desktop can download regardless of connection type', () async {
      final desktop = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
          downloadClientProvider.overrideWithValue(client),
          downloadSettingsProvider.overrideWith(_WifiOnlyDownloadSettings.new),
          isMobilePlatformProvider.overrideWithValue(false),
          // Passes even on non-Wi-Fi, non-wired connections (i.e. mobile data)
          unmeteredConnectivityCheckerProvider.overrideWithValue(
            () async => false,
          ),
        ],
      );
      addTearDown(desktop.dispose);

      await desktop
          .read(downloadControllerProvider.notifier)
          .startDownload('test_catalog');
      expect(
        desktop.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('Wi-Fi restriction: mobile on a non-Wi-Fi connection ends up failed', () async {
      final mobile = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
          downloadClientProvider.overrideWithValue(client),
          downloadSettingsProvider.overrideWith(_WifiOnlyDownloadSettings.new),
          isMobilePlatformProvider.overrideWithValue(true),
          unmeteredConnectivityCheckerProvider.overrideWithValue(
            () async => false,
          ),
        ],
      );
      addTearDown(mobile.dispose);

      await mobile
          .read(downloadControllerProvider.notifier)
          .startDownload('test_catalog');
      final state = mobile.read(downloadControllerProvider)['test_catalog'];
      expect(state?.status, DownloadStatus.failed);
      expect(state?.error, contains('Wi-Fi'));
      expect(client.tileFetchCount, 0); // never reaches tile fetching
    });

    test('Wi-Fi restriction: mobile can download when on Wi-Fi', () async {
      final mobile = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
          downloadClientProvider.overrideWithValue(client),
          downloadSettingsProvider.overrideWith(_WifiOnlyDownloadSettings.new),
          isMobilePlatformProvider.overrideWithValue(true),
          unmeteredConnectivityCheckerProvider.overrideWithValue(
            () async => true,
          ),
        ],
      );
      addTearDown(mobile.dispose);

      await mobile
          .read(downloadControllerProvider.notifier)
          .startDownload('test_catalog');
      expect(
        mobile.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.downloaded,
      );
    });

    test('deleteCatalog removes the data from the DB', () async {
      final controller = container.read(downloadControllerProvider.notifier);
      await controller.startDownload('test_catalog');
      await controller.deleteCatalog('test_catalog');
      final store = container.read(catalogStoreProvider);
      expect(await store.starsInTiles([0, 1], 10.0), isEmpty);
      expect(
        container.read(downloadControllerProvider)['test_catalog']?.status,
        DownloadStatus.notDownloaded,
      );
    });
  });
}
