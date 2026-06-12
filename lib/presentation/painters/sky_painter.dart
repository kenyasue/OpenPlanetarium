import 'package:flutter/rendering.dart';

import '../../domain/astro/projection.dart';
import '../../domain/models/viewport_state.dart';
import 'sky_layer_renderer.dart';

/// Parent painter for the sky canvas.
///
/// Draws the registered SkyLayerRenderers in list order
/// (background → horizon → grid → ...) in one pass. Stars and celestial
/// objects are not created as individual Widgets
/// (docs/development-guidelines.md performance rules).
class SkyPainter extends CustomPainter {
  SkyPainter({required this.state, required this.layers});

  final ViewportState state;
  final List<SkyLayerRenderer> layers;

  @override
  void paint(Canvas canvas, Size size) {
    // Build the projection from the actual canvas size, in case the provider's
    // screenSize and the real size diverge before layout is finalized
    final effectiveState = state.screenSize == size
        ? state
        : state.copyWith(screenSize: size);
    final context = SkyRenderContext(
      projection: ViewProjection(effectiveState),
      state: effectiveState,
    );
    for (final layer in layers) {
      layer.render(canvas, context);
    }
  }

  /// A new SkyPainter is created only when providers change (state or data
  /// arrival), so always repaint (comparing layer list contents is not worth
  /// the cost since diffing star lists etc. is hard).
  @override
  bool shouldRepaint(SkyPainter oldDelegate) => true;
}
