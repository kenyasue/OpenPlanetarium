import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/presentation/painters/label_declutter.dart';

void main() {
  group('LabelDeclutter', () {
    test('non-overlapping labels can be placed', () {
      final declutter = LabelDeclutter();
      expect(declutter.tryPlace(const Rect.fromLTWH(0, 0, 50, 20)), isTrue);
      expect(declutter.tryPlace(const Rect.fromLTWH(100, 0, 50, 20)), isTrue);
      expect(declutter.tryPlace(const Rect.fromLTWH(0, 50, 50, 20)), isTrue);
    });

    test('overlapping labels are rejected', () {
      final declutter = LabelDeclutter();
      expect(declutter.tryPlace(const Rect.fromLTWH(0, 0, 50, 20)), isTrue);
      expect(declutter.tryPlace(const Rect.fromLTWH(25, 10, 50, 20)), isFalse);
    });

    test(
      'intersections between rects spanning cell boundaries are also detected',
      () {
        final declutter = LabelDeclutter(cellSize: 64);
        // Rect spanning cells (0,0) to (1,0)
        expect(declutter.tryPlace(const Rect.fromLTWH(50, 10, 40, 20)), isTrue);
        // Starts in the neighboring cell but intersects the previous rect
        expect(
          declutter.tryPlace(const Rect.fromLTWH(70, 15, 40, 20)),
          isFalse,
        );
      },
    );

    test('rejected labels do not occupy space', () {
      final declutter = LabelDeclutter();
      expect(declutter.tryPlace(const Rect.fromLTWH(0, 0, 50, 20)), isTrue);
      expect(declutter.tryPlace(const Rect.fromLTWH(25, 0, 50, 20)), isFalse);
      // Overlaps the rejected (25,0) rect but not the reserved (0,0) one, so OK
      expect(declutter.tryPlace(const Rect.fromLTWH(55, 0, 30, 20)), isTrue);
    });
  });
}
