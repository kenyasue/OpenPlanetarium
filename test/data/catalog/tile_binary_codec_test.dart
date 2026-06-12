import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/tile_binary_codec.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/models/star.dart';

void main() {
  const codec = TileBinaryCodec();

  final sampleTiles = <int, List<Star>>{
    5: [
      const Star(
        id: 32349,
        raDeg: 101.2872,
        decDeg: -16.7161,
        magnitude: -1.44,
        tileIndex: 5,
        colorIndexBV: 0.009,
      ),
      const Star(
        id: 27989,
        raDeg: 88.7929,
        decDeg: 7.4071,
        magnitude: 0.45,
        tileIndex: 5,
        colorIndexBV: 1.85,
      ),
    ],
    42: [
      const Star(
        id: 11767,
        raDeg: 37.9546,
        decDeg: 89.2641,
        magnitude: 1.97,
        tileIndex: 42,
        // missing B-V
      ),
    ],
  };

  group('TileBinaryCodec', () {
    test('encode → decode round-trip preserves the contents', () {
      final bytes = codec.encode(sampleTiles);
      final decoded = codec.decode(bytes);

      expect(decoded.keys.toSet(), sampleTiles.keys.toSet());
      final sirius = decoded[5]![0];
      expect(sirius.id, 32349);
      expect(sirius.raDeg, closeTo(101.2872, 1e-3));
      expect(sirius.decDeg, closeTo(-16.7161, 1e-3));
      expect(sirius.magnitude, closeTo(-1.44, 1e-3));
      expect(sirius.colorIndexBV, closeTo(0.009, 1e-3));

      final polaris = decoded[42]![0];
      expect(polaris.colorIndexBV, isNull); // NaN → null
      expect(polaris.tileIndex, 42);
    });

    test('the proper-name map is applied', () {
      final bytes = codec.encode(sampleTiles);
      final decoded = codec.decode(bytes, names: {32349: 'Sirius'});
      expect(decoded[5]![0].name, 'Sirius');
      expect(decoded[5]![0].displayName, 'Sirius');
      expect(decoded[5]![1].name, isNull);
      expect(decoded[5]![1].displayName, 'HYG 27989');
    });

    test('magic mismatch throws CatalogCorruptedException', () {
      final bytes = codec.encode(sampleTiles);
      bytes[0] = 0x00;
      expect(
        () => codec.decode(bytes),
        throwsA(isA<CatalogCorruptedException>()),
      );
    });

    test('truncated data throws CatalogCorruptedException', () {
      final bytes = codec.encode(sampleTiles);
      final truncated = Uint8List.sublistView(bytes, 0, bytes.length - 10);
      expect(
        () => codec.decode(truncated),
        throwsA(isA<CatalogCorruptedException>()),
      );
    });

    test('too-short data throws CatalogCorruptedException', () {
      expect(
        () => codec.decode(Uint8List(4)),
        throwsA(isA<CatalogCorruptedException>()),
      );
    });
  });
}
