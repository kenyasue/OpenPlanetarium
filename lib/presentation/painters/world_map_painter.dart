import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/models/geo_location.dart';
import '../../domain/models/land_ring.dart';
import '../../domain/models/world_city.dart';
import '../../domain/models/world_map_projection.dart';

/// Builds the land silhouette as a single Path in normalized map
/// coordinates (x,y ∈ [0,1]).
///
/// Built once per catalog load and reused across repaints: rebuilding
/// ~5,000 path vertices every frame is wasteful on mobile.
Path buildLandPath(List<LandRing> landRings) {
  final path = Path();
  for (final ring in landRings) {
    for (var i = 0; i < ring.lonDeg.length; i++) {
      final x = lonToMapX(ring.lonDeg[i]);
      final y = latToMapY(ring.latDeg[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
  }
  return path;
}

/// Draws the world map for the observing-location picker: ocean background,
/// land silhouettes, city dots (capitals highlighted), and the current
/// observing-location marker.
///
/// Painted in the map's own coordinate space (the InteractiveViewer child),
/// so [viewScale] is used to keep dot/stroke sizes visually constant while
/// zoomed.
class WorldMapPainter extends CustomPainter {
  WorldMapPainter({
    required this.landPath,
    required this.cities,
    this.marker,
    this.viewScale = 1.0,
  });

  /// Land silhouette in normalized [0,1]×[0,1] coordinates ([buildLandPath])
  final Path landPath;

  final List<WorldCity> cities;

  /// Current observing location, or null while unresolved.
  ///
  /// GeoLocation equality compares only lat/lon (the name is irrelevant to
  /// rendering), which is exactly what [shouldRepaint] needs.
  final GeoLocation? marker;

  /// Current InteractiveViewer zoom factor (>= 1)
  final double viewScale;

  static const _oceanColor = Color(0xFF0D1B2A);
  static const _landColor = Color(0xFF2E4057);
  static const _cityColor = Color(0xFF9FB8D0);
  static const _capitalColor = Color(0xFFF4D35E);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _oceanColor);

    // Fill-only path: scaling the canvas from normalized coordinates does
    // not distort anything visible (no strokes involved)
    canvas.save();
    canvas.scale(size.width, size.height);
    canvas.drawPath(landPath, Paint()..color = _landColor);
    canvas.restore();

    // One draw call per dot class (round point mode) instead of ~1,250
    // drawCircle calls. Sizes divided by the view scale stay visually
    // constant while zoomed.
    final cityPoints = <double>[];
    final capitalPoints = <double>[];
    for (final city in cities) {
      final target = city.isCapital ? capitalPoints : cityPoints;
      target
        ..add(lonToMapX(city.longitudeDeg) * size.width)
        ..add(latToMapY(city.latitudeDeg) * size.height);
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      Float32List.fromList(cityPoints),
      Paint()
        ..color = _cityColor
        ..strokeWidth = 2.4 / viewScale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRawPoints(
      ui.PointMode.points,
      Float32List.fromList(capitalPoints),
      Paint()
        ..color = _capitalColor
        ..strokeWidth = 4.0 / viewScale
        ..strokeCap = StrokeCap.round,
    );

    final marker = this.marker;
    if (marker != null) {
      final p = Offset(
        lonToMapX(marker.longitudeDeg) * size.width,
        latToMapY(marker.latitudeDeg) * size.height,
      );
      final markerPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 / viewScale;
      final r = 5.0 / viewScale;
      canvas.drawCircle(p, r, markerPaint);
      canvas.drawLine(
        p - Offset(0, r * 1.8),
        p + Offset(0, r * 1.8),
        markerPaint,
      );
      canvas.drawLine(
        p - Offset(r * 1.8, 0),
        p + Offset(r * 1.8, 0),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WorldMapPainter oldDelegate) =>
      oldDelegate.landPath != landPath ||
      oldDelegate.cities != cities ||
      oldDelegate.marker != marker ||
      oldDelegate.viewScale != viewScale;
}
