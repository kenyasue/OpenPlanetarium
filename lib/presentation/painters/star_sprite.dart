import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pixel size of the sprite used for star rendering
const int kStarSpriteSize = 64;

/// Creates the star sprite (a disk that is bright at the center and falls
/// off toward the edge).
///
/// Drawn in white because drawAtlas's BlendMode.modulate multiplies in each star's color.
Future<ui.Image> createStarSprite({int size = kStarSpriteSize}) {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final center = ui.Offset(size / 2, size / 2);
  final radius = size / 2;

  final paint = ui.Paint()
    ..shader = ui.Gradient.radial(
      center,
      radius,
      const [
        ui.Color(0xFFFFFFFF),
        ui.Color(0xFFFFFFFF),
        ui.Color(0x99FFFFFF),
        ui.Color(0x00FFFFFF),
      ],
      const [0.0, 0.25, 0.5, 1.0],
    );
  canvas.drawCircle(center, radius, paint);

  return recorder.endRecording().toImage(size, size);
}

/// Star sprite (created once at app startup)
final starSpriteProvider = FutureProvider<ui.Image>(
  (ref) => createStarSprite(),
);
