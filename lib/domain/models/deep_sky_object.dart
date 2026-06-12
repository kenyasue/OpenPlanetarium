/// Deep-sky object type (docs/glossary.md).
enum ObjectType {
  galaxy('Galaxy'),
  openCluster('Open cluster'),
  globularCluster('Globular cluster'),
  nebula('Nebula'),
  planetaryNebula('Planetary nebula'),
  supernovaRemnant('Supernova remnant'),
  darkNebula('Dark nebula'),
  other('Celestial object');

  const ObjectType(this.labelJa);

  final String labelJa;
}

/// Catalog a DSO belongs to (unit of display filtering, F7).
enum DsoCatalog {
  messier('Messier'),
  ngc('NGC'),
  ic('IC'),
  sh2('Sh2'),
  lbn('LBN'),
  ldn('LDN'),
  vdb('vdB'),
  other('Other');

  const DsoCatalog(this.labelJa);

  final String labelJa;
}

/// Deep-sky object (Messier, NGC/IC; F7).
class DeepSkyObject {
  const DeepSkyObject({
    required this.id,
    required this.objectType,
    required this.raDeg,
    required this.decDeg,
    this.commonName,
    this.nameJa,
    this.magnitude,
    this.majorAxisArcmin,
    this.minorAxisArcmin,
    this.constellation,
    this.messierNumber,
  });

  /// Catalog ID ('NGC0224' / 'IC0434' / 'Mel022', etc.)
  final String id;

  final ObjectType objectType;
  final double raDeg;
  final double decDeg;

  /// Common name (English, e.g. 'Andromeda Galaxy')
  final String? commonName;

  /// Japanese name (famous objects only)
  final String? nameJa;

  /// Apparent magnitude (V magnitude, may be missing)
  final double? magnitude;

  /// Apparent diameter (major axis) [arcmin]
  final double? majorAxisArcmin;

  /// Apparent diameter (minor axis) [arcmin]
  final double? minorAxisArcmin;

  /// Host constellation (IAU abbreviation)
  final String? constellation;

  /// Messier number (31 = M31)
  final int? messierNumber;

  /// Set of catalogs this object belongs to (Messier objects may also belong to NGC, etc.).
  ///
  /// The display filter shows an object if any of its catalogs is enabled.
  Set<DsoCatalog> get catalogs {
    final result = <DsoCatalog>{
      if (messierNumber != null) DsoCatalog.messier,
      if (id.startsWith('NGC')) DsoCatalog.ngc,
      if (id.startsWith('IC')) DsoCatalog.ic,
      if (id.startsWith('SH2-')) DsoCatalog.sh2,
      if (id.startsWith('LBN')) DsoCatalog.lbn,
      if (id.startsWith('LDN')) DsoCatalog.ldn,
      if (id.startsWith('VDB')) DsoCatalog.vdb,
    };
    return result.isEmpty ? {DsoCatalog.other} : result;
  }

  /// Catalog designation in the form 'M31' / 'NGC 224' / 'Sh2-155'
  String get catalogLabel {
    if (messierNumber != null) return 'M$messierNumber';
    if (id.startsWith('NGC')) return 'NGC ${_stripZeros(id.substring(3))}';
    if (id.startsWith('IC')) return 'IC ${_stripZeros(id.substring(2))}';
    if (id.startsWith('SH2-')) return 'Sh2-${id.substring(4)}';
    if (id.startsWith('LBN')) return 'LBN ${_stripZeros(id.substring(3))}';
    if (id.startsWith('LDN')) return 'LDN ${_stripZeros(id.substring(3))}';
    if (id.startsWith('VDB')) return 'vdB ${_stripZeros(id.substring(3))}';
    return id;
  }

  /// Display name (Japanese name > common name > catalog designation)
  String get displayName => nameJa ?? commonName ?? catalogLabel;

  static String _stripZeros(String s) {
    final trimmed = s.replaceFirst(RegExp(r'^0+'), '');
    return trimmed.isEmpty ? s : trimmed;
  }
}
