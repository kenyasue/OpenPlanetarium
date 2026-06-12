import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/astro/astro_engine.dart';
import 'package:open_planetarium/domain/astro/projection.dart';
import 'package:open_planetarium/domain/models/geo_location.dart';
import 'package:open_planetarium/domain/models/horizontal_coord.dart';
import 'package:open_planetarium/domain/models/viewport_state.dart';
import 'package:open_planetarium/presentation/painters/ground_renderer.dart';

const _engine = AstroEngine();
const _size = Size(1280, 720);
final _time = DateTime.utc(2026, 6, 11, 14);
const _loc = GeoLocation.tokyo;

ViewProjection _projectionAt(double centerAltDeg, {double fovDeg = 70}) {
  final center = _engine.horizontalToEquatorial(
    HorizontalCoord(altDeg: centerAltDeg, azDeg: 180),
    _loc,
    _time,
  );
  return ViewProjection(
    ViewportState(
      center: center,
      fovDeg: fovDeg,
      screenSize: _size,
      observationTime: _time,
      location: _loc,
      viewportId: 0,
    ),
  );
}

/// For horizontal-coordinate samples projected onto the screen, verify that
/// "inside the ground Path ⟺ alt < 0" holds.
void _verifyGroundPath(ViewProjection projection) {
  final path = GroundRenderer.groundPath(projection, _size);
  final screenRect = Offset.zero & _size;
  const d2r = math.pi / 180.0;

  for (var alt = -80.0; alt <= 80.0; alt += 8.0) {
    // Skip near the horizon due to numerical error
    if (alt.abs() < 1.0) continue;
    for (var az = 0.0; az < 360.0; az += 20.0) {
      final pos = projection.projectHorizontal(alt * d2r, az * d2r);
      if (pos == null || !screenRect.deflate(2).contains(pos)) continue;
      final inGround = path?.contains(pos) ?? false;
      expect(
        inGround,
        alt < 0,
        reason:
            'alt=$alt az=$az pos=$pos '
            '(centerAlt=${projection.centerAltRad / d2r}°)',
      );
    }
  }
}

void main() {
  group('GroundRenderer.groundPath', () {
    test('center above the horizon (altitude 35°)', () {
      _verifyGroundPath(_projectionAt(35));
    });

    test('center below the horizon (altitude -35°)', () {
      _verifyGroundPath(_projectionAt(-35));
    });

    test(
      'center on the horizon (altitude 0°, straight-line approximation)',
      () {
        _verifyGroundPath(_projectionAt(0));
      },
    );

    test(
      'center near the horizon (altitude 0.05°, huge-radius straight-line approximation)',
      () {
        _verifyGroundPath(_projectionAt(0.05));
      },
    );

    test(
      'looking at the zenith (altitude 90°), the ground is outside the horizon circle',
      () {
        _verifyGroundPath(_projectionAt(89.9, fovDeg: 120));
      },
    );

    test(
      'looking at the nadir (altitude -89°), the ground is inside the horizon circle',
      () {
        _verifyGroundPath(_projectionAt(-89, fovDeg: 120));
      },
    );

    test(
      'narrow FOV with the ground off-screen (altitude 60°, FOV 5°) yields a null Path',
      () {
        final path = GroundRenderer.groundPath(
          _projectionAt(60, fovDeg: 5),
          _size,
        );
        expect(path, isNull);
      },
    );
  });
}
