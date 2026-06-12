import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'sky_layer_renderer.dart';

/// Renders the horizon and cardinal direction labels (N/E/S/W).
class HorizonRenderer implements SkyLayerRenderer {
  const HorizonRenderer();

  static const _d2r = math.pi / 180.0;
  static const _lineColor = Color(0xFF3A5A4A);
  static const _labelColor = Color(0xFFB8CDC2);
  static const _cardinals = [
    (azDeg: 0.0, label: 'N'),
    (azDeg: 90.0, label: 'E'),
    (azDeg: 180.0, label: 'S'),
    (azDeg: 270.0, label: 'W'),
  ];

  /// TextPainter cache for cardinal labels (strings and styles are immutable,
  /// so this avoids layout() every frame)
  static final Map<String, TextPainter> _labelPainters = {
    for (final c in _cardinals)
      c.label: TextPainter(
        text: TextSpan(
          text: c.label,
          style: TextStyle(
            color: c.label == 'N' ? const Color(0xFFE8A87C) : _labelColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
  };

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final state = context.state;
    final pxPerDeg = context.pxPerDeg;
    final stepDeg = (state.fovDeg / 60).clamp(0.1, 2.0);
    final breakPx = 4 * stepDeg * pxPerDeg + 32;

    // Horizon (alt = 0, all azimuths)
    final points = <Offset?>[
      for (var az = 0.0; az <= 360.0; az += stepDeg)
        projection.projectHorizontal(0, az * _d2r),
    ];
    final linePaint = Paint()
      ..color = _lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    drawSkyPolyline(canvas, linePaint, points, breakDistancePx: breakPx);

    // Cardinal direction labels
    final screenRect = (Offset.zero & state.screenSize).inflate(20);
    for (final cardinal in _cardinals) {
      final pos = projection.projectHorizontal(0, cardinal.azDeg * _d2r);
      if (pos == null || !screenRect.contains(pos)) continue;
      final painter = _labelPainters[cardinal.label]!;
      painter.paint(
        canvas,
        pos - Offset(painter.width / 2, painter.height + 6),
      );
    }
  }
}
