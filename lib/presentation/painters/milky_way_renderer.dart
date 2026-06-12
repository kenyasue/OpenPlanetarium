import 'dart:ui';

import '../../domain/astro/galactic.dart';
import 'sky_layer_renderer.dart';

/// Procedural representation of the Milky Way (F1).
///
/// Draws multiple layers of faint light bands along the galactic plane
/// (galactic latitude b=0) using blurred strokes.
/// Replacing this with a real texture is a future quality improvement candidate.
class MilkyWayRenderer implements SkyLayerRenderer {
  const MilkyWayRenderer();

  /// Layers of (galactic latitude offset [deg], band angular width [deg], alpha).
  /// Brighter toward the center; the galactic center direction (near l=0) is
  /// separately emphasized as the bulge.
  static const _bands = [
    (0.0, 14.0, 0.030),
    (0.0, 8.0, 0.040),
    (2.5, 4.0, 0.028),
    (-2.5, 4.0, 0.028),
  ];

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final pxPerDeg = context.pxPerDeg;
    final breakPx = context.state.screenSize.longestSide * 0.5 + 64;

    for (final (bOffset, widthDeg, alpha) in _bands) {
      final points = <Offset?>[
        for (var l = 0.0; l <= 360.0; l += 3.0)
          context.projection.project(Galactic.toEquatorial(l, bOffset)),
      ];
      final strokeWidth = widthDeg * pxPerDeg;
      final paint = Paint()
        ..color = const Color(0xFFAFC4DC).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          strokeWidth * 0.35 + 1,
        );
      drawSkyPolyline(canvas, paint, points, breakDistancePx: breakPx);
    }

    // Emphasis on the galactic center bulge (toward Sagittarius, l=0, b=0)
    final bulgeCenter = context.projection.project(Galactic.toEquatorial(0, 0));
    if (bulgeCenter != null) {
      final radius = 9.0 * pxPerDeg;
      canvas.drawCircle(
        bulgeCenter,
        radius,
        Paint()
          ..shader = Gradient.radial(bulgeCenter, radius, [
            const Color(0xFFC8D4E4).withValues(alpha: 0.06),
            const Color(0x00C8D4E4),
          ]),
      );
    }
  }
}
