import 'dart:collection';
import 'dart:ui' as ui;

/// In-memory LRU cache for decoded tile images.
///
/// ui.Image consumes uncompressed memory, so the cache is bounded by entry
/// count (docs/architecture.md, resource usage). Evicted images are disposed.
class MemoryTileCache {
  /// The default capacity can hold one screenful plus ancestor tiles even
  /// when many tiles are visible at a wide FOV (low order)
  /// (accuracy first, F11)
  MemoryTileCache({this.capacity = 192});

  final int capacity;
  final LinkedHashMap<String, ui.Image> _entries = LinkedHashMap();

  int get length => _entries.length;

  /// On a hit, updates the LRU order and returns the image
  ui.Image? get(String key) {
    final image = _entries.remove(key);
    if (image != null) _entries[key] = image;
    return image;
  }

  void put(String key, ui.Image image) {
    _entries.remove(key)?.dispose();
    _entries[key] = image;
    while (_entries.length > capacity) {
      final oldestKey = _entries.keys.first;
      _entries.remove(oldestKey)?.dispose();
    }
  }

  bool contains(String key) => _entries.containsKey(key);

  void clear() {
    for (final image in _entries.values) {
      image.dispose();
    }
    _entries.clear();
  }
}
