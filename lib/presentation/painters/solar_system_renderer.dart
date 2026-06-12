import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../application/sky/solar_system_provider.dart';
import '../../domain/models/solar_system.dart';
import 'sky_layer_renderer.dart';

/// Renders the Sun, Moon, and planets (F7).
///
/// The MVP uses stylized representations (characteristic-color disks,
/// Saturn's rings, Jupiter's bands, Moon phases).
/// Switching to photographic textures will be considered in M8.
class SolarSystemRenderer implements SkyLayerRenderer {
  SolarSystemRenderer({
    required this.bodies,
    required this.moonPhase,
    this.showLabels = true,
  });

  final List<SolarBodyPosition> bodies;
  final MoonPhase moonPhase;
  final bool showLabels;

  /// Stylized planet colors
  static const _bodyColors = {
    SolarBodyId.sun: Color(0xFFFFF3C4),
    SolarBodyId.moon: Color(0xFFD8DCE0),
    SolarBodyId.mercury: Color(0xFFB8AFa3),
    SolarBodyId.venus: Color(0xFFF2E3BC),
    SolarBodyId.mars: Color(0xFFE08A5B),
    SolarBodyId.jupiter: Color(0xFFE3C9A4),
    SolarBodyId.saturn: Color(0xFFE8D9A8),
    SolarBodyId.uranus: Color(0xFFA8DCE0),
    SolarBodyId.neptune: Color(0xFF6F8FE0),
  };

  static final Map<SolarBodyId, TextPainter> _labels = {
    for (final body in SolarBodyId.values)
      body: TextPainter(
        text: TextSpan(
          text: body.nameJa,
          style: TextStyle(
            color: (_bodyColors[body] ?? const Color(0xFFFFFFFF)).withValues(
              alpha: 0.9,
            ),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
  };

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final bounds = (Offset.zero & context.state.screenSize).inflate(60);

    Offset? sunScreen;
    final sunPos = bodies.firstWhere((b) => b.body == SolarBodyId.sun).position;
    sunScreen = projection.project(sunPos);

    for (final body in bodies) {
      final pos = projection.project(body.position);
      if (pos == null || !bounds.contains(pos)) continue;

      final radiusPx = math.max(
        body.angularDiameterDeg * context.pxPerDeg / 2,
        switch (body.body) {
          SolarBodyId.sun || SolarBodyId.moon => 9.0,
          SolarBodyId.jupiter || SolarBodyId.venus => 4.5,
          SolarBodyId.saturn || SolarBodyId.mars => 4.0,
          _ => 3.0,
        },
      );
      final color = _bodyColors[body.body]!;

      switch (body.body) {
        case SolarBodyId.sun:
          _drawSun(canvas, pos, radiusPx, color);
        case SolarBodyId.moon:
          _drawMoon(canvas, pos, radiusPx, sunScreen);
        case SolarBodyId.saturn:
          _drawDisk(canvas, pos, radiusPx, color);
          _drawSaturnRing(canvas, pos, radiusPx);
        case SolarBodyId.jupiter:
          _drawDisk(canvas, pos, radiusPx, color);
          _drawJupiterBands(canvas, pos, radiusPx);
        default:
          _drawDisk(canvas, pos, radiusPx, color);
      }

      if (showLabels) {
        final painter = _labels[body.body]!;
        final rect = Rect.fromLTWH(
          pos.dx + radiusPx + 4,
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

  void _drawSun(Canvas canvas, Offset pos, double radius, Color color) {
    // Strong glow (3 layers) + body
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        pos,
        radius * 4,
        [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.0),
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(pos, radius * 4, glowPaint);
    canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFFFFFBEF));
  }

  void _drawMoon(Canvas canvas, Offset pos, double radius, Offset? sunScreen) {
    // Draw the shadowed side (full disk) first
    canvas.drawCircle(pos, radius, Paint()..color = const Color(0xFF3A3F46));

    final k = moonPhase.illuminatedFraction;
    if (k <= 0.01) return;

    // The lit side faces the Sun (direction fixed simply if off-screen)
    final sunDir = sunScreen != null && (sunScreen - pos).distance > 1
        ? (sunScreen - pos)
        : const Offset(1, 0);
    final angle = math.atan2(sunDir.dy, sunDir.dx);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final litPaint = Paint()..color = const Color(0xFFE8ECF0);
    if (k >= 0.99) {
      canvas.drawCircle(Offset.zero, radius, litPaint);
    } else {
      // Phases are represented by a lit half-circle + terminator ellipse (half-width = r|2k-1|)
      final terminatorHalfWidth = radius * (2 * k - 1).abs();
      final path = Path()
        ..moveTo(0, -radius)
        // Half-circle on the lit side (+x direction)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: radius),
          -math.pi / 2,
          math.pi,
          false,
        );
      // Terminator: bulges toward the dark side for k>0.5, cuts into the lit side for k<0.5
      final terminatorRect = Rect.fromCenter(
        center: Offset.zero,
        width: terminatorHalfWidth * 2,
        height: radius * 2,
      );
      path.arcTo(
        terminatorRect,
        math.pi / 2,
        (k >= 0.5 ? 1 : -1) * math.pi,
        false,
      );
      path.close();
      canvas.drawPath(path, litPaint);
    }
    canvas.restore();
  }

  void _drawDisk(Canvas canvas, Offset pos, double radius, Color color) {
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(pos, radius * 2.6, [
        color.withValues(alpha: 0.35),
        color.withValues(alpha: 0.0),
      ]);
    canvas.drawCircle(pos, radius * 2.6, glowPaint);
    canvas.drawCircle(pos, radius, Paint()..color = color);
  }

  void _drawSaturnRing(Canvas canvas, Offset pos, double radius) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(-0.35); // Stylized ring tilt (fixed)
    final ringPaint = Paint()
      ..color = const Color(0xFFD8C58A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, radius * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 4.4,
        height: radius * 1.6,
      ),
      ringPaint,
    );
    canvas.restore();
  }

  void _drawJupiterBands(Canvas canvas, Offset pos, double radius) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: pos, radius: radius)),
    );
    final bandPaint = Paint()
      ..color = const Color(0xFFB08D62).withValues(alpha: 0.7)
      ..strokeWidth = math.max(1.0, radius * 0.22);
    for (final dy in [-radius * 0.35, radius * 0.3]) {
      canvas.drawLine(
        Offset(pos.dx - radius, pos.dy + dy),
        Offset(pos.dx + radius, pos.dy + dy),
        bandPaint,
      );
    }
    canvas.restore();
  }
}
