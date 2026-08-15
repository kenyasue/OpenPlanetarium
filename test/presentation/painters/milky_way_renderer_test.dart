import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/application/viewport/viewport_controller.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/astro/projection.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/horizontal_coord.dart';
import 'package:open_planetarium/domain/models/viewport_state.dart';
import 'package:open_planetarium/presentation/painters/milky_way_renderer.dart';
import 'package:open_planetarium/presentation/painters/sky_layer_renderer.dart';

const _engine = AstroEngine();

/// Phone-sized viewport (the device the zoom OOM was reported on)
const _size = Size(414, 896);
final _time = DateTime.utc(2026, 8, 15, 12);
const _loc = GeoLocation.tokyo;

/// The widest band in MilkyWayRenderer's band table, and its alpha
const _widestBandDeg = 14.0;
const _widestBandAlpha = 0.030;

SkyRenderContext _contextAt(double fovDeg) {
  final center = _engine.horizontalToEquatorial(
    const HorizontalCoord(altDeg: 35, azDeg: 180),
    _loc,
    _time,
  );
  final state = ViewportState(
    center: center,
    fovDeg: fovDeg,
    screenSize: _size,
    observationTime: _time,
    location: _loc,
    viewportId: 0,
  );
  return SkyRenderContext(projection: ViewProjection(state), state: state);
}

void main() {
  group('MilkyWayRenderer.bandLayers', () {
    test('is independent of the zoom level', () {
      // Widths come back in degrees, so the same layer stack serves every FOV.
      // This is what keeps the cost of the band from scaling with zoom.
      final a = MilkyWayRenderer.bandLayers(_widestBandDeg, _widestBandAlpha);
      final b = MilkyWayRenderer.bandLayers(_widestBandDeg, _widestBandAlpha);
      expect(a.map((l) => l.widthDeg), b.map((l) => l.widthDeg));
      expect(a.map((l) => l.alpha), b.map((l) => l.alpha));
    });

    test('accumulates to the band alpha at the centre', () {
      // Every layer covers the centre line, so their alphas must sum to the
      // band's nominal alpha — the core keeps its original brightness.
      final layers = MilkyWayRenderer.bandLayers(
        _widestBandDeg,
        _widestBandAlpha,
      );
      final total = layers.fold<double>(0, (sum, l) => sum + l.alpha);
      expect(total, closeTo(_widestBandAlpha, 1e-9));
    });

    test('is ordered widest and faintest first', () {
      // Drawing order matters: narrower strokes go on top and add the alpha
      // their ring is still missing.
      final layers = MilkyWayRenderer.bandLayers(
        _widestBandDeg,
        _widestBandAlpha,
      );
      expect(layers.length, greaterThan(1));
      for (var i = 1; i < layers.length; i++) {
        expect(layers[i].widthDeg, lessThan(layers[i - 1].widthDeg));
      }
    });

    test('fades out beyond the nominal band edge', () {
      final layers = MilkyWayRenderer.bandLayers(
        _widestBandDeg,
        _widestBandAlpha,
      );
      // Widest stroke reaches past the nominal edge (soft outer falloff)…
      expect(layers.first.widthDeg, greaterThan(_widestBandDeg));
      // …contributing far less than the ring at the steepest part of the falloff
      final peak = layers.map((l) => l.alpha).reduce(math.max);
      expect(layers.first.alpha, lessThan(peak / 2));
    });

    test('the accumulated profile never exceeds the band alpha', () {
      final layers = MilkyWayRenderer.bandLayers(
        _widestBandDeg,
        _widestBandAlpha,
      );
      for (var i = 0; i < layers.length; i++) {
        final covered = layers
            .take(i + 1)
            .fold<double>(0, (sum, l) => sum + l.alpha);
        expect(covered, lessThanOrEqualTo(_widestBandAlpha + 1e-9));
      }
    });
  });

  group('MilkyWayRenderer.render', () {
    test('records without throwing at the maximum zoom', () {
      final recorder = PictureRecorder();
      const MilkyWayRenderer().render(Canvas(recorder), _contextAt(kMinFovDeg));
      recorder.endRecording().dispose();
    });

    test('records without throwing at the widest field of view', () {
      final recorder = PictureRecorder();
      const MilkyWayRenderer().render(Canvas(recorder), _contextAt(kMaxFovDeg));
      recorder.endRecording().dispose();
    });
  });
}
