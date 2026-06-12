import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/astro/projection.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';
import 'package:open_planetarium/domain/models/viewport_state.dart';

ViewportState _state({
  SkyPoint? center,
  double fovDeg = 70,
  Size screenSize = const Size(1280, 720),
}) {
  return ViewportState(
    center: center ?? SkyPoint(180, 30),
    fovDeg: fovDeg,
    screenSize: screenSize,
    observationTime: DateTime.utc(2026, 6, 11, 14, 30),
    location: GeoLocation.tokyo,
    viewportId: 0,
  );
}

void main() {
  group('ViewProjection.project', () {
    test('view center projects to the screen center', () {
      final state = _state();
      final proj = ViewProjection(state);
      final screen = proj.project(state.center);
      expect(screen, isNotNull);
      expect(screen!.dx, closeTo(640, 1e-6));
      expect(screen.dy, closeTo(360, 1e-6));
    });

    test('a point at the top edge of the screen is half the FOV (fov/2) from the center', () {
      final state = _state(fovDeg: 60);
      final proj = ViewProjection(state);
      final centerSky = proj.unproject(const Offset(640, 360));
      final topSky = proj.unproject(const Offset(640, 0));
      expect(centerSky.angularDistanceTo(topSky), closeTo(30.0, 0.01));
    });

    test('points opposite the view center (angular distance >140°) return null', () {
      final state = _state();
      final proj = ViewProjection(state);
      final antipode = SkyPoint(state.center.raDeg + 180, -state.center.decDeg);
      expect(proj.project(antipode), isNull);
    });
  });

  group('ViewProjection.unproject (round-trip consistency)', () {
    test('unproject then project returns the original screen coordinates (on-screen samples)', () {
      final state = _state();
      final proj = ViewProjection(state);
      for (var dx = 100.0; dx < 1280; dx += 300) {
        for (var dy = 80.0; dy < 720; dy += 200) {
          final radec = proj.unproject(Offset(dx, dy));
          final screen = proj.project(radec);
          expect(screen, isNotNull, reason: '($dx,$dy) failed to project');
          expect(screen!.dx, closeTo(dx, 0.01), reason: 'dx mismatch ($dx,$dy)');
          expect(screen.dy, closeTo(dy, 0.01), reason: 'dy mismatch ($dx,$dy)');
        }
      }
    });

    test('round-trip still matches at high zoom (fov=1°)', () {
      final state = _state(fovDeg: 1.0);
      final proj = ViewProjection(state);
      final radec = proj.unproject(const Offset(900, 200));
      final screen = proj.project(radec);
      expect(screen!.dx, closeTo(900, 0.01));
      expect(screen.dy, closeTo(200, 0.01));
    });

    test('unprojecting the screen center matches the view center', () {
      final state = _state();
      final proj = ViewProjection(state);
      final radec = proj.unproject(const Offset(640, 360));
      expect(radec.angularDistanceTo(state.center), lessThan(1e-6));
    });
  });

  group('ViewProjection.projectHorizontal', () {
    test('passing the horizontal coordinates of the view center projects to the screen center', () {
      const d2r = math.pi / 180.0;
      const engine = AstroEngine();
      final state = _state();
      final proj = ViewProjection(state);
      final hor = engine.equatorialToHorizontal(
        state.center,
        state.location,
        state.observationTime,
      );
      final screen = proj.projectHorizontal(hor.altDeg * d2r, hor.azDeg * d2r);
      expect(screen, isNotNull);
      expect(screen!.dx, closeTo(640, 1e-6));
      expect(screen.dy, closeTo(360, 1e-6));
    });
  });
}
