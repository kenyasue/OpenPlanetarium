import 'dart:ui';

import '../../domain/astro/projection.dart';
import '../../domain/models/viewport_state.dart';
import 'label_declutter.dart';

/// Render context for a single frame.
///
/// In addition to projection and view state, holds the label overlap
/// avoidance (LabelDeclutter) shared across layers (so constellation names
/// and celestial object names never overlap each other).
class SkyRenderContext {
  SkyRenderContext({required this.projection, required this.state})
    : labelDeclutter = LabelDeclutter();

  final ViewProjection projection;
  final ViewportState state;
  final LabelDeclutter labelDeclutter;

  /// Screen pixels per degree (for label LOD and size calculations)
  double get pxPerDeg => state.screenSize.height / state.fovDeg;
}

/// Render layer interface for the sky canvas.
///
/// SkyPainter draws layers in list order. New display layers (stars,
/// constellations, surveys, etc.) can be added simply by implementing this
/// interface (docs/architecture.md extensibility requirements).
abstract class SkyLayerRenderer {
  void render(Canvas canvas, SkyRenderContext context);
}

/// Helper that draws a continuous curve on the celestial sphere (horizon,
/// grid, etc.) as a polyline.
///
/// Splits the path where points are unprojectable (null) or discontinuous
/// (distance between adjacent points exceeds the threshold).
void drawSkyPolyline(
  Canvas canvas,
  Paint paint,
  List<Offset?> points, {
  required double breakDistancePx,
}) {
  Path? path;
  Offset? prev;
  for (final point in points) {
    if (point == null) {
      prev = null;
      continue;
    }
    if (prev == null || (point - prev).distance > breakDistancePx) {
      if (path != null) canvas.drawPath(path, paint);
      path = Path()..moveTo(point.dx, point.dy);
    } else {
      path!.lineTo(point.dx, point.dy);
    }
    prev = point;
  }
  if (path != null) canvas.drawPath(path, paint);
}
