/// Solar system body identifier (F7).
enum SolarBodyId {
  sun('Sun', 'Sun'),
  moon('Moon', 'Moon'),
  mercury('Mercury', 'Mercury'),
  venus('Venus', 'Venus'),
  mars('Mars', 'Mars'),
  jupiter('Jupiter', 'Jupiter'),
  saturn('Saturn', 'Saturn'),
  uranus('Uranus', 'Uranus'),
  neptune('Neptune', 'Neptune');

  const SolarBodyId(this.nameJa, this.nameEn);

  final String nameJa;
  final String nameEn;
}

/// Representative magnitude for display/selection priority (rough value ignoring variation)
extension SolarBodyDisplay on SolarBodyId {
  double get representativeMagnitude => switch (this) {
    SolarBodyId.sun => -26.7,
    SolarBodyId.moon => -12.7,
    SolarBodyId.mercury => 0.0,
    SolarBodyId.venus => -4.0,
    SolarBodyId.mars => 0.5,
    SolarBodyId.jupiter => -2.2,
    SolarBodyId.saturn => 0.6,
    SolarBodyId.uranus => 5.7,
    SolarBodyId.neptune => 7.9,
  };
}

/// Moon phase information.
class MoonPhase {
  const MoonPhase({
    required this.ageDays,
    required this.illuminatedFraction,
    required this.waxing,
  });

  /// Moon age [days] 0 to about 29.5 (new moon = 0)
  final double ageDays;

  /// Illuminated fraction 0 (new moon) to 1 (full moon)
  final double illuminatedFraction;

  /// Whether the moon is waxing (first-quarter side)
  final bool waxing;
}

/// Rise/set and transit times of a celestial object (F9/F10).
///
/// [circumpolar]=true means it never sets (rise/set are null);
/// [neverRises]=true means it never rises (rise/transit/set all treated as null).
class RiseSetTimes {
  const RiseSetTimes({
    this.rise,
    this.transit,
    this.set,
    this.circumpolar = false,
    this.neverRises = false,
  });

  final DateTime? rise;
  final DateTime? transit;
  final DateTime? set;
  final bool circumpolar;
  final bool neverRises;
}
