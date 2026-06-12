import 'dart:typed_data';

import '../../domain/exceptions.dart';
import '../../domain/models/star.dart';

/// Encoder/decoder for catalog tile binaries.
///
/// Format (little-endian):
/// ```
/// header: uint32 magic 'FPC1' (0x31435046) | uint32 version | uint32 tileCount
/// tile:   int32 tileIndex | int32 starCount
/// record: int32 id | float32 raDeg | float32 decDeg | float32 mag | float32 bv
/// ```
/// Missing B-V is represented as NaN. Proper names live in a separate file
/// (star_names.json). Encoding is also used by the conversion script
/// (tool/catalog_converter) and the M5 download import.
class TileBinaryCodec {
  const TileBinaryCodec();

  /// Little-endian representation of 'FPC1'
  static const int magic = 0x31435046;
  static const int version = 1;
  static const int _headerBytes = 12;
  static const int _tileHeaderBytes = 8;
  static const int _recordBytes = 20;

  /// Encodes a map of tile index to star list into binary
  Uint8List encode(Map<int, List<Star>> tiles) {
    final starTotal = tiles.values.fold<int>(0, (sum, s) => sum + s.length);
    final size =
        _headerBytes +
        tiles.length * _tileHeaderBytes +
        starTotal * _recordBytes;
    final data = ByteData(size);

    var offset = 0;
    data.setUint32(offset, magic, Endian.little);
    data.setUint32(offset + 4, version, Endian.little);
    data.setUint32(offset + 8, tiles.length, Endian.little);
    offset = _headerBytes;

    final sortedTiles = tiles.keys.toList()..sort();
    for (final tileIndex in sortedTiles) {
      final stars = tiles[tileIndex]!;
      data.setInt32(offset, tileIndex, Endian.little);
      data.setInt32(offset + 4, stars.length, Endian.little);
      offset += _tileHeaderBytes;
      for (final star in stars) {
        data.setInt32(offset, star.id, Endian.little);
        data.setFloat32(offset + 4, star.raDeg, Endian.little);
        data.setFloat32(offset + 8, star.decDeg, Endian.little);
        data.setFloat32(offset + 12, star.magnitude, Endian.little);
        data.setFloat32(
          offset + 16,
          star.colorIndexBV ?? double.nan,
          Endian.little,
        );
        offset += _recordBytes;
      }
    }
    return data.buffer.asUint8List(0, size);
  }

  /// Decodes the binary. [names] is a proper-name map (id → name).
  ///
  /// Throws [CatalogCorruptedException] on malformed data.
  Map<int, List<Star>> decode(Uint8List bytes, {Map<int, String>? names}) {
    if (bytes.length < _headerBytes) {
      throw const CatalogCorruptedException('Catalog data is too short');
    }
    final data = ByteData.sublistView(bytes);
    if (data.getUint32(0, Endian.little) != magic) {
      throw const CatalogCorruptedException(
        'Invalid catalog format (magic mismatch)',
      );
    }
    if (data.getUint32(4, Endian.little) != version) {
      throw const CatalogCorruptedException('Unsupported catalog version');
    }
    final tileCount = data.getUint32(8, Endian.little);

    final result = <int, List<Star>>{};
    var offset = _headerBytes;
    for (var t = 0; t < tileCount; t++) {
      if (offset + _tileHeaderBytes > bytes.length) {
        throw const CatalogCorruptedException('Catalog data is truncated');
      }
      final tileIndex = data.getInt32(offset, Endian.little);
      final starCount = data.getInt32(offset + 4, Endian.little);
      offset += _tileHeaderBytes;
      if (starCount < 0 || offset + starCount * _recordBytes > bytes.length) {
        throw const CatalogCorruptedException('Catalog data is truncated');
      }
      final stars = List<Star>.generate(starCount, (i) {
        final base = offset + i * _recordBytes;
        final id = data.getInt32(base, Endian.little);
        final bv = data.getFloat32(base + 16, Endian.little);
        return Star(
          id: id,
          raDeg: data.getFloat32(base + 4, Endian.little),
          decDeg: data.getFloat32(base + 8, Endian.little),
          magnitude: data.getFloat32(base + 12, Endian.little),
          tileIndex: tileIndex,
          colorIndexBV: bv.isNaN ? null : bv,
          name: names?[id],
        );
      });
      offset += starCount * _recordBytes;
      result[tileIndex] = stars;
    }
    return result;
  }
}
