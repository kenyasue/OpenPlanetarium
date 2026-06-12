import 'dart:math' as math;

import '../models/geo_location.dart';
import '../models/minor_body.dart';
import '../models/sky_point.dart';
import '../models/solar_system.dart';
import 'astro_engine.dart';

/// Ephemeris engine for the Sun, Moon, and planets (pure computation).
///
/// Accuracy policy (for visual display, docs/functional-design.md):
/// - Sun: low-accuracy formulas from Meeus ch. 25 (±0.01°)
/// - Moon: major periodic terms from Meeus ch. 47 only (about ±0.1°)
/// - Planets: Standish (JPL) approximate Keplerian elements 1800-2050 (±a few arcmin)
/// - Aberration, nutation, and geocentric parallax omitted (lunar parallax only embedded in the distance calculation)
class EphemerisEngine {
  const EphemerisEngine({this.astroEngine = const AstroEngine()});

  final AstroEngine astroEngine;

  static const _d2r = math.pi / 180.0;
  static const _r2d = 180.0 / math.pi;

  /// Mean synodic month [days] (Meeus ch. 49)
  static const synodicMonthDays = 29.530588853;

  /// Returns the apparent position at the given time (geocentric, mean equinox of date, not J2000).
  SkyPoint position(SolarBodyId body, DateTime utc) {
    final t = _centuriesFromJ2000(utc);
    switch (body) {
      case SolarBodyId.sun:
        final (lambda, _) = _sunEclipticLongitude(t);
        return _eclipticToEquatorial(lambda, 0.0, t);
      case SolarBodyId.moon:
        final moon = _moonEcliptic(t);
        return _eclipticToEquatorial(moon.$1, moon.$2, t);
      default:
        return _planetPosition(body, t);
    }
  }

  /// Lunar distance [km] (for apparent diameter calculation)
  double moonDistanceKm(DateTime utc) =>
      _moonEcliptic(_centuriesFromJ2000(utc)).$3;

  /// Geocentric apparent position and distances of a minor body (asteroid/comet) (F7 extension).
  ///
  /// Propagation via the Keplerian two-body problem. Assumes elements in the same
  /// J2000 ecliptic frame as the planets, with mean motion
  /// n = 0.9856076686 / a^1.5 [deg/day] (from the Gaussian gravitational constant).
  /// Returns: geocentric apparent position (RA/Dec), heliocentric distance r [au], geocentric distance Δ [au]
  ({SkyPoint position, double rAu, double deltaAu}) minorBodyGeocentric(
    OrbitalElements el,
    DateTime utc,
  ) {
    final t = _centuriesFromJ2000(utc);
    final jd = astroEngine.julianDate(utc);
    final n = 0.9856076686 / math.pow(el.aAu, 1.5);
    final m = _normalizeDeg(el.meanAnomalyDeg + n * (jd - el.epochJd));

    final body = _orbitalXyz(
      el.aAu,
      el.e,
      el.iDeg * _d2r,
      (el.argPeriDeg) * _d2r,
      el.nodeDeg * _d2r,
      m * _d2r,
    );
    final earth = _heliocentric(_earthElements, t);

    final gx = body.$1 - earth.$1;
    final gy = body.$2 - earth.$2;
    final gz = body.$3 - earth.$3;
    final lambda = math.atan2(gy, gx) * _r2d;
    final beta = math.atan2(gz, math.sqrt(gx * gx + gy * gy)) * _r2d;
    return (
      position: _eclipticToEquatorial(_normalizeDeg(lambda), beta, t),
      rAu: math.sqrt(body.$1 * body.$1 + body.$2 * body.$2 + body.$3 * body.$3),
      deltaAu: math.sqrt(gx * gx + gy * gy + gz * gz),
    );
  }

  /// Moon phase (age and illuminated fraction)
  MoonPhase moonPhase(DateTime utc) {
    final t = _centuriesFromJ2000(utc);
    final (sunLambda, _) = _sunEclipticLongitude(t);
    final moon = _moonEcliptic(t);
    final elongation = _normalizeDeg(moon.$1 - sunLambda);

    // Illuminated fraction k = (1 - cos ψ) / 2 (approximating phase angle ≈ 180° - elongation)
    final k = (1 - math.cos(elongation * _d2r)) / 2;
    final age = elongation / 360.0 * synodicMonthDays;
    return MoonPhase(
      ageDays: age,
      illuminatedFraction: k.clamp(0.0, 1.0),
      waxing: elongation < 180.0,
    );
  }

  /// Rise/set and transit times (local date range of the given day, 10-minute sampling + linear interpolation).
  ///
  /// [radec] is treated as fixed within the day (intended for stars, DSOs, and planets.
  /// The Moon moves fast, causing errors of tens of minutes — a display-purpose approximation).
  RiseSetTimes riseSetTimes(SkyPoint radec, GeoLocation loc, DateTime local) {
    const h0 = -0.5667; // Rise/set altitude including refraction (Meeus ch. 15)
    final dayStart = DateTime(local.year, local.month, local.day);

    const stepMinutes = 10;
    const samples = 24 * 60 ~/ stepMinutes + 1;
    final alts = List<double>.generate(samples, (i) {
      final time = dayStart.add(Duration(minutes: i * stepMinutes));
      return astroEngine
          .equatorialToHorizontal(radec, loc, time.toUtc())
          .altDeg;
    });

    var maxAlt = -90.0, minAlt = 90.0, maxIdx = 0;
    for (var i = 0; i < samples; i++) {
      if (alts[i] > maxAlt) {
        maxAlt = alts[i];
        maxIdx = i;
      }
      if (alts[i] < minAlt) minAlt = alts[i];
    }

    if (maxAlt < h0) return const RiseSetTimes(neverRises: true);

    DateTime timeAt(double sampleIndex) => dayStart.add(
      Duration(seconds: (sampleIndex * stepMinutes * 60).round()),
    );

    // Transit: parabolic interpolation around the maximum altitude
    var transitIdx = maxIdx.toDouble();
    if (maxIdx > 0 && maxIdx < samples - 1) {
      final d1 = alts[maxIdx - 1], d2 = alts[maxIdx], d3 = alts[maxIdx + 1];
      final denom = d1 - 2 * d2 + d3;
      if (denom.abs() > 1e-12) {
        transitIdx = maxIdx + 0.5 * (d1 - d3) / denom;
      }
    }
    final transit = timeAt(transitIdx);

    if (minAlt > h0) {
      return RiseSetTimes(transit: transit, circumpolar: true);
    }

    DateTime? rise, set;
    for (var i = 1; i < samples; i++) {
      final a0 = alts[i - 1], a1 = alts[i];
      if (a0 < h0 && a1 >= h0 && rise == null) {
        rise = timeAt(i - 1 + (h0 - a0) / (a1 - a0));
      }
      if (a0 >= h0 && a1 < h0 && set == null) {
        set = timeAt(i - 1 + (a0 - h0) / (a0 - a1));
      }
    }
    return RiseSetTimes(rise: rise, transit: transit, set: set);
  }

  // ---- Internal implementation ----

  double _centuriesFromJ2000(DateTime utc) =>
      (astroEngine.julianDate(utc) - 2451545.0) / 36525.0;

  /// Mean obliquity of the ecliptic [deg] (leading terms of Meeus eq. 22.2)
  double _obliquityDeg(double t) => 23.43929111 - 0.01300417 * t;

  SkyPoint _eclipticToEquatorial(double lambdaDeg, double betaDeg, double t) {
    final eps = _obliquityDeg(t) * _d2r;
    final lambda = lambdaDeg * _d2r;
    final beta = betaDeg * _d2r;
    final ra = math.atan2(
      math.sin(lambda) * math.cos(eps) - math.tan(beta) * math.sin(eps),
      math.cos(lambda),
    );
    final dec = math.asin(
      (math.sin(beta) * math.cos(eps) +
              math.cos(beta) * math.sin(eps) * math.sin(lambda))
          .clamp(-1.0, 1.0),
    );
    return SkyPoint(ra * _r2d, dec * _r2d);
  }

  /// Apparent ecliptic longitude of the Sun [deg] and geocentric distance [au] (Meeus ch. 25, low accuracy)
  (double, double) _sunEclipticLongitude(double t) {
    final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final m = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * _d2r;
    final e = 0.016708634 - 0.000042037 * t;
    final c =
        (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(m) +
        (0.019993 - 0.000101 * t) * math.sin(2 * m) +
        0.000289 * math.sin(3 * m);
    final trueLongitude = l0 + c;
    final nuRad = m + c * _d2r; // True anomaly ν = M[rad] + C[deg→rad]
    final r = 1.000001018 * (1 - e * e) / (1 + e * math.cos(nuRad));
    // Apparent longitude (leading terms of aberration and nutation, Meeus eq. 25.10)
    final omega = (125.04 - 1934.136 * t) * _d2r;
    final apparent = trueLongitude - 0.00569 - 0.00478 * math.sin(omega);
    return (_normalizeDeg(apparent), r);
  }

  /// Lunar ecliptic longitude/latitude [deg] and distance [km] (leading terms of Meeus ch. 47, tables 47.A/47.B)
  (double, double, double) _moonEcliptic(double t) {
    final lp =
        _normalizeDeg(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t) *
        _d2r;
    final d =
        _normalizeDeg(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t) *
        _d2r;
    final m = _normalizeDeg(357.5291092 + 35999.0502909 * t) * _d2r;
    final mp =
        _normalizeDeg(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t) *
        _d2r;
    final f =
        _normalizeDeg(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t) *
        _d2r;
    // Eccentricity correction factor (applied to M terms, Meeus eq. 47.6)
    final eCorr = 1 - 0.002516 * t - 0.0000074 * t * t;

    // Leading longitude terms [1e-6 deg] (top of table 47.A)
    final sumL =
        6288774 * math.sin(mp) +
        1274027 * math.sin(2 * d - mp) +
        658314 * math.sin(2 * d) +
        213618 * math.sin(2 * mp) -
        185116 * eCorr * math.sin(m) -
        114332 * math.sin(2 * f) +
        58793 * math.sin(2 * d - 2 * mp) +
        57066 * eCorr * math.sin(2 * d - m - mp) +
        53322 * math.sin(2 * d + mp) +
        45758 * eCorr * math.sin(2 * d - m) -
        40923 * eCorr * math.sin(m - mp) -
        34720 * math.sin(d) -
        30383 * eCorr * math.sin(m + mp) +
        15327 * math.sin(2 * d - 2 * f) -
        12528 * math.sin(mp + 2 * f) +
        10980 * math.sin(mp - 2 * f);

    // Leading latitude terms [1e-6 deg] (top of table 47.B)
    final sumB =
        5128122 * math.sin(f) +
        280602 * math.sin(mp + f) +
        277693 * math.sin(mp - f) +
        173237 * math.sin(2 * d - f) +
        55413 * math.sin(2 * d - mp + f) +
        46271 * math.sin(2 * d - mp - f) +
        32573 * math.sin(2 * d + f) +
        17198 * math.sin(2 * mp + f);

    // Leading distance terms [1e-3 km] (table 47.A)
    final sumR =
        -20905355 * math.cos(mp) -
        3699111 * math.cos(2 * d - mp) -
        2955968 * math.cos(2 * d) -
        569925 * math.cos(2 * mp);

    final lambda = _normalizeDeg(lp * _r2d + sumL / 1e6);
    final beta = sumB / 1e6;
    final distanceKm = 385000.56 + sumR / 1e3;
    return (lambda, beta, distanceKm);
  }

  /// Geocentric apparent position of a planet (Standish approximate Keplerian elements 1800-2050).
  ///
  /// Source: E.M. Standish "Approximate Positions of the Planets"
  /// (JPL Solar System Dynamics, Table 1). Earth approximated by the EM barycenter.
  SkyPoint _planetPosition(SolarBodyId body, double t) {
    final planet = _heliocentric(_elements[body]!, t);
    final earth = _heliocentric(_earthElements, t);
    final gx = planet.$1 - earth.$1;
    final gy = planet.$2 - earth.$2;
    final gz = planet.$3 - earth.$3;
    final lambda = math.atan2(gy, gx) * _r2d;
    final beta = math.atan2(gz, math.sqrt(gx * gx + gy * gy)) * _r2d;
    return _eclipticToEquatorial(_normalizeDeg(lambda), beta, t);
  }

  /// Keplerian elements (Standish-format element list) → heliocentric ecliptic Cartesian coordinates [au]
  (double, double, double) _heliocentric(List<double> el, double t) {
    final a = el[0] + el[6] * t;
    final e = el[1] + el[7] * t;
    final inc = (el[2] + el[8] * t) * _d2r;
    final l = el[3] + el[9] * t;
    final lonPeri = el[4] + el[10] * t;
    final lonNode = el[5] + el[11] * t;

    final m = _normalizeDeg(l - lonPeri) * _d2r;
    final omega = (lonPeri - lonNode) * _d2r;
    final node = lonNode * _d2r;
    return _orbitalXyz(a, e, inc, omega, node, m);
  }

  /// Six orbital elements → heliocentric ecliptic Cartesian coordinates [au] (all angles in radians).
  ///
  /// [omega] = argument of perihelion ω, [node] = longitude of ascending node Ω, [m] = mean anomaly.
  (double, double, double) _orbitalXyz(
    double a,
    double e,
    double inc,
    double omega,
    double node,
    double m,
  ) {
    // Solve Kepler's equation with Newton's method
    var bigE = m + e * math.sin(m);
    for (var i = 0; i < 32; i++) {
      final delta = (bigE - e * math.sin(bigE) - m) / (1 - e * math.cos(bigE));
      bigE -= delta;
      if (delta.abs() < 1e-9) break;
    }

    final xp = a * (math.cos(bigE) - e);
    final yp = a * math.sqrt(1 - e * e) * math.sin(bigE);

    final cosO = math.cos(node), sinO = math.sin(node);
    final cosI = math.cos(inc), sinI = math.sin(inc);
    final cosW = math.cos(omega), sinW = math.sin(omega);

    final x =
        (cosW * cosO - sinW * sinO * cosI) * xp +
        (-sinW * cosO - cosW * sinO * cosI) * yp;
    final y =
        (cosW * sinO + sinW * cosO * cosI) * xp +
        (-sinW * sinO + cosW * cosO * cosI) * yp;
    final z = (sinW * sinI) * xp + (cosW * sinI) * yp;
    return (x, y, z);
  }

  static double _normalizeDeg(double deg) {
    final d = deg % 360.0;
    return d < 0 ? d + 360.0 : d;
  }

  /// [a, e, I, L, ϖ, Ω, da, de, dI, dL, dϖ, dΩ] (au, deg, per Julian century)
  static const _earthElements = [
    1.00000261, 0.01671123, -0.00001531, 100.46457166, 102.93768193, 0.0, //
    0.00000562, -0.00004392, -0.01294668, 35999.37244981, 0.32327364, 0.0,
  ];

  static const Map<SolarBodyId, List<double>> _elements = {
    SolarBodyId.mercury: [
      0.38709927, 0.20563593, 7.00497902, 252.25032350, 77.45779628,
      48.33076593, //
      0.00000037, 0.00001906, -0.00594749, 149472.67411175, 0.16047689,
      -0.12534081,
    ],
    SolarBodyId.venus: [
      0.72333566, 0.00677672, 3.39467605, 181.97909950, 131.60246718,
      76.67984255, //
      0.00000390, -0.00004107, -0.00078890, 58517.81538729, 0.00268329,
      -0.27769418,
    ],
    SolarBodyId.mars: [
      1.52371034, 0.09339410, 1.84969142, -4.55343205, -23.94362959,
      49.55953891, //
      0.00001847, 0.00007882, -0.00813131, 19140.30268499, 0.44441088,
      -0.29257343,
    ],
    SolarBodyId.jupiter: [
      5.20288700, 0.04838624, 1.30439695, 34.39644051, 14.72847983,
      100.47390909, //
      -0.00011607, -0.00013253, -0.00183714, 3034.74612775, 0.21252668,
      0.20469106,
    ],
    SolarBodyId.saturn: [
      9.53667594, 0.05386179, 2.48599187, 49.95424423, 92.59887831,
      113.66242448, //
      -0.00125060, -0.00050991, 0.00193609, 1222.49362201, -0.41897216,
      -0.28867794,
    ],
    SolarBodyId.uranus: [
      19.18916464, 0.04725744, 0.77263783, 313.23810451, 170.95427630,
      74.01692503, //
      -0.00196176, -0.00004397, -0.00242939, 428.48202785, 0.40805281,
      0.04240589,
    ],
    SolarBodyId.neptune: [
      30.06992276, 0.00859048, 1.77004347, -55.12002969, 44.96476227,
      131.78422574, //
      0.00026291, 0.00005105, 0.00035372, 218.45945325, -0.32241464,
      -0.00508664,
    ],
  };
}
