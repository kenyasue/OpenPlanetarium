import 'dart:ui';

import 'sky_layer_renderer.dart';

/// Night sky background gradient.
///
/// M1 uses a deep navy vertical gradient. Airglow and light pollution glow
/// following the horizon shape will be added in M8 (design polish).
class BackgroundRenderer implements SkyLayerRenderer {
  const BackgroundRenderer();

  static const _topColor = Color(0xFF04060E);
  static const _bottomColor = Color(0xFF0B1226);

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final rect = Offset.zero & context.state.screenSize;
    final paint = Paint()
      ..shader = Gradient.linear(rect.topCenter, rect.bottomCenter, [
        _topColor,
        _bottomColor,
      ]);
    canvas.drawRect(rect, paint);
  }
}
