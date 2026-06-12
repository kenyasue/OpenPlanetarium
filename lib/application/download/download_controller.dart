import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog/tile_binary_codec.dart';
import '../../data/database/drift_catalog_store.dart';
import '../../data/network/dio_download_client.dart';
import '../../data/network/vizier_download_client.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/catalog_download.dart';
import '../../domain/repositories/download_client.dart';
import '../data/database_providers.dart';
import '../settings/download_settings_controller.dart';
import '../sky/visible_stars_provider.dart';

/// DI point for DownloadClient (replaced with a fake in tests).
///
/// By default, fetches directly from CDS VizieR, the official distributor of Tycho-2.
/// When a self-hosted server is specified via `--dart-define=CATALOG_BASE_URL=...`,
/// the conventional manifest + binary tile distribution is used.
final downloadClientProvider = Provider<DownloadClient>(
  (ref) =>
      kCatalogBaseUrl.isEmpty ? VizieRDownloadClient() : DioDownloadClient(),
);

/// Whether this is a mobile device (Android/iOS).
///
/// The Wi-Fi restriction applies only to mobile devices with metered connections
/// (desktops are never restricted, regardless of wired or Wi-Fi).
final isMobilePlatformProvider = Provider<bool>(
  (ref) =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS,
);

/// Checks whether the connection can be considered unmetered (Wi-Fi/wired) (replaced with a fake in tests)
final unmeteredConnectivityCheckerProvider = Provider<Future<bool> Function()>(
  (ref) => () async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.contains(ConnectivityResult.wifi) ||
        connectivity.contains(ConnectivityResult.ethernet);
  },
);

/// List of catalogs available for additional download (whitelist)
final availableCatalogsProvider = Provider<List<CatalogDescriptor>>(
  (ref) => const [
    CatalogDescriptor(
      id: 'tycho2_m10',
      name: 'Tycho-2 (up to mag 10)',
      description:
          'Standard extended catalog of about 250,000 stars. For binoculars and small telescopes. '
          'Fetched directly from CDS VizieR (official distributor).',
    ),
  ],
);

/// Manages catalog downloads (F3/F4).
///
/// Supports per-tile resume (completed tiles are skipped), SHA-256 verification,
/// exponential backoff retry, and cancellation.
class DownloadController extends Notifier<Map<String, CatalogDownloadState>> {
  final _cancelRequested = <String>{};

  @override
  Map<String, CatalogDownloadState> build() => const {};

  void _update(String catalogId, CatalogDownloadState newState) {
    state = {...state, catalogId: newState};
  }

  Future<void> startDownload(String catalogId) async {
    if (state[catalogId]?.status == DownloadStatus.downloading) return;

    // Check the Wi-Fi-only setting (F4). Applies to mobile devices only
    final mode = ref.read(downloadSettingsProvider);
    if (mode == DownloadMode.wifiOnly && ref.read(isMobilePlatformProvider)) {
      final unmetered = await ref.read(unmeteredConnectivityCheckerProvider)();
      if (!unmetered) {
        _update(
          catalogId,
          const CatalogDownloadState(
            status: DownloadStatus.failed,
            error:
                'Downloads are set to Wi-Fi only. Please connect to Wi-Fi.',
          ),
        );
        return;
      }
    }

    _cancelRequested.remove(catalogId);
    _update(
      catalogId,
      const CatalogDownloadState(status: DownloadStatus.downloading),
    );

    final client = ref.read(downloadClientProvider);
    final store = ref.read(catalogStoreProvider);
    const codec = TileBinaryCodec();

    try {
      await _runDownload(catalogId, client, store, codec);
    } on AppException catch (e) {
      _update(
        catalogId,
        CatalogDownloadState(status: DownloadStatus.failed, error: e.message),
      );
    } finally {
      // Never leave the flag behind, whether via exception or cancellation
      _cancelRequested.remove(catalogId);
    }
  }

  Future<void> _runDownload(
    String catalogId,
    DownloadClient client,
    DriftCatalogStore store,
    TileBinaryCodec codec,
  ) async {
    final manifest = await client.fetchManifest(catalogId);
    // Resume: skip tiles already completed (hash matches)
    final done = await store.downloadedTiles(catalogId);
    final pending = [
      for (final tile in manifest.tiles)
        if (done[tile.index] != tile.sha256) tile,
    ];
    var completed = manifest.tiles.length - pending.length;
    _update(
      catalogId,
      CatalogDownloadState(
        status: DownloadStatus.downloading,
        completedTiles: completed,
        totalTiles: manifest.tiles.length,
      ),
    );

    for (final tile in pending) {
      if (_cancelRequested.contains(catalogId)) {
        _update(
          catalogId,
          CatalogDownloadState(
            status: DownloadStatus.notDownloaded,
            completedTiles: completed,
            totalTiles: manifest.tiles.length,
          ),
        );
        return;
      }

      final bytes = await _fetchTileVerified(client, catalogId, tile);
      final decoded = codec.decode(bytes);
      await store.importTile(
        catalog: catalogId,
        tileIndex: tile.index,
        sha256: tile.sha256,
        stars: decoded[tile.index] ?? const [],
      );
      completed++;
      _update(
        catalogId,
        CatalogDownloadState(
          status: DownloadStatus.downloading,
          completedTiles: completed,
          totalTiles: manifest.tiles.length,
        ),
      );
    }

    _update(
      catalogId,
      CatalogDownloadState(
        status: DownloadStatus.downloaded,
        completedTiles: completed,
        totalTiles: manifest.tiles.length,
      ),
    );
    // Reflect the new catalog in the display
    ref.invalidate(visibleStarsProvider);
  }

  /// Fetches a tile with SHA-256 verification. Retries up to 3 times with exponential backoff.
  /// On hash mismatch, re-fetches once; if it still mismatches, raises a corruption error.
  /// Tiles with an empty sha256 are not verified (e.g. VizieR fetches with
  /// client-side conversion, where no server-side checksum exists).
  Future<Uint8List> _fetchTileVerified(
    DownloadClient client,
    String catalogId,
    ManifestTile tile,
  ) async {
    if (tile.sha256.isEmpty) {
      return _fetchWithRetry(client, catalogId, tile.index);
    }
    for (var verifyAttempt = 0; verifyAttempt < 2; verifyAttempt++) {
      if (_cancelRequested.contains(catalogId)) {
        // On cancellation, abort the re-verification fetch too (the caller loop restores the state)
        throw const DownloadException('Cancelled', retryable: false);
      }
      final bytes = await _fetchWithRetry(client, catalogId, tile.index);
      if (sha256.convert(bytes).toString() == tile.sha256) {
        return bytes;
      }
    }
    throw CatalogCorruptedException(
      'Checksum mismatch for tile ${tile.index} (still mismatched after re-fetch)',
    );
  }

  Future<Uint8List> _fetchWithRetry(
    DownloadClient client,
    String catalogId,
    int tileIndex,
  ) async {
    var delay = const Duration(milliseconds: 200);
    for (var attempt = 0; ; attempt++) {
      try {
        return await client.fetchTile(catalogId, tileIndex);
      } on DownloadException catch (e) {
        if (!e.retryable || attempt >= 2) rethrow;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
  }

  void cancel(String catalogId) => _cancelRequested.add(catalogId);

  /// Deletes the catalog and removes it from the display
  Future<void> deleteCatalog(String catalogId) async {
    await ref.read(catalogStoreProvider).deleteCatalog(catalogId);
    _update(catalogId, const CatalogDownloadState());
    ref.invalidate(visibleStarsProvider);
  }
}

final downloadControllerProvider =
    NotifierProvider<DownloadController, Map<String, CatalogDownloadState>>(
      DownloadController.new,
    );
