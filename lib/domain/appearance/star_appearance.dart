import 'dart:math' as math;
import 'dart:ui';

/// User settings for star appearance (F5).
class AppearanceSettings {
  const AppearanceSettings({
    this.sizeScale = 1.0,
    this.glowIntensity = 1.0,
    this.saturation = 1.0,
    this.userLimitingMagnitude = 6.5,
    this.showMilkyWay = true,
  });

  /// Allowed range for the display limiting magnitude
  static const double minLimitingMagnitude = 1.0;
  static const double maxLimitingMagnitude = 20.0;

  /// Star size scale factor
  final double sizeScale;

  /// Glow intensity scale factor
  final double glowIntensity;

  /// Star color saturation (0=monochrome, 1=scientific, >1=enhanced)
  final double saturation;

  /// User-set display limiting magnitude ("show stars down to magnitude N", 1.0-20.0)
  final double userLimitingMagnitude;

  /// Show the Milky Way (F1)
  final bool showMilkyWay;

  AppearanceSettings copyWith({
    double? sizeScale,
    double? glowIntensity,
    double? saturation,
    double? userLimitingMagnitude,
    bool? showMilkyWay,
  }) {
    return AppearanceSettings(
      sizeScale: sizeScale ?? this.sizeScale,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      saturation: saturation ?? this.saturation,
      userLimitingMagnitude:
          userLimitingMagnitude ?? this.userLimitingMagnitude,
      showMilkyWay: showMilkyWay ?? this.showMilkyWay,
    );
  }
}

/// Render parameters for a single star
class StarRenderParams {
  const StarRenderParams({
    required this.radiusPx,
    required this.glowStrength,
    required this.opacity,
  });

  final double radiusPx;

  /// 0 = no glow. >0 overlays a glow sprite
  final double glowStrength;

  final double opacity;
}

/// Star color/brightness computation (pure computation, functional design A3/A4).
class StarAppearance {
  const StarAppearance._();

  /// Fallback color when the B-V color index is missing (slightly warm white)
  static const fallbackColor = Color(0xFFFFF8F0);

  /// B-V color index → display color.
  ///
  /// 1. B-V → effective temperature [K] via the Ballesteros (2012) approximation
  ///    T = 4600 (1/(0.92BV+1.7) + 1/(0.92BV+0.62))
  /// 2. Temperature → RGB via Tanner Helland's black-body approximation polynomials
  static Color colorOf(double? bv, {double saturation = 1.0}) {
    if (bv == null || bv.isNaN) return fallbackColor;
    final clampedBv = bv.clamp(-0.4, 2.0);
    final temp =
        4600.0 *
        (1.0 / (0.92 * clampedBv + 1.7) + 1.0 / (0.92 * clampedBv + 0.62));
    final rgb = _blackBodyRgb(temp);
    return _applySaturation(rgb, saturation);
  }

  /// Apparent magnitude → render size, glow, and opacity (based on Pogson's relation, A4).
  ///
  /// The faint-star fade onset tracks the display limiting magnitude (raising the
  /// limit reveals stars near it, fading smoothly close to the limit).
  static StarRenderParams renderParams(
    double magnitude,
    AppearanceSettings settings, {
    double baseRadiusPx = 4.0,
    double faintFadeRange = 1.8,
  }) {
    final faintFadeStart = math.max(5.0, settings.userLimitingMagnitude - 1.5);
    // Brightness ratio relative to magnitude 0 (1 mag difference = factor 2.512, Pogson's ratio)
    final relative = math.pow(10.0, -0.4 * magnitude).toDouble();
    final radius =
        (baseRadiusPx * math.pow(relative, 0.35) * settings.sizeScale)
            .clamp(0.5, 16.0)
            .toDouble();
    final glow = magnitude < 2.0
        ? settings.glowIntensity * (2.0 - magnitude)
        : 0.0;
    final opacity = magnitude > faintFadeStart
        ? (1.0 - (magnitude - faintFadeStart) / faintFadeRange)
              .clamp(0.15, 1.0)
              .toDouble()
        : 1.0;
    return StarRenderParams(
      radiusPx: radius,
      glowStrength: glow,
      opacity: opacity,
    );
  }

  /// Approximate RGB of black-body radiation (Tanner Helland approximation, input clamped to 1,000-40,000K)
  static Color _blackBodyRgb(double tempK) {
    final t = tempK.clamp(1000.0, 40000.0) / 100.0;

    final double r;
    if (t <= 66) {
      r = 255;
    } else {
      r = 329.698727446 * math.pow(t - 60, -0.1332047592).toDouble();
    }

    final double g;
    if (t <= 66) {
      g = 99.4708025861 * math.log(t) - 161.1195681661;
    } else {
      g = 288.1221695283 * math.pow(t - 60, -0.0755148492).toDouble();
    }

    final double b;
    if (t >= 66) {
      b = 255;
    } else if (t <= 19) {
      b = 0;
    } else {
      b = 138.5177312231 * math.log(t - 10) - 305.0447927307;
    }

    return Color.fromARGB(
      255,
      r.clamp(0, 255).round(),
      g.clamp(0, 255).round(),
      b.clamp(0, 255).round(),
    );
  }

  /// Saturation adjustment: linear interpolation toward gray preserving luma (>1 enhances)
  static Color _applySaturation(Color color, double saturation) {
    if (saturation == 1.0) return color;
    // ITU-R BT.601 luma coefficients
    final luma = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    double mix(double channel) =>
        (luma + (channel - luma) * saturation).clamp(0.0, 1.0);
    return Color.from(
      alpha: color.a,
      red: mix(color.r),
      green: mix(color.g),
      blue: mix(color.b),
    );
  }
}
