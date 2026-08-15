import 'dart:math' as math;
import 'dart:ui';

import '../../domain/astro/galactic.dart';
import 'sky_layer_renderer.dart';

/// Procedural representation of the Milky Way (F1).
///
/// Draws multiple layers of faint light bands along the galactic plane
/// (galactic latitude b=0). Each band's soft edge comes from a stack of
/// concentric strokes rather than a blur filter — see [bandLayers].
/// Replacing this with a real texture is a future quality improvement candidate.
class MilkyWayRenderer implements SkyLayerRenderer {
  const MilkyWayRenderer();

  static const _bandColor = Color(0xFFAFC4DC);

  /// Layers of (galactic latitude offset [deg], band angular width [deg], alpha).
  /// Brighter toward the center; the galactic center direction (near l=0) is
  /// separately emphasized as the bulge.
  static const _bands = [
    (0.0, 14.0, 0.030),
    (0.0, 8.0, 0.040),
    (2.5, 4.0, 0.028),
    (-2.5, 4.0, 0.028),
  ];

  /// Number of concentric strokes used to approximate one band's soft edge
  static const _layerCount = 5;

  /// Concentric strokes approximating a band with a softened cross-section.
  ///
  /// The bands used to be a single stroke carrying
  /// `MaskFilter.blur(sigma = 0.35 * strokeWidth)`. A blurred draw is
  /// rasterized into an offscreen sized from the draw's bounds, and both the
  /// bounds and the stroke width scale with pxPerDeg (= screen height / FOV):
  /// at the 0.5° minimum FOV the stroke is ~25,000 px wide and the projected
  /// galactic circle spans ±800,000 px. On an iPhone that pushed the process
  /// past the 2 GB memory limit and iOS killed the app while zooming in past
  /// roughly 20° FOV (`EXC_RESOURCE ... high watermark memory limit exceeded`).
  /// Neither capping the sigma nor clipping the canvas bounds that allocation —
  /// only not asking for the blur does.
  ///
  /// So the falloff is drawn instead of filtered: widest and faintest stroke
  /// first, each narrower stroke adding the alpha its ring is still missing.
  /// A point at distance d from the band centre is covered by every stroke at
  /// least 2d wide, so the accumulated alpha traces the cross-section profile.
  /// Cost is a handful of ordinary strokes and no offscreen at any zoom level.
  ///
  /// Widths are returned in degrees (resolution independent), so the result
  /// depends only on the band and can be scaled by pxPerDeg when drawing.
  static List<({double widthDeg, double alpha})> bandLayers(
    double widthDeg,
    double alpha,
  ) {
    // Chosen to match the previous blur: full strength until one sigma inside
    // the nominal edge, faded out two sigma beyond it.
    final sigma = 0.35 * widthDeg;
    final core = math.max(0.0, widthDeg / 2 - sigma);
    final outer = widthDeg / 2 + 2 * sigma;

    final layers = <({double widthDeg, double alpha})>[];
    // Alpha compositing is 1-(1-a₁)(1-a₂)…, but these alphas total well under
    // 0.1, where that differs from the plain sum by less than 0.5%.
    var covered = 0.0;
    for (var i = _layerCount; i >= 0; i--) {
      final ringOuter = i == 0
          ? core
          : core + (outer - core) * i / _layerCount;
      final ringInner = i == 0
          ? 0.0
          : core + (outer - core) * (i - 1) / _layerCount;
      final target =
          alpha * _profile((ringInner + ringOuter) / 2, core, outer);
      final layerAlpha = target - covered;
      // Skip rings whose contribution would round away to nothing
      if (layerAlpha <= 0.0005) continue;
      covered += layerAlpha;
      layers.add((widthDeg: ringOuter * 2, alpha: layerAlpha));
    }
    return layers;
  }

  /// Cross-section profile: full strength inside [core], smoothly to 0 at [outer]
  static double _profile(double d, double core, double outer) {
    if (d <= core) return 1.0;
    if (d >= outer) return 0.0;
    final t = (d - core) / (outer - core);
    return 1.0 - t * t * (3.0 - 2.0 * t);
  }

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final pxPerDeg = context.pxPerDeg;
    final breakPx = context.state.screenSize.longestSide * 0.5 + 64;

    for (final (bOffset, widthDeg, alpha) in _bands) {
      // Projected once per band and reused by every layer of that band
      final points = <Offset?>[
        for (var l = 0.0; l <= 360.0; l += 3.0)
          context.projection.project(Galactic.toEquatorial(l, bOffset)),
      ];
      for (final layer in bandLayers(widthDeg, alpha)) {
        final paint = Paint()
          ..color = _bandColor.withValues(alpha: layer.alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer.widthDeg * pxPerDeg
          ..strokeCap = StrokeCap.round;
        drawSkyPolyline(canvas, paint, points, breakDistancePx: breakPx);
      }
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
