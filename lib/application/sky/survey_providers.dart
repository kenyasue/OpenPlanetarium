import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/survey/disk_tile_cache.dart';
import '../../data/survey/hips_client.dart';
import '../../data/survey/memory_tile_cache.dart';
import '../../domain/astro/projection.dart';
import '../../domain/models/survey_layer.dart';
import '../../domain/models/viewport_state.dart';
import '../../domain/spatial/healpix.dart';
import '../settings/settings_persistence.dart';

/// Survey display settings (F11, persisted).
class SurveySettings {
  const SurveySettings({
    this.activeSurveyId,
    this.opacity = 0.85,
    this.cacheLimitMb = 512,
  });

  /// The survey being displayed (null means hidden; exclusive selection)
  final String? activeSurveyId;

  final double opacity;
  final int cacheLimitMb;

  SurveySettings copyWith({
    String? Function()? activeSurveyId,
    double? opacity,
    int? cacheLimitMb,
  }) {
    return SurveySettings(
      activeSurveyId: activeSurveyId != null
          ? activeSurveyId()
          : this.activeSurveyId,
      opacity: opacity ?? this.opacity,
      cacheLimitMb: cacheLimitMb ?? this.cacheLimitMb,
    );
  }
}

class SurveySettingsController extends Notifier<SurveySettings> {
  static const _key = 'settings.survey';

  @override
  SurveySettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    var disposed = false;
    ref.onDispose(() => disposed = true);
    unawaited(
      repo.read(_key).then((value) {
        if (disposed || value == null) return;
        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          state = SurveySettings(
            activeSurveyId: json['active'] as String?,
            opacity: (json['opacity'] as num?)?.toDouble() ?? 0.85,
            cacheLimitMb: (json['cacheLimitMb'] as num?)?.toInt() ?? 512,
          );
        } on FormatException {
          // Continue with defaults if the settings are corrupted
        }
      }),
    );
    return const SurveySettings();
  }

  void _save() {
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(
            _key,
            jsonEncode({
              'active': state.activeSurveyId,
              'opacity': state.opacity,
              'cacheLimitMb': state.cacheLimitMb,
            }),
          ),
    );
  }

  void setActiveSurvey(String? surveyId) {
    state = state.copyWith(activeSurveyId: () => surveyId);
    _save();
  }

  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.05, 1.0));
    _save();
  }
}

final surveySettingsProvider =
    NotifierProvider<SurveySettingsController, SurveySettings>(
      SurveySettingsController.new,
    );

/// Repaint trigger incremented each time a tile arrives
class TileVersionController extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final tileVersionProvider = NotifierProvider<TileVersionController, int>(
  TileVersionController.new,
);

/// DI point for the tile fetcher
final hipsTileFetcherProvider = Provider<HipsTileFetcher>(
  (ref) => DioHipsTileFetcher(),
);

final surveyTileServiceProvider = Provider<SurveyTileService>((ref) {
  final service = SurveyTileService(
    fetcher: ref.watch(hipsTileFetcherProvider),
    onTileReady: () => ref.read(tileVersionProvider.notifier).bump(),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Survey tile fetching and cache arbitration (F11).
///
/// Fetch flow: memory → disk → network (4 concurrent connections).
/// Failed tiles are not retried for a while (negative cache).
class SurveyTileService {
  SurveyTileService({
    required this.fetcher,
    required this.onTileReady,
    MemoryTileCache? memoryCache,
    DiskTileCache? diskCache,
    this.maxConcurrentFetches = 4,
  }) : _memory = memoryCache ?? MemoryTileCache(),
       _diskOverride = diskCache;

  final HipsTileFetcher fetcher;
  final void Function() onTileReady;
  final int maxConcurrentFetches;

  final MemoryTileCache _memory;
  final DiskTileCache? _diskOverride;
  Future<DiskTileCache>? _diskFuture;

  final _loading = <String>{};
  final _failedAt = <String, DateTime>{};
  var _activeFetches = 0;
  final _queue = <(SurveyLayerDef, HipsTileRef)>[];
  var _disposed = false;

  static const _negativeCacheDuration = Duration(seconds: 60);

  Future<DiskTileCache> _disk() {
    if (_diskOverride != null) return Future.value(_diskOverride);
    return _diskFuture ??= getApplicationCacheDirectory().then(
      (dir) => DiskTileCache(
        rootDir: Directory('${dir.path}/survey_tiles'),
        limitBytes: 512 * 1024 * 1024,
      ),
    );
  }

  /// Keeps the disk cache size limit in sync with the setting
  Future<void> setCacheLimitMb(int limitMb) async {
    (await _disk()).limitBytes = limitMb * 1024 * 1024;
  }

  Future<void> clearCache() async {
    _memory.clear();
    await (await _disk()).clear();
  }

  /// Returns immediately if in memory. Otherwise schedules an asynchronous load and returns null
  /// (a repaint is triggered via onTileReady when the tile arrives).
  ui.Image? imageFor(SurveyLayerDef survey, HipsTileRef ref) {
    final cached = _memory.get(ref.key);
    if (cached != null) return cached;
    _scheduleLoad(survey, ref);
    return null;
  }

  void _scheduleLoad(SurveyLayerDef survey, HipsTileRef ref) {
    if (_loading.contains(ref.key)) return;
    final failedAt = _failedAt[ref.key];
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < _negativeCacheDuration) {
      return;
    }
    _loading.add(ref.key);
    _queue.add((survey, ref));
    _pump();
  }

  void _pump() {
    while (_activeFetches < maxConcurrentFetches && _queue.isNotEmpty) {
      final (survey, ref) = _queue.removeAt(0);
      _activeFetches++;
      unawaited(
        _load(survey, ref).whenComplete(() {
          _activeFetches--;
          _loading.remove(ref.key);
          if (!_disposed) _pump();
        }),
      );
    }
  }

  Future<void> _load(SurveyLayerDef survey, HipsTileRef ref) async {
    try {
      final disk = await _disk();
      var bytes = await disk.get(ref.key);
      if (bytes == null) {
        bytes = await fetcher.fetchTile(survey, ref);
        await disk.put(ref.key, bytes);
      }
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        if (_disposed) {
          frame.image.dispose();
          return;
        }
        _memory.put(ref.key, frame.image);
        onTileReady();
      } finally {
        codec.dispose(); // Release native resources (prevent leaks)
      }
    } on Exception {
      // Network or decode failure: do not retry for a while (rendering continues with ancestor tiles)
      _failedAt[ref.key] = DateTime.now();
    }
  }

  void dispose() {
    _disposed = true;
    _queue.clear();
    _memory.clear();
  }
}

/// Enumerates the HiPS tiles needed for the viewport.
///
/// Samples the screen at intervals of about half the tile's on-screen size and takes
/// the union of ang2pix at each point (tiles larger than the screen are still caught via the center point).
List<HipsTileRef> tilesForViewport({
  required ViewProjection projection,
  required ViewportState state,
  required String surveyId,
  required int order,
}) {
  final pxPerDeg = state.screenSize.height / state.fovDeg;
  final tileScreenPx = 58.6 / (1 << order) * pxPerDeg;
  final step = (tileScreenPx / 2).clamp(48.0, 256.0);

  final pixels = <int>{};
  // Sample one step beyond the screen edges to avoid missing edge tiles
  for (var x = -step; x <= state.screenSize.width + step; x += step) {
    for (var y = -step; y <= state.screenSize.height + step; y += step) {
      final sky = projection.unproject(ui.Offset(x, y));
      pixels.add(Healpix.ang2pixNest(order, sky.raDeg, sky.decDeg));
    }
  }
  return [
    for (final pix in pixels)
      HipsTileRef(surveyId: surveyId, order: order, pix: pix),
  ];
}
