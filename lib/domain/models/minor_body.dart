import 'dart:math' as math;

/// Minor body kind (F7 extension).
enum MinorBodyKind {
  asteroid('Asteroid'),
  comet('Comet');

  const MinorBodyKind(this.labelJa);

  final String labelJa;
}

/// Keplerian orbital elements (J2000 ecliptic frame, from JPL SBDB).
class OrbitalElements {
  const OrbitalElements({
    required this.epochJd,
    required this.aAu,
    required this.e,
    required this.iDeg,
    required this.nodeDeg,
    required this.argPeriDeg,
    required this.meanAnomalyDeg,
  });

  /// Epoch of the elements (Julian date)
  final double epochJd;

  /// Semi-major axis [au] (comets converted from q/(1−e); e<1 only)
  final double aAu;

  /// Eccentricity
  final double e;

  /// Orbital inclination [deg]
  final double iDeg;

  /// Longitude of ascending node Ω [deg]
  final double nodeDeg;

  /// Argument of perihelion ω [deg]
  final double argPeriDeg;

  /// Mean anomaly M0 at epoch [deg]
  final double meanAnomalyDeg;
}

/// Asteroid/comet (bundled asset data from JPL SBDB, F7 extension).
class MinorBody {
  const MinorBody({
    required this.id,
    required this.name,
    required this.kind,
    required this.elements,
    required this.mag1,
    required this.mag2,
    this.nameJa,
  });

  /// SPK-ID (JPL unique ID)
  final String id;

  /// Name ('1 Ceres' / '2P/Encke', etc.)
  final String name;

  /// Japanese name (well-known objects only)
  final String? nameJa;

  final MinorBodyKind kind;
  final OrbitalElements elements;

  /// Asteroid: absolute magnitude H / Comet: total magnitude parameter M1
  final double mag1;

  /// Asteroid: unused (0) / Comet: magnitude slope K1
  final double mag2;

  String get displayName => nameJa ?? name;

  /// Computes apparent magnitude from heliocentric distance r and geocentric distance Δ [au].
  ///
  /// Asteroid: V = H + 5·log10(r·Δ) (phase correction omitted; conservative side)
  /// Comet:    m = M1 + 5·log10(Δ) + 2.5·K1·log10(r)
  double magnitudeAt({required double rAu, required double deltaAu}) {
    switch (kind) {
      case MinorBodyKind.asteroid:
        return mag1 + 5.0 * _log10(rAu * deltaAu);
      case MinorBodyKind.comet:
        return mag1 + 5.0 * _log10(deltaAu) + 2.5 * mag2 * _log10(rAu);
    }
  }

  static double _log10(double x) => math.log(x) / math.ln10;
}
