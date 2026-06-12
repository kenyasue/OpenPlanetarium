import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/data/catalog/tile_binary_codec.dart';
import 'package:open_planetarium/data/network/vizier_download_client.dart';
import 'package:open_planetarium/domain/exceptions.dart';
import 'package:open_planetarium/domain/spatial/spatial_index.dart';

void main() {
  final index = SpatialIndex();

  group('SpatialIndex.tileBounds', () {
    test('tile centers lie inside their bounds, and points inside belong to that tile', () {
      for (var tile = 0; tile < index.tileCount; tile++) {
        final b = index.tileBounds(tile);
        final center = index.tileCenter(tile);
        expect(center.raDeg, inInclusiveRange(b.raMinDeg, b.raMaxDeg));
        expect(center.decDeg, inInclusiveRange(b.decMinDeg, b.decMaxDeg));
        // A representative interior point (the center) maps back to the same tile
        expect(index.tileIndexOf(center.raDeg, center.decDeg), tile);
      }
    });

    test('the combined tile bounds cover the whole sky', () {
      // In each Dec band, the RA rectangles fill 360° without gaps
      var coveredBands = 0.0;
      for (var tile = 0; tile < index.tileCount; tile++) {
        final b = index.tileBounds(tile);
        coveredBands += (b.raMaxDeg - b.raMinDeg) / 360.0;
      }
      expect(coveredBands, closeTo(SpatialIndex.bandCount, 1e-9));
    });
  });

  group('VizieRDownloadClient.fetchManifest', () {
    test('generates all tiles locally without sha256', () async {
      final client = VizieRDownloadClient(index: index);
      final manifest = await client.fetchManifest('tycho2_m10');
      expect(manifest.tiles, hasLength(index.tileCount));
      expect(manifest.tiles.every((t) => t.sha256.isEmpty), isTrue);
    });

    test('unsupported catalog IDs raise an unavailable error', () {
      final client = VizieRDownloadClient(index: index);
      expect(
        () => client.fetchManifest('unknown'),
        throwsA(isA<DownloadUnavailableException>()),
      );
    });
  });

  group('VizieRDownloadClient.adqlForTile', () {
    test('includes the tile RA/Dec range and the VT pre-filter', () {
      final tile = index.tileIndexOf(83.8, -5.4); // near Orion
      final adql = VizieRDownloadClient.adqlForTile(index, tile);
      final b = index.tileBounds(tile);
      expect(adql, contains('FROM "I/259/tyc2"'));
      expect(adql, contains('RAmdeg>=${b.raMinDeg}'));
      expect(adql, contains('RAmdeg<${b.raMaxDeg}'));
      expect(adql, contains('DEmdeg>=${b.decMinDeg}'));
      expect(adql, contains('VTmag<='));
    });

    test('the topmost band (celestial north pole) includes Dec=+90', () {
      final tile = index.tileIndexOf(0, 89.9);
      final adql = VizieRDownloadClient.adqlForTile(index, tile);
      expect(adql, contains('DEmdeg<=90'));
    });
  });

  group('VizieRDownloadClient.parseTycho2Csv', () {
    // Test with a tile near Orion
    final tile = index.tileIndexOf(84.0, -5.0);
    final b = index.tileBounds(tile);
    final raIn = (b.raMinDeg + b.raMaxDeg) / 2;
    final decIn = (b.decMinDeg + b.decMaxDeg) / 2;

    test('V magnitude and B-V conversion and IDs are correct', () {
      // BT=9.0, VT=8.0 → V = 8.0-0.090*1.0 = 7.91, B-V = 0.85
      final csv =
          'TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag\n'
          '4767,1234,1,$raIn,$decIn,9.0,8.0\n';
      final stars = VizieRDownloadClient.parseTycho2Csv(csv, tile, index);
      expect(stars, hasLength(1));
      expect(stars.first.magnitude, closeTo(7.91, 1e-9));
      expect(stars.first.colorIndexBV, closeTo(0.85, 1e-9));
      expect(stars.first.id, 4767 * 200000 + 1234 * 4 + 1);
      expect(stars.first.tileIndex, tile);
    });

    test('missing BT is accepted as V=VT with unknown B-V', () {
      final csv =
          'TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag\n'
          '1,2,1,$raIn,$decIn,,8.5\n';
      final stars = VizieRDownloadClient.parseTycho2Csv(csv, tile, index);
      expect(stars, hasLength(1));
      expect(stars.first.magnitude, 8.5);
      expect(stars.first.colorIndexBV, isNull);
    });

    test('mag 6.5 and brighter (bundled in BSC) and fainter than mag 10 are excluded', () {
      final csv =
          'TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag\n'
          '1,1,1,$raIn,$decIn,,6.4\n' // too bright (covered by BSC)
          '1,2,1,$raIn,$decIn,,10.4\n' // too faint
          '1,3,1,$raIn,$decIn,,9.9\n'; // accepted
      final stars = VizieRDownloadClient.parseTycho2Csv(csv, tile, index);
      expect(stars, hasLength(1));
      expect(stars.first.id, 1 * 200000 + 3 * 4 + 1);
    });

    test('rows with missing coordinates and stars outside the tile are skipped', () {
      final csv =
          'TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag\n'
          '1,1,1,,,8.0,8.0\n' // missing coordinates
          '1,2,1,200.0,80.0,,8.0\n' // outside the tile
          '1,3,1,$raIn,$decIn,,8.0\n'; // accepted
      final stars = VizieRDownloadClient.parseTycho2Csv(csv, tile, index);
      expect(stars, hasLength(1));
    });

    test('unexpected column layout raises a corruption error', () {
      expect(
        () => VizieRDownloadClient.parseTycho2Csv('foo,bar\n1,2\n', 0, index),
        throwsA(isA<CatalogCorruptedException>()),
      );
    });

    test('parse results round-trip through TileBinaryCodec', () {
      final csv =
          'TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag\n'
          '4767,1234,1,$raIn,$decIn,9.0,8.0\n';
      final stars = VizieRDownloadClient.parseTycho2Csv(csv, tile, index);
      const codec = TileBinaryCodec();
      final decoded = codec.decode(codec.encode({tile: stars}));
      expect(decoded[tile], hasLength(1));
      expect(decoded[tile]!.first.id, stars.first.id);
      expect(decoded[tile]!.first.magnitude, closeTo(7.91, 1e-4));
    });
  });
}
