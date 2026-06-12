import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../application/sky/minor_body_provider.dart';
import '../../domain/models/minor_body.dart';
import '../../domain/models/sky_point.dart';
import 'sky_layer_renderer.dart';

/// Renders asteroids and comets (F7 extension).
///
/// Asteroid = diamond marker; comet = coma plus a stylized anti-sunward tail.
/// Like DSOs, a zoom-dependent magnitude gate prevents overcrowding at wide FOV.
class MinorBodyRenderer implements SkyLayerRenderer {
  MinorBodyRenderer({required this.bodies, required this.sunPosition});

  final List<MinorBodyPosition> bodies;

  /// Used to compute comet tail direction (extends away from the Sun)
  final SkyPoint sunPosition;

  static const _asteroidColor = Color(0xFFD8CFA8);
  static const _cometColor = Color(0xFFA8E8DC);

  /// Label cache (id → TextPainter)
  static final Map<String, TextPainter> _labelCache = {};

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final bounds = (Offset.zero & context.state.screenSize).inflate(40);

    // Zoom-linked visibility and label limits (tiers matching the DSO renderer)
    final fov = context.state.fovDeg;
    final limitMag = fov > 60
        ? 9.0
        : fov > 30
        ? 11.0
        : 99.0;
    final labelLimitMag = fov > 60
        ? 7.0
        : fov > 30
        ? 9.0
        : 12.0;

    final sunScreen = projection.project(sunPosition);

    for (final item in bodies) {
      if (item.magnitude > limitMag) continue;
      final pos = projection.project(item.position);
      if (pos == null || !bounds.contains(pos)) continue;

      switch (item.body.kind) {
        case MinorBodyKind.asteroid:
          _drawAsteroid(canvas, pos);
        case MinorBodyKind.comet:
          _drawComet(canvas, pos, sunScreen);
      }

      if (item.magnitude <= labelLimitMag) {
        final painter = _labelCache.putIfAbsent(item.body.id, () {
          final color = item.body.kind == MinorBodyKind.asteroid
              ? _asteroidColor
              : _cometColor;
          return TextPainter(
            text: TextSpan(
              text: item.body.displayName,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
        });
        final rect = Rect.fromLTWH(
          pos.dx + 7,
          pos.dy - painter.height / 2,
          painter.width + 4,
          painter.height,
        );
        if (context.labelDeclutter.tryPlace(rect)) {
          painter.paint(canvas, rect.topLeft);
        }
      }
    }
  }

  void _drawAsteroid(Canvas canvas, Offset pos) {
    const half = 4.0;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - half)
      ..lineTo(pos.dx + half, pos.dy)
      ..lineTo(pos.dx, pos.dy + half)
      ..lineTo(pos.dx - half, pos.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = _asteroidColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawComet(Canvas canvas, Offset pos, Offset? sunScreen) {
    // Coma (nucleus)
    canvas.drawCircle(
      pos,
      2.5,
      Paint()..color = _cometColor.withValues(alpha: 0.9),
    );

    // Tail: points away from the Sun's screen position (fixed upper-right if the Sun is off-screen)
    final away = sunScreen != null && (pos - sunScreen).distance > 1
        ? (pos - sunScreen) / (pos - sunScreen).distance
        : const Offset(0.7, -0.7);
    final tailPaint = Paint()
      ..color = _cometColor.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final spread in [-0.25, 0.0, 0.25]) {
      final angle = math.atan2(away.dy, away.dx) + spread;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(pos + dir * 3.5, pos + dir * 14.0, tailPaint);
    }
  }
}
