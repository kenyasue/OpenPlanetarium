import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/survey/disk_tile_cache.dart';
import 'package:open_planetarium/data/survey/memory_tile_cache.dart';

Future<ui.Image> _dummyImage() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 4, 4),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  return recorder.endRecording().toImage(4, 4);
}

void main() {
  group('MemoryTileCache', () {
    test('exceeding the entry limit evicts the oldest entry', () async {
      final cache = MemoryTileCache(capacity: 2);
      cache.put('a', await _dummyImage());
      cache.put('b', await _dummyImage());
      cache.put('c', await _dummyImage());
      expect(cache.contains('a'), isFalse);
      expect(cache.contains('b'), isTrue);
      expect(cache.contains('c'), isTrue);
      cache.clear();
    });

    test('get updates the LRU order', () async {
      final cache = MemoryTileCache(capacity: 2);
      cache.put('a', await _dummyImage());
      cache.put('b', await _dummyImage());
      cache.get('a'); // mark a as recently used
      cache.put('c', await _dummyImage());
      expect(cache.contains('a'), isTrue);
      expect(cache.contains('b'), isFalse);
      cache.clear();
    });
  });

  group('DiskTileCache', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tile_cache_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    Uint8List bytes(int size, int fill) =>
        Uint8List.fromList(List.filled(size, fill));

    test('put → get round-trip; unsaved keys return null', () async {
      final cache = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      await cache.put('dss/3/100', bytes(10, 1));
      expect(await cache.get('dss/3/100'), bytes(10, 1));
      expect(await cache.get('dss/3/999'), isNull);
    });

    test('exceeding the byte limit evicts in LRU order', () async {
      final cache = DiskTileCache(rootDir: tempDir, limitBytes: 25);
      await cache.put('a', bytes(10, 1));
      await cache.put('b', bytes(10, 2));
      await cache.get('a'); // mark a as recently used
      await cache.put('c', bytes(10, 3)); // 30 > 25 → b is evicted
      expect(await cache.get('b'), isNull);
      expect(await cache.get('a'), isNotNull);
      expect(await cache.get('c'), isNotNull);
      expect(cache.totalBytes, lessThanOrEqualTo(25));
    });

    test('the index is persisted and restored by a new instance', () async {
      final cache1 = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      await cache1.put('dss/3/100', bytes(10, 7));

      final cache2 = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      expect(await cache2.get('dss/3/100'), bytes(10, 7));
    });

    test('entries whose backing file disappeared are removed during reconciliation', () async {
      final cache1 = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      await cache1.put('dss/3/100', bytes(10, 7));
      // Delete only the backing file
      File('${tempDir.path}/dss_3_100.bin').deleteSync();

      final cache2 = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      expect(await cache2.get('dss/3/100'), isNull);
    });

    test('LRU updates from get are preserved across a restart', () async {
      final cache1 = DiskTileCache(
        rootDir: tempDir,
        limitBytes: 1000,
        accessPersistDelay: Duration.zero,
      );
      await cache1.put('a', bytes(10, 1));
      await cache1.put('b', bytes(10, 2));
      await cache1.get('a'); // mark a as recently used
      await Future<void>.delayed(const Duration(milliseconds: 20)); // wait for persistence

      // Simulated restart: a new instance with a tighter limit evicts b first
      final cache2 = DiskTileCache(rootDir: tempDir, limitBytes: 15);
      await cache2.put('c', bytes(5, 3));
      expect(await cache2.get('b'), isNull, reason: 'b, accessed longest ago, is evicted');
      expect(await cache2.get('a'), isNotNull);
    });

    test('clear removes everything', () async {
      final cache = DiskTileCache(rootDir: tempDir, limitBytes: 1000);
      await cache.put('a', bytes(10, 1));
      await cache.put('b', bytes(10, 2));
      await cache.clear();
      expect(cache.totalBytes, 0);
      expect(await cache.get('a'), isNull);
    });
  });
}
