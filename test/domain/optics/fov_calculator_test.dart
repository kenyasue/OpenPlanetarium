import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/models/equipment.dart';
import 'package:open_planetarium/domain/models/sky_point.dart';
import 'package:open_planetarium/domain/optics/fov_calculator.dart';

/// Verification based on the PRD F12 worked examples (KPI: error within 1%).
void main() {
  const rasa8 = Telescope(
    id: 't1',
    name: 'RASA 8',
    type: TelescopeType.rasa,
    apertureMm: 203,
    focalLengthMm: 400,
  );
  const refractor1000 = Telescope(
    id: 't2',
    name: '1000mm Refractor',
    type: TelescopeType.refractor,
    apertureMm: 200,
    focalLengthMm: 1000,
  );
  const asi294 = CameraDevice(
    id: 'c1',
    name: 'ASI294MC Pro',
    sensorWidthMm: 19.1,
    sensorHeightMm: 13.0,
    pixelSizeUm: 4.63,
    resolutionX: 4144,
    resolutionY: 2822,
  );
  const plossl25 = Eyepiece(
    id: 'e1',
    name: '25mm Plössl',
    focalLengthMm: 25,
    apparentFovDeg: 50,
  );
  const barlow2x = OpticalModifier(
    id: 'm1',
    name: '2x Barlow',
    kind: ModifierKind.barlow,
    factor: 2.0,
  );
  const reducer067 = OpticalModifier(
    id: 'm2',
    name: '0.67x Reducer',
    kind: ModifierKind.reducer,
    factor: 0.67,
  );

  group('FovCalculator.cameraFov (KPI verification: error within 1%)', () {
    test('RASA 8 + ASI294MC Pro: FOV 2.735°×1.862°, 2.388"/px', () {
      final result = FovCalculator.cameraFov(rasa8, asi294, null);
      // Theoretical: 2*atan(19.1/800) = 2.7352°, 2*atan(13.0/800) = 1.8619°
      expect(result.widthDeg, closeTo(2.7352, 2.7352 * 0.01));
      expect(result.heightDeg, closeTo(1.8619, 1.8619 * 0.01));
      // 206.265 * 4.63 / 400 = 2.3875 arcsec/px
      expect(result.pixelScaleArcsec, closeTo(2.3875, 2.3875 * 0.01));
      expect(result.fRatio, closeTo(400 / 203, 0.01));
    });

    test('2x Barlow doubles effective focal length and roughly halves the FOV', () {
      final result = FovCalculator.cameraFov(rasa8, asi294, barlow2x);
      expect(result.effectiveFocalLengthMm, 800);
      expect(result.widthDeg, closeTo(2 * 0.6839, 0.014)); // 2*atan(19.1/1600)
      expect(result.pixelScaleArcsec, closeTo(2.3875 / 2, 0.012));
    });

    test('0.67x reducer shortens effective focal length and widens the FOV', () {
      final result = FovCalculator.cameraFov(rasa8, asi294, reducer067);
      expect(result.effectiveFocalLengthMm, closeTo(268, 1e-9));
      final without = FovCalculator.cameraFov(rasa8, asi294, null);
      expect(result.widthDeg, greaterThan(without.widthDeg));
    });
  });

  group('FovCalculator.eyepieceFov', () {
    test('1000mm + 25mm/AFOV 50°: 40x, true FOV 1.25°, exit pupil 5mm', () {
      final result = FovCalculator.eyepieceFov(refractor1000, plossl25, null);
      expect(result.magnification, closeTo(40, 40 * 0.01));
      expect(result.trueFovDeg, closeTo(1.25, 1.25 * 0.01));
      expect(result.exitPupilMm, closeTo(5.0, 5.0 * 0.01));
    });

    test('2x Barlow doubles magnification and halves true FOV', () {
      final result = FovCalculator.eyepieceFov(
        refractor1000,
        plossl25,
        barlow2x,
      );
      expect(result.magnification, closeTo(80, 0.01));
      expect(result.trueFovDeg, closeTo(0.625, 0.01));
    });
  });

  group('FovCalculator.checkFit', () {
    test('M31 (3.0°×1.0°) overflows a 2.74°×1.86° frame', () {
      expect(
        FovCalculator.checkFit(
          frameWidthDeg: 2.7352,
          frameHeightDeg: 1.8619,
          targetMajorDeg: 3.0,
          targetMinorDeg: 1.0,
        ),
        FitResult.overflow,
      );
    });

    test('elongated object fits when it would fit after rotation (best case with free rotation)', () {
      // A 0.4°×1.4° object fits a 2.0°×0.5° frame "if rotated"
      expect(
        FovCalculator.checkFit(
          frameWidthDeg: 2.0,
          frameHeightDeg: 0.5,
          targetMajorDeg: 1.4,
          targetMinorDeg: 0.4,
        ),
        FitResult.fits,
      );
    });

    test('near-square object is judged by the short side regardless of long-side margin', () {
      // 1.4°×1.4° object vs 2.0°×1.5°: short-side ratio is 1.4/1.5≈0.93 in either orientation
      expect(
        FovCalculator.checkFit(
          frameWidthDeg: 2.0,
          frameHeightDeg: 1.5,
          targetMajorDeg: 1.4,
          targetMinorDeg: 1.4,
        ),
        FitResult.tight,
      );
    });

    test('small object is fits, borderline is tight', () {
      expect(
        FovCalculator.checkFit(
          frameWidthDeg: 2.0,
          frameHeightDeg: 1.5,
          targetMajorDeg: 1.0,
          targetMinorDeg: 0.5,
        ),
        FitResult.fits,
      );
      expect(
        FovCalculator.checkFit(
          frameWidthDeg: 2.0,
          frameHeightDeg: 1.5,
          targetMajorDeg: 1.9,
          targetMinorDeg: 0.5,
        ),
        FitResult.tight,
      );
    });
  });

  group('FovCalculator.mosaicPlan', () {
    test('2×2 with 20% overlap: panel spacing and serpentine order', () {
      final center = SkyPoint(180, 0); // on the equator (no cos correction)
      final plan = FovCalculator.mosaicPlan(
        center: center,
        frameWidthDeg: 2.0,
        frameHeightDeg: 1.5,
        rows: 2,
        cols: 2,
        overlapRatio: 0.2,
      );
      expect(plan.panels, hasLength(4));

      // Spacing = 2.0×0.8 = 1.6° / 1.5×0.8 = 1.2°
      final p00 = plan.panels.firstWhere((p) => p.row == 0 && p.col == 0);
      final p01 = plan.panels.firstWhere((p) => p.row == 0 && p.col == 1);
      final p10 = plan.panels.firstWhere((p) => p.row == 1 && p.col == 0);
      expect((p01.center.raDeg - p00.center.raDeg).abs(), closeTo(1.6, 1e-9));
      expect((p00.center.decDeg - p10.center.decDeg).abs(), closeTo(1.2, 1e-9));

      // Serpentine order: row0 left-to-right, row1 right-to-left
      expect(p00.order, 0);
      expect(p01.order, 1);
      final p11 = plan.panels.firstWhere((p) => p.row == 1 && p.col == 1);
      expect(p11.order, 2);
      expect(p10.order, 3);
    });

    test('at high Dec the RA spacing widens by cos(dec)', () {
      final plan = FovCalculator.mosaicPlan(
        center: SkyPoint(0, 60), // cos(60°)=0.5
        frameWidthDeg: 2.0,
        frameHeightDeg: 1.5,
        rows: 1,
        cols: 2,
        overlapRatio: 0.0,
      );
      final ra0 = plan.panels[0].center.raDeg;
      final ra1 = plan.panels[1].center.raDeg;
      var diff = (ra1 - ra0).abs();
      if (diff > 180) diff = 360 - diff;
      expect(diff, closeTo(4.0, 0.01)); // 2.0 / cos(60°) = 4.0
    });

    test('all panel centers are placed symmetrically around the mosaic center', () {
      final center = SkyPoint(100, 20);
      final plan = FovCalculator.mosaicPlan(
        center: center,
        frameWidthDeg: 1.0,
        frameHeightDeg: 1.0,
        rows: 3,
        cols: 3,
        overlapRatio: 0.15,
      );
      final meanDec =
          plan.panels.map((p) => p.center.decDeg).reduce((a, b) => a + b) / 9;
      expect(meanDec, closeTo(20, 1e-9));
      // Center panel (row1,col1) coincides with the mosaic center
      final mid = plan.panels.firstWhere((p) => p.row == 1 && p.col == 1);
      expect(mid.center.angularDistanceTo(center), lessThan(1e-9));
    });
  });
}
