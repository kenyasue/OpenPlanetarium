import 'dart:ui';

import '../../domain/models/sky_point.dart';
import 'sky_layer_renderer.dart';

/// Focus ring shown on the selected celestial object.
class SelectionRenderer implements SkyLayerRenderer {
  const SelectionRenderer({required this.target});

  final SkyPoint target;

  static const _ringColor = Color(0xFF53C8E8); // Accent: cyan

  @override
  void render(Canvas canvas, SkyRenderContext context) {
    final pos = context.projection.project(target);
    if (pos == null) return;

    final paint = Paint()
      ..color = _ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(pos, 13, paint);

    // Short ticks on four sides improve visibility
    const tickStart = 16.0;
    const tickEnd = 22.0;
    for (final dir in const [
      Offset(1, 0),
      Offset(-1, 0),
      Offset(0, 1),
      Offset(0, -1),
    ]) {
      canvas.drawLine(pos + dir * tickStart, pos + dir * tickEnd, paint);
    }
  }
}
