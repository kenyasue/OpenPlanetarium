import 'package:flutter_test/flutter_test.dart';
import 'package:open_planetarium/domain/appearance/star_appearance.dart';

void main() {
  group('StarAppearance.colorOf', () {
    test('Sirius (B-V≈0.0) is bluish-white (B component > R component)', () {
      final color = StarAppearance.colorOf(0.0);
      expect(color.b, greaterThan(color.r));
    });

    test('Betelgeuse (B-V≈1.85) is reddish (R component > B component)', () {
      final color = StarAppearance.colorOf(1.85);
      expect(color.r, greaterThan(color.b));
      expect(color.r, closeTo(1.0, 0.01)); // R saturates for cool stars
    });

    test('Rigel (B-V≈-0.03) is bluer than the Sun (B-V≈0.66)', () {
      final rigel = StarAppearance.colorOf(-0.03);
      final sun = StarAppearance.colorOf(0.66);
      expect(rigel.b / rigel.r, greaterThan(sun.b / sun.r));
    });

    test('missing B-V (null / NaN) yields fallback color', () {
      expect(StarAppearance.colorOf(null), StarAppearance.fallbackColor);
      expect(StarAppearance.colorOf(double.nan), StarAppearance.fallbackColor);
    });

    test('saturation 0 produces grayscale', () {
      final color = StarAppearance.colorOf(1.85, saturation: 0.0);
      expect(color.r, closeTo(color.g, 0.005));
      expect(color.g, closeTo(color.b, 0.005));
    });
  });

  group('StarAppearance.renderParams', () {
    const settings = AppearanceSettings();

    test('brighter stars have larger radii (magnitude monotonicity)', () {
      double radiusOf(double mag) =>
          StarAppearance.renderParams(mag, settings).radiusPx;
      expect(radiusOf(-1.5), greaterThan(radiusOf(0.0)));
      expect(radiusOf(0.0), greaterThan(radiusOf(3.0)));
      expect(radiusOf(3.0), greaterThan(radiusOf(6.0)));
    });

    test('radius is clamped to 0.5-16 px', () {
      expect(
        StarAppearance.renderParams(-27, settings).radiusPx,
        lessThanOrEqualTo(16.0),
      );
      expect(
        StarAppearance.renderParams(15, settings).radiusPx,
        greaterThanOrEqualTo(0.5),
      );
    });

    test('only stars brighter than magnitude 2 have glow', () {
      expect(
        StarAppearance.renderParams(0.0, settings).glowStrength,
        greaterThan(0),
      );
      expect(StarAppearance.renderParams(2.5, settings).glowStrength, 0);
    });

    test('faint stars fade but keep a 0.15 floor', () {
      final faint = StarAppearance.renderParams(6.5, settings);
      expect(faint.opacity, lessThan(1.0));
      expect(faint.opacity, greaterThanOrEqualTo(0.15));
      expect(StarAppearance.renderParams(3.0, settings).opacity, 1.0);
    });

    test('sizeScale setting is reflected in the radius', () {
      final normal = StarAppearance.renderParams(2.0, settings).radiusPx;
      final doubled = StarAppearance.renderParams(
        2.0,
        const AppearanceSettings(sizeScale: 2.0),
      ).radiusPx;
      expect(doubled, closeTo(normal * 2, 1e-9));
    });
  });

  group('fade tied to display limiting magnitude', () {
    test('raising the limiting magnitude moves the fade onset to fainter magnitudes', () {
      // Default (mag 6.5): a mag 6.0 star is fading
      const def = AppearanceSettings();
      expect(StarAppearance.renderParams(6.0, def).opacity, lessThan(1.0));

      // Display down to mag 12: fade starts at mag 10.5, so mag 6.0 is full brightness
      const deep = AppearanceSettings(userLimitingMagnitude: 12.0);
      expect(StarAppearance.renderParams(6.0, deep).opacity, 1.0);
      expect(StarAppearance.renderParams(11.5, deep).opacity, lessThan(1.0));
      expect(
        StarAppearance.renderParams(11.5, deep).opacity,
        greaterThanOrEqualTo(0.15),
      );
    });
  });
}
