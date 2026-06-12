import 'dart:math' as math;
import 'dart:ui';

import 'sky_layer_renderer.dart';

/// Renders the altitude-azimuth grid (altitude circles at 30°/60°, meridians every 30° of azimuth).
class GridRenderer implements SkyLayerRenderer {
  const GridRenderer();

  static const _d2r = math.pi / 180.0;
  static const _gridColor = Color(0x14FFFFFF); // White, α≈0.08

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final stepDeg = (context.state.fovDeg / 40).clamp(0.2, 4.0);
    final breakPx = 4 * stepDeg * context.pxPerDeg + 32;

    final paint = Paint()
      ..color = _gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Altitude lines (alt = 30°, 60°)
    for (final altDeg in const [30.0, 60.0]) {
      final points = <Offset?>[
        for (var az = 0.0; az <= 360.0; az += stepDeg)
          projection.projectHorizontal(altDeg * _d2r, az * _d2r),
      ];
      drawSkyPolyline(canvas, paint, points, breakDistancePx: breakPx);
    }

    // Azimuth lines (az = 0°-330°, every 30°, altitude 0°-88°)
    for (var azDeg = 0.0; azDeg < 360.0; azDeg += 30.0) {
      final points = <Offset?>[
        for (var alt = 0.0; alt <= 88.0; alt += stepDeg)
          projection.projectHorizontal(alt * _d2r, azDeg * _d2r),
      ];
      drawSkyPolyline(canvas, paint, points, breakDistancePx: breakPx);
    }
  }
}
