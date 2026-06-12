import 'dart:math' as math;
import 'dart:ui';

import '../models/horizontal_coord.dart';
import '../models/sky_point.dart';
import '../models/viewport_state.dart';
import 'astro_engine.dart';

/// Projection context for a single frame.
///
/// Precomputes trigonometric values from the ViewportState to speed up the
/// many project/unproject calls within a frame.
///
/// Projection scheme: stereographic projection (on the horizontal coordinate
/// sphere) with the view center (the RA/Dec point converted to Alt/Az) as the
/// tangent point. Its conformality keeps constellation shapes from distorting.
class ViewProjection {
  ViewProjection(this.state, {AstroEngine engine = const AstroEngine()})
    : _engine = engine {
    _lstDeg = engine.lstDeg(state.observationTime, state.location.longitudeDeg);
    final phi = state.location.latitudeDeg * _d2r;
    _sinPhi = math.sin(phi);
    _cosPhi = math.cos(phi);

    final center = engine.equatorialToHorizontal(
      state.center,
      state.location,
      state.observationTime,
    );
    _centerAlt = center.altDeg * _d2r;
    _centerAz = center.azDeg * _d2r;
    _sinAlt0 = math.sin(_centerAlt);
    _cosAlt0 = math.cos(_centerAlt);

    // Scale mapping the vertical field of view (FOV) to the screen height [px per tangent-plane unit].
    // In stereographic projection a central angle θ maps to radius R = 2 tan(θ/2),
    // so half the screen height = scale × 2 tan(fov/4).
    final fovRad = state.fovDeg * _d2r;
    _scale = state.screenSize.height / (4.0 * math.tan(fovRad / 4.0));
    _cx = state.screenSize.width / 2.0;
    _cy = state.screenSize.height / 2.0;
  }

  static const double _d2r = math.pi / 180.0;
  static const double _r2d = 180.0 / math.pi;

  final ViewportState state;
  final AstroEngine _engine;

  late final double _lstDeg;
  late final double _sinPhi;
  late final double _cosPhi;
  late final double _centerAlt;
  late final double _centerAz;
  late final double _sinAlt0;
  late final double _cosAlt0;
  late final double _scale;
  late final double _cx;
  late final double _cy;

  /// Local sidereal time [deg] (for debugging and label display)
  double get lstDeg => _lstDeg;

  /// Altitude of the view center [rad] (for analytic calculations such as horizon rendering)
  double get centerAltRad => _centerAlt;

  /// Scale from tangent-plane units to pixels
  double get scalePx => _scale;

  /// Screen coordinates of the projection center
  Offset get screenCenter => Offset(_cx, _cy);

  /// Equatorial coordinates → screen coordinates. Returns null on the far side of the view (more than 140° from center).
  Offset? project(SkyPoint radec) {
    // Equatorial → horizontal (inlined: same formulas as equatorialToHorizontal)
    final h = (_lstDeg - radec.raDeg) * _d2r;
    final dec = radec.decDeg * _d2r;
    final sinAlt =
        _sinPhi * math.sin(dec) + _cosPhi * math.cos(dec) * math.cos(h);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));
    final azSouth = math.atan2(
      math.sin(h),
      math.cos(h) * _sinPhi - math.tan(dec) * _cosPhi,
    );
    final az = azSouth + math.pi; // North-based, measured eastward
    return projectHorizontal(alt, az);
  }

  /// Horizontal coordinates → screen coordinates (altRad/azRad in radians; az is north-based, measured eastward).
  Offset? projectHorizontal(double altRad, double azRad) {
    final dAz = azRad - _centerAz;
    final sinAlt = math.sin(altRad);
    final cosAlt = math.cos(altRad);
    final cosDaz = math.cos(dAz);

    // Cosine of the angular distance from the center
    final cosC = _sinAlt0 * sinAlt + _cosAlt0 * cosAlt * cosDaz;
    if (cosC < -0.766) return null; // Beyond 140° from center is not rendered

    // Stereographic projection (Snyder "Map Projections" eqs. 21-2 to 21-4)
    final k = 2.0 / (1.0 + cosC);
    final x = k * cosAlt * math.sin(dAz);
    final y = k * (_cosAlt0 * sinAlt - _sinAlt0 * cosAlt * cosDaz);

    // On screen, up = increasing altitude (y is positive upward, so screen Y is inverted)
    return Offset(_cx + x * _scale, _cy - y * _scale);
  }

  /// Screen coordinates → equatorial coordinates (inverse projection to identify a celestial object from a tap position).
  SkyPoint unproject(Offset screen) {
    final x = (screen.dx - _cx) / _scale;
    final y = -(screen.dy - _cy) / _scale;
    final rho = math.sqrt(x * x + y * y);

    final double alt;
    final double az;
    if (rho < 1e-12) {
      alt = _centerAlt;
      az = _centerAz;
    } else {
      // Inverse stereographic projection (Snyder eqs. 20-14, 20-15, 21-15)
      final c = 2.0 * math.atan(rho / 2.0);
      final sinC = math.sin(c);
      final cosC = math.cos(c);
      alt = math.asin(
        (cosC * _sinAlt0 + y * sinC * _cosAlt0 / rho).clamp(-1.0, 1.0),
      );
      az =
          _centerAz +
          math.atan2(x * sinC, rho * _cosAlt0 * cosC - y * _sinAlt0 * sinC);
    }

    return _engine.horizontalToEquatorial(
      HorizontalCoord(
        altDeg: alt * _r2d,
        azDeg: SkyPoint.normalizeRa(az * _r2d),
      ),
      state.location,
      state.observationTime,
    );
  }
}
