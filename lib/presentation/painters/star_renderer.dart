import 'dart:ui' as ui;

import '../../domain/appearance/star_appearance.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/star.dart';
import 'sky_layer_renderer.dart';
import 'star_sprite.dart';

/// Batch rendering of stars (F1/F5).
///
/// Uses only sprite batch drawing via drawAtlas; no per-star Widget creation
/// or drawCircle calls (docs/development-guidelines.md performance rules).
/// Glow is rendered for bright stars (mag<2) by overlaying the same sprite
/// at a larger scale with low alpha.
class StarRenderer implements SkyLayerRenderer {
  StarRenderer({
    required this.stars,
    required this.settings,
    required this.sprite,
  });

  final List<Star> stars;
  final AppearanceSettings settings;

  /// Null until generation completes (right after startup) → skip rendering meanwhile
  final ui.Image? sprite;

  @override
  void render(ui.Canvas canvas, SkyRenderContext context) {
    final image = sprite;
    if (image == null || stars.isEmpty) return;

    final projection = context.projection;
    final bounds = (ui.Offset.zero & context.state.screenSize).inflate(8);
    const anchor = kStarSpriteSize / 2.0;
    final spriteRect = ui.Rect.fromLTWH(
      0,
      0,
      kStarSpriteSize.toDouble(),
      kStarSpriteSize.toDouble(),
    );

    final transforms = <ui.RSTransform>[];
    final rects = <ui.Rect>[];
    final colors = <ui.Color>[];

    final glowTransforms = <ui.RSTransform>[];
    final glowRects = <ui.Rect>[];
    final glowColors = <ui.Color>[];

    for (final star in stars) {
      final pos = projection.project(SkyPoint(star.raDeg, star.decDeg));
      if (pos == null || !bounds.contains(pos)) continue;

      final params = StarAppearance.renderParams(star.magnitude, settings);
      final color = StarAppearance.colorOf(
        star.colorIndexBV,
        saturation: settings.saturation,
      );

      final scale = params.radiusPx * 2 / kStarSpriteSize;
      transforms.add(
        ui.RSTransform.fromComponents(
          rotation: 0,
          scale: scale,
          anchorX: anchor,
          anchorY: anchor,
          translateX: pos.dx,
          translateY: pos.dy,
        ),
      );
      rects.add(spriteRect);
      colors.add(color.withValues(alpha: params.opacity));

      if (params.glowStrength > 0) {
        final glowScale =
            params.radiusPx * (3.0 + params.glowStrength) * 2 / kStarSpriteSize;
        glowTransforms.add(
          ui.RSTransform.fromComponents(
            rotation: 0,
            scale: glowScale,
            anchorX: anchor,
            anchorY: anchor,
            translateX: pos.dx,
            translateY: pos.dy,
          ),
        );
        glowRects.add(spriteRect);
        glowColors.add(
          color.withValues(
            alpha: (0.10 * params.glowStrength).clamp(0.0, 0.35),
          ),
        );
      }
    }

    final paint = ui.Paint()..filterQuality = ui.FilterQuality.low;
    // Draw glow first, then overlay the star bodies on top
    if (glowTransforms.isNotEmpty) {
      canvas.drawAtlas(
        image,
        glowTransforms,
        glowRects,
        glowColors,
        ui.BlendMode.modulate,
        null,
        paint,
      );
    }
    canvas.drawAtlas(
      image,
      transforms,
      rects,
      colors,
      ui.BlendMode.modulate,
      null,
      paint,
    );
  }
}
