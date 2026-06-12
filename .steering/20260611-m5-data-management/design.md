# Design Document

## Architecture Overview

```
presentation/  SettingsScreen (sectioned) / DataManagementSection / LocationSection
application/   DownloadController (queue, progress) / SettingsPersistence (save/restore for each Controller) / downloadSettingsProvider
domain/        CatalogDescriptor / CatalogManifest / DownloadProgress / CatalogStatus / SettingsRepository (IF) / DownloadClient (IF)
data/          drift AppDatabase (stars) / DriftCatalogStore / CompositeCatalogRepository / DioDownloadClient / PrefsSettingsRepository
tool/          add manifest generation to convert.dart (output to dist/)
```

## Component Design

### 1. Distribution Format

```
<base>/<catalogId>/manifest.json
{
  "catalogId": "tycho2_m10", "version": 1, "limitingMagnitude": 10.0,
  "tiles": [{"index": 0, "bytes": 1234, "sha256": "..."}, ...],
  "totalBytes": 123456
}
<base>/<catalogId>/tiles/<index>.bin   (FPC1 format, decoded by TileBinaryCodec)
```

### 2. DownloadClient (domain IF) / DioDownloadClient (data)

```dart
abstract class DownloadClient {
  Future<CatalogManifest> fetchManifest(String catalogId);
  Future<Uint8List> fetchTile(String catalogId, int tileIndex, {CancelToken? token});
}
```
- DioDownloadClient: baseUrl is String.fromEnvironment('CATALOG_BASE_URL'). When unset, DownloadUnavailableException
- Retry (exponential backoff 200ms × 2^n, 3 times) is performed on the DownloadController side

### 3. Drift Database and CompositeCatalogRepository

- AppDatabase (catalogs.db): stars table {id, catalog, tileIndex, raDeg, decDeg, magnitude, bv?, name?} + index(tileIndex, magnitude) + downloadedTiles table {catalog, tileIndex, sha256}
- DriftCatalogStore: importTile (delete+insert in a transaction), starsInTiles, downloadedTiles, deleteCatalog, databaseSize
- CompositeCatalogRepository implements CatalogRepository: combines results from the asset BSC + DriftCatalogStore (replaces catalogRepositoryProvider)
- drift uses native (NativeDatabase). Tests use NativeDatabase.memory()

### 4. DownloadController (application)

```dart
class CatalogDownloadState { status(idle/downloading/paused/failed/done), completedTiles, totalTiles, receivedBytes, error }
class DownloadController extends Notifier<Map<String, CatalogDownloadState>> {
  Future<void> startDownload(String catalogId);  // fetch manifest → sequentially DL only unfetched tiles → verify → import
  void cancel(String catalogId);
}
```
- Resume: fetch only the difference between the downloadedTiles table and the manifest
- Verification: sha256 (crypto) mismatch → one re-fetch; on repeated failure mark the tile as failed (the whole download continues)
- Wi-Fi setting: when downloadMode=wifiOnly, refuse to start (with message) if connectivity_plus reports anything other than wifi

### 5. Settings Persistence

- SettingsRepository (IF): `Future<String?> read(String key)` / `Future<void> write(String key, String value)` (JSON strings)
- PrefsSettingsRepository: shared_preferences implementation
- Each Controller (Appearance/Constellation/manual Location/DownloadSettings) restores in build() and saves on change (fire-and-forget + unawaited)
- Since restoration cannot be synchronous in build(), use initial value → replace state after loading (Notifier + restore method rather than Async. Pre-fetch SharedPreferences in main() and inject as an override into ProviderScope)

### 6. Settings Screen

- SettingsScreen (Navigator push; desktop is a dialog-like view with width 720, mobile is full screen)
- Sections: Display settings / Constellation display / Observing location / Data management
- Observing location: latitude/longitude TextField + major city presets (Tokyo/Osaka/Sapporo/Fukuoka/Naha) + "Acquire via GPS" button
- Data management: catalog cards (name, status, progress bar, start/cancel), DB size display, catalog deletion, update check button
- Replace the two settings sections in the left panel with an "Open settings" button (search and light pollution slider remain)

## Error Handling Strategy

- Add DownloadUnavailableException (server not configured) / DownloadException (retryable) to exceptions.dart
- Download failure results in a per-catalog failed state + retry button. It does not affect the starry sky display

## Test Strategy

- DownloadController integration tests with FakeDownloadClient (in-memory manifest + tiles, failure injection possible): happy path / resume (skipping completed tiles) / sha256 mismatch re-fetch / cancel
- DriftCatalogStore: import → query → delete with in-memory DB
- CompositeCatalogRepository: asset + DB composition
- SettingsPersistence: save/restore with InMemorySettingsRepository
- Impact on existing tests: with the catalogRepositoryProvider replacement (made Composite), the visibleStars tests must continue to pass

## Implementation Order

1. Introduce drift (schema, Store) + tests
2. Distribution format, DownloadClient, DownloadController + tests
3. CompositeCatalogRepository + provider replacement
4. SettingsRepository + persistence of each setting
5. Settings screen UI
6. Update docs (F3 spec change) → verification → merge

## Performance Considerations

- drift runs in a background isolate (NativeDatabase.createInBackground)
- Import uses batch insert (transactional)
