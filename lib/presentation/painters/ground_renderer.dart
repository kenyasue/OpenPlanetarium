import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../domain/astro/projection.dart';
import 'sky_layer_renderer.dart';

/// Layer that fills the area below the horizon (the ground) with semi-transparent black.
///
/// Since the stereographic projection maps circles to circles, the image of
/// the horizon (the alt=0 great circle) is a circle (a line when the view
/// center's altitude is near 0). Instead of mesh subdivision, the circle is
/// computed analytically, and which side to fill is decided by whether the
/// zenith's image lies inside the circle.
class GroundRenderer implements SkyLayerRenderer {
  const GroundRenderer();

  /// Ground fill color (black, about 55%)
  static const fillColor = Color(0x8C000000);

  /// Maximum radius [px] still treated as a circle (beyond this, use a line approximation)
  static const _maxRadiusPx = 1e6;

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final path = groundPath(context.projection, context.state.screenSize);
    if (path == null) return;
    canvas.drawPath(path, Paint()..color = fillColor);
  }

  /// Returns the Path of the ground region (null if no ground is on screen).
  ///
  /// In tangent-plane coordinates (y = toward zenith, screen y is flipped),
  /// the horizon circle is centered on x=0:
  /// - Horizon point at the view-center azimuth: y_a = -2·tan(alt0/2)
  /// - Horizon point at the opposite azimuth:    y_b = +2/tan(alt0/2)
  /// - Image of the zenith:                      y_z = 2·cos(alt0)/(1+sin(alt0))
  @visibleForTesting
  static Path? groundPath(ViewProjection projection, Size screenSize) {
    final screenRect = Offset.zero & screenSize;
    final alt0 = projection.centerAltRad;
    final scale = projection.scalePx;
    final center = projection.screenCenter;
    final t = math.tan(alt0 / 2.0);

    // When the radius (1+t²)/|t| becomes huge (center altitude ≈ 0), use a
    // line approximation: fill below the horizon's screen y
    final radiusPx = t.abs() < 1e-12
        ? double.infinity
        : (1.0 + t * t) / t.abs() * scale;
    if (radiusPx > _maxRadiusPx) {
      final horizonY = center.dy + 2.0 * t * scale;
      if (horizonY >= screenRect.bottom) return null;
      return Path()..addRect(
        Rect.fromLTRB(
          screenRect.left,
          math.max(horizonY, screenRect.top),
          screenRect.right,
          screenRect.bottom,
        ),
      );
    }

    final yc = (1.0 - t * t) / t; // Circle center (tangent-plane y)
    final circleCenter = Offset(center.dx, center.dy - yc * scale);
    final circle = Rect.fromCircle(center: circleCenter, radius: radiusPx);

    // Zenith inside the circle → sky = inside, ground = outside (rect − circle via evenOdd).
    // At alt0=-π/2 (true nadir) the denominator is 0 so yz=+Infinity, but
    // it falls through to zenithInside=false, giving "ground = inside the circle", which is correct
    final yz = 2.0 * math.cos(alt0) / (1.0 + math.sin(alt0));
    final zenithInside = (yz - yc).abs() < radiusPx / scale;
    if (zenithInside) {
      // If even the farthest screen corner is inside the circle, no ground is visible on screen
      final farthestCorner = [
        screenRect.topLeft,
        screenRect.topRight,
        screenRect.bottomLeft,
        screenRect.bottomRight,
      ].map((p) => (p - circleCenter).distance).reduce(math.max);
      if (farthestCorner <= radiusPx) return null;
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(screenRect)
        ..addOval(circle);
    }

    // Ground = inside the circle
    if (!circle.overlaps(screenRect)) return null;
    return Path()..addOval(circle);
  }
}
