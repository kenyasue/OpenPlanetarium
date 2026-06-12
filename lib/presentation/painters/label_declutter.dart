import 'dart:ui';

/// Label overlap avoidance (greedy placement within a single frame).
///
/// Reserved rectangles are managed in a grid hash (per cell); a new label is
/// rejected if it intersects an existing one. Shared by constellation names
/// (M3) and celestial object names (M4).
/// A new instance is created for each frame.
class LabelDeclutter {
  LabelDeclutter({this.cellSize = 64.0});

  final double cellSize;
  final Map<(int, int), List<Rect>> _grid = {};

  /// Reserves [rect] and returns true if it does not overlap any existing label.
  bool tryPlace(Rect rect) {
    final cells = _cellsOf(rect);
    for (final cell in cells) {
      final existing = _grid[cell];
      if (existing == null) continue;
      for (final other in existing) {
        if (rect.overlaps(other)) return false;
      }
    }
    for (final cell in cells) {
      _grid.putIfAbsent(cell, () => []).add(rect);
    }
    return true;
  }

  List<(int, int)> _cellsOf(Rect rect) {
    final x0 = (rect.left / cellSize).floor();
    final x1 = (rect.right / cellSize).floor();
    final y0 = (rect.top / cellSize).floor();
    final y1 = (rect.bottom / cellSize).floor();
    return [
      for (var x = x0; x <= x1; x++)
        for (var y = y0; y <= y1; y++) (x, y),
    ];
  }
}
