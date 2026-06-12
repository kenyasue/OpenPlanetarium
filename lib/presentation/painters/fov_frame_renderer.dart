import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../application/fov/active_fov_controller.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/optics/fov_calculator.dart';
import 'sky_layer_renderer.dart';

/// Renders field of view (FOV) frames (F12).
///
/// A camera FOV is a rectangle; an eyepiece FOV is a circle. When mosaic mode
/// is enabled, rows × columns panel outlines and shooting-order numbers are shown.
class FovFrameRenderer implements SkyLayerRenderer {
  FovFrameRenderer({
    required this.frame,
    required this.fovState,
    required this.center,
  });

  final FovFrame frame;
  final ActiveFovState fovState;

  /// Frame center (selected celestial object, or the view center if none)
  final SkyPoint center;

  static const _d2r = math.pi / 180.0;

  /// TextPainter cache for panel numbers (finite set 1-36, per color)
  static final Map<(int, int), TextPainter> _panelNumberCache = {};

  /// Annotation label cache (most recent entry only: re-layout happens only
  /// when the label text or color changes. Static cache assuming a single active frame)
  static (String, int)? _cachedLabelKey;
  static TextPainter? _cachedLabelPainter;

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final color = Color(frame.colorArgb);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    if (fovState.mosaicEnabled && !frame.isCircle) {
      final plan = FovCalculator.mosaicPlan(
        center: center,
        frameWidthDeg: frame.widthDeg,
        frameHeightDeg: frame.heightDeg,
        rows: fovState.mosaicRows,
        cols: fovState.mosaicCols,
        overlapRatio: fovState.overlapRatio,
      );
      final panelPaint = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (final panel in plan.panels) {
        _drawRect(canvas, context, panel.center, panelPaint);
        _drawPanelNumber(canvas, context, panel, color);
      }
    } else if (frame.isCircle) {
      _drawCircle(canvas, context, paint);
    } else {
      _drawRect(canvas, context, center, paint);
    }

    _drawLabel(canvas, context, color);
  }

  /// Maps an angular offset (dx, dy) [deg] on the tangent plane to celestial coordinates
  SkyPoint _offsetPoint(SkyPoint origin, double dxDeg, double dyDeg) {
    final rotation = fovState.rotationDeg * _d2r;
    final cosR = math.cos(rotation);
    final sinR = math.sin(rotation);
    final rx = dxDeg * cosR - dyDeg * sinR;
    final ry = dxDeg * sinR + dyDeg * cosR;
    final cosDec = math.max(kMinCosDec, math.cos(origin.decDeg * _d2r));
    return SkyPoint(origin.raDeg + rx / cosDec, origin.decDeg + ry);
  }

  void _drawRect(
    Canvas canvas,
    SkyRenderContext context,
    SkyPoint rectCenter,
    Paint paint,
  ) {
    final halfW = frame.widthDeg / 2;
    final halfH = frame.heightDeg / 2;
    // Project each edge in 4 segments (handles distortion at wide FOV)
    final points = <Offset?>[];
    void edge(double x0, double y0, double x1, double y1) {
      for (var i = 0; i < 4; i++) {
        final f = i / 4;
        points.add(
          context.projection.project(
            _offsetPoint(rectCenter, x0 + (x1 - x0) * f, y0 + (y1 - y0) * f),
          ),
        );
      }
    }

    edge(-halfW, -halfH, halfW, -halfH);
    edge(halfW, -halfH, halfW, halfH);
    edge(halfW, halfH, -halfW, halfH);
    edge(-halfW, halfH, -halfW, -halfH);
    points.add(points.first); // Close the loop

    drawSkyPolyline(
      canvas,
      paint,
      points,
      breakDistancePx: context.state.screenSize.longestSide,
    );
  }

  void _drawCircle(Canvas canvas, SkyRenderContext context, Paint paint) {
    final radius = frame.widthDeg / 2;
    final points = <Offset?>[
      for (var i = 0; i <= 36; i++)
        context.projection.project(
          _offsetPoint(
            center,
            radius * math.cos(i * 10 * _d2r),
            radius * math.sin(i * 10 * _d2r),
          ),
        ),
    ];
    drawSkyPolyline(
      canvas,
      paint,
      points,
      breakDistancePx: context.state.screenSize.longestSide,
    );
  }

  void _drawPanelNumber(
    Canvas canvas,
    SkyRenderContext context,
    MosaicPanel panel,
    Color color,
  ) {
    final pos = context.projection.project(panel.center);
    if (pos == null) return;
    final painter = _panelNumberCache.putIfAbsent(
      (panel.order + 1, frame.colorArgb),
      () => TextPainter(
        text: TextSpan(
          text: '${panel.order + 1}',
          style: TextStyle(
            color: color.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
    painter.paint(canvas, pos - Offset(painter.width / 2, painter.height / 2));
  }

  void _drawLabel(Canvas canvas, SkyRenderContext context, Color color) {
    final anchor = context.projection.project(
      _offsetPoint(center, 0, -frame.heightDeg / 2 - frame.heightDeg * 0.08),
    );
    if (anchor == null) return;
    final key = (frame.label, frame.colorArgb);
    if (_cachedLabelKey != key) {
      _cachedLabelPainter?.dispose();
      _cachedLabelPainter = TextPainter(
        text: TextSpan(
          text: frame.label,
          style: TextStyle(color: color.withValues(alpha: 0.85), fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _cachedLabelKey = key;
    }
    final painter = _cachedLabelPainter!;
    final rect = Rect.fromCenter(
      center: anchor + Offset(0, painter.height),
      width: painter.width + 6,
      height: painter.height + 4,
    );
    if (context.labelDeclutter.tryPlace(rect)) {
      painter.paint(
        canvas,
        rect.center - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }
}
