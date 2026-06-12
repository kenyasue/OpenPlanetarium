import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../domain/models/deep_sky_object.dart';
import '../../domain/models/sky_point.dart';
import 'sky_layer_renderer.dart';

/// Renders type icons and labels for deep sky objects (Messier, NGC/IC, nebula catalogs) (F7).
///
/// Type colors (docs/functional-design.md UI design):
/// galaxy = pale purple / nebula = pale red / cluster = pale yellow.
/// Filtering of visible objects (catalog, magnitude) is done upstream by
/// visibleDsosProvider; this class only handles zoom-linked labels and
/// overlap decluttering.
class DsoRenderer implements SkyLayerRenderer {
  DsoRenderer({required this.dsos, this.showLabels = true});

  final List<DeepSkyObject> dsos;

  /// Whether to show DSO name labels on the celestial sphere (DSO tab in celestial object settings)
  final bool showLabels;

  static const _typeColors = {
    ObjectType.galaxy: Color(0xFFC9A9E8),
    ObjectType.openCluster: Color(0xFFE8DCA9),
    ObjectType.globularCluster: Color(0xFFE8D49A),
    ObjectType.nebula: Color(0xFFE8A9B4),
    ObjectType.planetaryNebula: Color(0xFFA9E8D8),
    ObjectType.supernovaRemnant: Color(0xFFE8B9A9),
    ObjectType.darkNebula: Color(0xFF8A93A0),
    ObjectType.other: Color(0xFFB8C4D0),
  };

  /// Label cache (id → TextPainter; bounded since the data is fixed at startup)
  static final Map<String, TextPainter> _labelCache = {};

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final state = context.state;
    final bounds = (Offset.zero & state.screenSize).inflate(40);

    // Labels appear progressively from brighter objects as the view zooms in
    // (LabelDeclutter further thins out overlaps)
    final labelLimitMag = state.fovDeg > 60
        ? 4.5
        : state.fovDeg > 30
        ? 6.5
        : 99.0;

    for (final dso in dsos) {
      final mag = dso.magnitude ?? 12.0;
      final isMessier = dso.messierNumber != null;

      final pos = projection.project(SkyPoint(dso.raDeg, dso.decDeg));
      if (pos == null || !bounds.contains(pos)) continue;

      final sizePx = _iconSize(dso, context.pxPerDeg);
      final color = _typeColors[dso.objectType]!;
      _drawIcon(canvas, pos, sizePx, dso.objectType, color);

      if (showLabels &&
          (mag <= labelLimitMag || (isMessier && state.fovDeg <= 60))) {
        final painter = _labelCache.putIfAbsent(dso.id, () {
          return TextPainter(
            text: TextSpan(
              text: dso.displayName,
              style: TextStyle(
                color: color.withValues(alpha: 0.85),
                fontSize: 11,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
        });
        final rect = Rect.fromLTWH(
          pos.dx + sizePx / 2 + 3,
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

  double _iconSize(DeepSkyObject dso, double pxPerDeg) {
    final majAxDeg = (dso.majorAxisArcmin ?? 10.0) / 60.0;
    return (majAxDeg * pxPerDeg).clamp(7.0, 48.0);
  }

  void _drawIcon(
    Canvas canvas,
    Offset pos,
    double size,
    ObjectType type,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final half = size / 2;

    switch (type) {
      case ObjectType.galaxy:
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(-math.pi / 5);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size,
            height: size * 0.45,
          ),
          paint,
        );
        canvas.restore();
      case ObjectType.openCluster:
        // Dotted circle
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawCircle(
            pos + Offset(math.cos(angle), math.sin(angle)) * half,
            1.1,
            Paint()..color = paint.color,
          );
        }
      case ObjectType.globularCluster:
        canvas.drawCircle(pos, half, paint);
        canvas.drawLine(
          pos - Offset(half * 0.7, 0),
          pos + Offset(half * 0.7, 0),
          paint,
        );
        canvas.drawLine(
          pos - Offset(0, half * 0.7),
          pos + Offset(0, half * 0.7),
          paint,
        );
      case ObjectType.nebula:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCircle(center: pos, radius: half * 0.85),
            Radius.circular(half * 0.35),
          ),
          paint,
        );
      case ObjectType.planetaryNebula:
        canvas.drawCircle(pos, half * 0.5, paint);
        for (var i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          final dir = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(pos + dir * half * 0.6, pos + dir * half, paint);
        }
      case ObjectType.darkNebula:
        // Dashed-style rounded rectangle (dim outline to distinguish from emission nebulae)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCircle(center: pos, radius: half * 0.85),
            Radius.circular(half * 0.35),
          ),
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      case ObjectType.supernovaRemnant || ObjectType.other:
        canvas.drawCircle(pos, half * 0.7, paint);
    }
  }
}
