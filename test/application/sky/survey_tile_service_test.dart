import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/sky/survey_providers.dart';
import 'package:open_planetarium/data/survey/disk_tile_cache.dart';
import 'package:open_planetarium/data/survey/hips_client.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/survey_layer.dart';

/// Valid PNG bytes for tests (generated from a real image in setUpAll)
late Uint8List _pngBytes;

class FakeFetcher implements HipsTileFetcher {
  int fetchCount = 0;
  bool fail = false;

  @override
  Future<Uint8List> fetchTile(SurveyLayerDef survey, HipsTileRef ref) async {
    fetchCount++;
    if (fail) throw const DownloadException('injected');
    return _pngBytes;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 2, 2),
      ui.Paint()..color = const ui.Color(0xFF808080),
    );
    final image = await recorder.endRecording().toImage(2, 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    _pngBytes = data!.buffer.asUint8List();
  });

  late Directory tempDir;
  late FakeFetcher fetcher;
  late int readyCount;
  late SurveyTileService service;

  const survey = SurveyLayerDef(
    id: 'test',
    name: 'Test',
    baseUrl: 'https://example.com/test',
    attribution: 'test',
  );
  const ref0 = HipsTileRef(surveyId: 'test', order: 3, pix: 100);

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('survey_service_test');
    fetcher = FakeFetcher();
    readyCount = 0;
    service = SurveyTileService(
      fetcher: fetcher,
      onTileReady: () => readyCount++,
      diskCache: DiskTileCache(rootDir: tempDir, limitBytes: 1 << 20),
    );
  });

  tearDown(() async {
    service.dispose();
    await tempDir.delete(recursive: true);
  });

  Future<void> pump() async {
    // Wait for fetching and decoding to finish
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (readyCount > 0) return;
    }
  }

  group('SurveyTileService', () {
    test('first call returns null; after fetch completes onTileReady fires and the image is returned', () async {
      expect(service.imageFor(survey, ref0), isNull);
      await pump();
      expect(readyCount, 1);
      expect(service.imageFor(survey, ref0), isA<ui.Image>());
      expect(fetcher.fetchCount, 1);
    });

    test('a disk cache hit does not go to the network', () async {
      service.imageFor(survey, ref0);
      await pump();

      // Re-fetch with a new service (no memory cache, same disk)
      final service2 = SurveyTileService(
        fetcher: fetcher,
        onTileReady: () => readyCount++,
        diskCache: DiskTileCache(rootDir: tempDir, limitBytes: 1 << 20),
      );
      addTearDown(service2.dispose);
      fetcher.fetchCount = 0;
      readyCount = 0;
      expect(service2.imageFor(survey, ref0), isNull);
      await pump();
      expect(service2.imageFor(survey, ref0), isNotNull);
      expect(fetcher.fetchCount, 0); // loaded from disk
    });

    test('fetch failures are negatively cached and not retried immediately', () async {
      fetcher.fail = true;
      service.imageFor(survey, ref0);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(fetcher.fetchCount, 1);

      // An immediate re-request does not re-fetch
      service.imageFor(survey, ref0);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(fetcher.fetchCount, 1);
    });
  });

  group('tilesForViewport (indirect verification)', () {
    test('HipsTileRef path format follows the HiPS convention', () {
      const tile = HipsTileRef(surveyId: 's', order: 7, pix: 12345);
      expect(tile.pathWithExtension('jpg'), 'Norder7/Dir10000/Npix12345.jpg');
      const tile2 = HipsTileRef(surveyId: 's', order: 3, pix: 99);
      expect(tile2.pathWithExtension('png'), 'Norder3/Dir0/Npix99.png');
    });
  });
}
