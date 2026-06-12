import 'dart:math' as math;

import '../models/equipment.dart';
import '../models/sky_point.dart';

/// Minimum value to clamp cos(dec) near the poles (declination ±87° or more)
/// so the tangent-plane RA spacing correction does not diverge (cos(87.1°) ≈ 0.052).
const double kMinCosDec = 0.05;

/// Camera field of view (FOV) calculation result (F12).
class CameraFovResult {
  const CameraFovResult({
    required this.widthDeg,
    required this.heightDeg,
    required this.diagonalDeg,
    required this.pixelScaleArcsec,
    required this.effectiveFocalLengthMm,
    required this.fRatio,
  });

  final double widthDeg;
  final double heightDeg;
  final double diagonalDeg;

  /// Pixel scale [arcsec/px]
  final double pixelScaleArcsec;

  final double effectiveFocalLengthMm;
  final double fRatio;
}

/// Eyepiece field of view (FOV) calculation result.
class EyepieceFovResult {
  const EyepieceFovResult({
    required this.magnification,
    required this.trueFovDeg,
    required this.exitPupilMm,
    required this.effectiveFocalLengthMm,
  });

  final double magnification;
  final double trueFovDeg;
  final double exitPupilMm;
  final double effectiveFocalLengthMm;
}

/// Fit assessment (docs/glossary.md FitResult).
enum FitResult {
  /// Fits within 90% on both axes
  fits,

  /// 90-100% (barely fits)
  tight,

  /// Overflows (mosaic recommended)
  overflow,
}

/// One panel of a mosaic imaging plan.
class MosaicPanel {
  const MosaicPanel({
    required this.row,
    required this.col,
    required this.order,
    required this.center,
  });

  final int row;
  final int col;

  /// Imaging order (serpentine/boustrophedon order, 0-based)
  final int order;

  final SkyPoint center;
}

class MosaicPlan {
  const MosaicPlan({
    required this.rows,
    required this.cols,
    required this.overlapRatio,
    required this.panels,
  });

  final int rows;
  final int cols;
  final double overlapRatio;
  final List<MosaicPanel> panels;
}

/// Optical calculations for equipment (pure computation, functional design A5. KPI: within 1% of theoretical values).
class FovCalculator {
  const FovCalculator._();

  static const _d2r = math.pi / 180.0;
  static const _r2d = 180.0 / math.pi;

  /// Effective focal length = telescope focal length × Barlow/reducer factor
  static double effectiveFocalLengthMm(
    Telescope telescope,
    OpticalModifier? modifier,
  ) => telescope.focalLengthMm * (modifier?.factor ?? 1.0);

  /// Camera FOV (exact atan formula on sensor dimensions; more accurate than the 57.3 approximation)
  static CameraFovResult cameraFov(
    Telescope telescope,
    CameraDevice camera,
    OpticalModifier? modifier,
  ) {
    final fl = effectiveFocalLengthMm(telescope, modifier);
    double fov(double sensorMm) =>
        2.0 * math.atan(sensorMm / (2.0 * fl)) * _r2d;
    final diagonalMm = math.sqrt(
      camera.sensorWidthMm * camera.sensorWidthMm +
          camera.sensorHeightMm * camera.sensorHeightMm,
    );
    return CameraFovResult(
      widthDeg: fov(camera.sensorWidthMm),
      heightDeg: fov(camera.sensorHeightMm),
      diagonalDeg: fov(diagonalMm),
      // Pixel scale = 206.265 × pixel size [µm] / effective focal length [mm]
      pixelScaleArcsec: 206.265 * camera.pixelSizeUm / fl,
      effectiveFocalLengthMm: fl,
      fRatio: fl / telescope.apertureMm,
    );
  }

  /// Eyepiece FOV (magnification, true FOV, exit pupil diameter)
  static EyepieceFovResult eyepieceFov(
    Telescope telescope,
    Eyepiece eyepiece,
    OpticalModifier? modifier,
  ) {
    final fl = effectiveFocalLengthMm(telescope, modifier);
    final magnification = fl / eyepiece.focalLengthMm;
    return EyepieceFovResult(
      magnification: magnification,
      trueFovDeg: eyepiece.apparentFovDeg / magnification,
      exitPupilMm: telescope.apertureMm / magnification,
      effectiveFocalLengthMm: fl,
    );
  }

  /// Determines whether the target celestial object fits in the frame.
  ///
  /// Compares the object's major/minor axes against the frame's long/short
  /// sides (rotation is free, so the best axis-aligned case is used).
  static FitResult checkFit({
    required double frameWidthDeg,
    required double frameHeightDeg,
    required double targetMajorDeg,
    required double targetMinorDeg,
  }) {
    // Best case with free rotation: of the two axis pairings
    // (major↔long side / major↔short side), use the one that fits better
    final ratioAligned = math.max(
      targetMajorDeg / frameWidthDeg,
      targetMinorDeg / frameHeightDeg,
    );
    final ratioRotated = math.max(
      targetMajorDeg / frameHeightDeg,
      targetMinorDeg / frameWidthDeg,
    );
    final worst = math.min(ratioAligned, ratioRotated);

    if (worst <= 0.9) return FitResult.fits;
    if (worst <= 1.0) return FitResult.tight;
    return FitResult.overflow;
  }

  /// Mosaic imaging plan (functional design A5).
  ///
  /// Panel spacing = frame dimension × (1 - overlap ratio).
  /// Spacing along RA is corrected by cos(dec); imaging order is serpentine (boustrophedon).
  /// Frame rotation is ignored for simplicity (0° rotation grid).
  static MosaicPlan mosaicPlan({
    required SkyPoint center,
    required double frameWidthDeg,
    required double frameHeightDeg,
    required int rows,
    required int cols,
    required double overlapRatio,
  }) {
    final stepX = frameWidthDeg * (1.0 - overlapRatio);
    final stepY = frameHeightDeg * (1.0 - overlapRatio);
    final cosDec = math.max(kMinCosDec, math.cos(center.decDeg * _d2r));

    final panels = <MosaicPanel>[];
    var order = 0;
    for (var row = 0; row < rows; row++) {
      // Serpentine order: even rows left→right, odd rows right→left
      final colOrder = row.isEven
          ? List<int>.generate(cols, (i) => i)
          : List<int>.generate(cols, (i) => cols - 1 - i);
      for (final col in colOrder) {
        final dx = (col - (cols - 1) / 2.0) * stepX;
        final dy = ((rows - 1) / 2.0 - row) * stepY;
        panels.add(
          MosaicPanel(
            row: row,
            col: col,
            order: order++,
            center: SkyPoint(center.raDeg + dx / cosDec, center.decDeg + dy),
          ),
        );
      }
    }
    return MosaicPlan(
      rows: rows,
      cols: cols,
      overlapRatio: overlapRatio,
      panels: panels,
    );
  }
}
