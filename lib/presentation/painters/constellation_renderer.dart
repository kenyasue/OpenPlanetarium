import 'package:flutter/painting.dart';

import '../../application/settings/constellation_settings_controller.dart';
import '../../domain/models/constellation_data.dart';
import 'sky_layer_renderer.dart';

/// Renders constellation lines, boundaries, and constellation names (F6).
///
/// Drawn after the grid and before stars (constellation lines stay in a
/// lower layer with pale colors so they never cover stars).
class ConstellationRenderer implements SkyLayerRenderer {
  ConstellationRenderer({required this.set, required this.settings});

  final ConstellationSet set;
  final ConstellationSettings settings;

  static const _lineColor = Color(0xFF7E9BB8); // Pale blue-gray
  static const _boundaryColor = Color(0xFF5A6B7E);
  static const _labelColor = Color(0xFFA8BDD4);

  /// Cache of laid-out TextPainters per constellation.
  ///
  /// Renderers are discarded every frame, so this is held statically
  /// (an instance field would re-run layout() every frame).
  /// On language switch, the old language's painters are dispose()d,
  /// keeping the cache capped at 88 entries.
  /// Styles are fixed, so no invalidation other than language is needed.
  static final Map<String, TextPainter> _labelCache = {};
  static NameLanguage? _cacheLanguage;

  static void _ensureCacheLanguage(NameLanguage language) {
    if (_cacheLanguage == language) return;
    for (final painter in _labelCache.values) {
      painter.dispose();
    }
    _labelCache.clear();
    _cacheLanguage = language;
  }

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final projection = context.projection;
    final state = context.state;
    final pxPerDeg = context.pxPerDeg;
    final breakPx = state.screenSize.longestSide * 0.5 + 64;

    if (settings.showBoundaries) {
      final paint = Paint()
        ..color = _boundaryColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      for (final boundary in set.boundaries) {
        drawSkyPolyline(canvas, paint, [
          for (final p in boundary) projection.project(p),
        ], breakDistancePx: breakPx);
      }
    }

    if (settings.showLines) {
      final paint = Paint()
        ..color = _lineColor.withValues(alpha: settings.lineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = settings.lineWidth
        ..strokeCap = StrokeCap.round;
      for (final constellation in set.constellations) {
        for (final line in constellation.lines) {
          drawSkyPolyline(canvas, paint, [
            for (final p in line) projection.project(p),
          ], breakDistancePx: breakPx);
        }
      }
    }

    if (settings.showNames && pxPerDeg > 4) {
      // At extremely wide views (all-sky display with 1° < 4px), labels are omitted for readability
      _ensureCacheLanguage(settings.language);
      final declutter = context.labelDeclutter; // Shared with celestial object name labels
      // Allow slightly off-screen positions so labels at screen edges are not cut off
      final screenRect = (Offset.zero & state.screenSize).inflate(48);

      for (final constellation in set.constellations) {
        final pos = projection.project(constellation.labelAnchor);
        if (pos == null || !screenRect.contains(pos)) continue;

        final painter = _labelCache.putIfAbsent(constellation.iau, () {
          return TextPainter(
            text: TextSpan(
              text: constellation.nameIn(settings.language),
              style: const TextStyle(
                color: _labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
        });

        final rect = Rect.fromCenter(
          center: pos,
          width: painter.width + 8,
          height: painter.height + 4,
        );
        if (!declutter.tryPlace(rect)) continue;
        painter.paint(
          canvas,
          pos - Offset(painter.width / 2, painter.height / 2),
        );
      }
    }
  }
}
