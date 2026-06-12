import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Disk LRU cache for survey tiles (F11: offline redisplay).
///
/// Stores tiles at `<root>/<filename encoded from the key>` and manages
/// LRU eviction via index.json (key → size and last access).
/// On startup, reconciles the index with the actual files to repair
/// inconsistencies.
class DiskTileCache {
  DiskTileCache({
    required this.rootDir,
    required this.limitBytes,
    this.accessPersistDelay = const Duration(seconds: 2),
  });

  final Directory rootDir;

  /// Capacity limit in [bytes] (configurable via settings)
  int limitBytes;

  /// Delay before lastAccess updates from get() are persisted in a batch
  final Duration accessPersistDelay;

  final Map<String, _IndexEntry> _index = {};
  var _accessCounter = 0;
  Future<void>? _initFuture;
  var _persistScheduled = false;

  File get _indexFile => File('${rootDir.path}/index.json');

  /// Concurrent callers wait until initialization completes (race protection)
  Future<void> _ensureInitialized() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    await rootDir.create(recursive: true);
    if (await _indexFile.exists()) {
      try {
        final json =
            jsonDecode(await _indexFile.readAsString()) as Map<String, dynamic>;
        for (final entry in json.entries) {
          final value = entry.value as Map<String, dynamic>;
          _index[entry.key] = _IndexEntry(
            sizeBytes: value['size'] as int,
            lastAccess: value['access'] as int,
          );
        }
      } on FormatException {
        _index.clear(); // Rebuild a corrupted index from scratch
      }
    }
    // Reconcile with actual files: drop entries whose file is missing
    _index.removeWhere((key, _) => !_fileOf(key).existsSync());
    _accessCounter = _index.values.fold(
      0,
      (max, e) => e.lastAccess > max ? e.lastAccess : max,
    );
  }

  File _fileOf(String key) =>
      File('${rootDir.path}/${key.replaceAll('/', '_')}.bin');

  Future<Uint8List?> get(String key) async {
    await _ensureInitialized();
    final entry = _index[key];
    if (entry == null) return null;
    final file = _fileOf(key);
    if (!await file.exists()) {
      _index.remove(key);
      return null;
    }
    entry.lastAccess = ++_accessCounter;
    // Persist access updates in batches too, so LRU order survives restarts
    _scheduleAccessPersist();
    return file.readAsBytes();
  }

  void _scheduleAccessPersist() {
    if (_persistScheduled) return;
    _persistScheduled = true;
    unawaited(
      Future<void>.delayed(accessPersistDelay).then((_) {
        _persistScheduled = false;
        return _persistIndex();
      }),
    );
  }

  Future<void> put(String key, Uint8List bytes) async {
    await _ensureInitialized();
    await _fileOf(key).writeAsBytes(bytes);
    _index[key] = _IndexEntry(
      sizeBytes: bytes.length,
      lastAccess: ++_accessCounter,
    );
    await _evictToLimit();
    await _persistIndex();
  }

  Future<void> _evictToLimit() async {
    var total = totalBytes;
    if (total <= limitBytes) return;
    final keysByAccess = _index.keys.toList()
      ..sort((a, b) => _index[a]!.lastAccess.compareTo(_index[b]!.lastAccess));
    for (final key in keysByAccess) {
      if (total <= limitBytes) break;
      total -= _index[key]!.sizeBytes;
      _index.remove(key);
      final file = _fileOf(key);
      if (await file.exists()) await file.delete();
    }
  }

  int get totalBytes => _index.values.fold(0, (sum, e) => sum + e.sizeBytes);

  Future<void> _persistIndex() async {
    await _indexFile.writeAsString(
      jsonEncode({
        for (final entry in _index.entries)
          entry.key: {
            'size': entry.value.sizeBytes,
            'access': entry.value.lastAccess,
          },
      }),
    );
  }

  Future<void> clear() async {
    await _ensureInitialized();
    for (final key in _index.keys.toList()) {
      final file = _fileOf(key);
      if (await file.exists()) await file.delete();
    }
    _index.clear();
    await _persistIndex();
  }
}

class _IndexEntry {
  _IndexEntry({required this.sizeBytes, required this.lastAccess});

  final int sizeBytes;
  int lastAccess;
}
