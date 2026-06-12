/// HiPS survey layer definition (F11).
class SurveyLayerDef {
  const SurveyLayerDef({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.attribution,
    this.maxOrder = 9,
    this.tileExtension = 'jpg',
  });

  final String id;
  final String name;
  final String baseUrl;
  final String attribution;
  final int maxOrder;
  final String tileExtension;
}

/// Reference to a HiPS tile (order + NESTED number).
class HipsTileRef {
  const HipsTileRef({
    required this.surveyId,
    required this.order,
    required this.pix,
  });

  final String surveyId;
  final int order;
  final int pix;

  /// Tile path per the HiPS convention (Dir in units of 10000)
  String pathWithExtension(String extension) =>
      'Norder$order/Dir${(pix ~/ 10000) * 10000}/Npix$pix.$extension';

  /// Cache key
  String get key => '$surveyId/$order/$pix';

  @override
  bool operator ==(Object other) =>
      other is HipsTileRef &&
      other.surveyId == surveyId &&
      other.order == order &&
      other.pix == pix;

  @override
  int get hashCode => Object.hash(surveyId, order, pix);
}

/// Built-in surveys (the 4 initial layers in docs/functional-design.md.
/// URLs are CDS alasky, reachability verified on 2026-06-11).
const List<SurveyLayerDef> kBuiltinSurveys = [
  SurveyLayerDef(
    id: 'dss2_color',
    name: 'DSS Colored',
    baseUrl: 'https://alasky.cds.unistra.fr/DSS/DSSColor',
    attribution: 'DSS2 (CDS/Aladin, STScI/NASA)',
  ),
  SurveyLayerDef(
    id: 'dss2_blue',
    name: 'DSS Blue',
    baseUrl: 'https://alasky.cds.unistra.fr/DSS/DSS2-blue-XJ-S',
    attribution: 'DSS2 Blue (CDS/Aladin, STScI/NASA)',
  ),
  SurveyLayerDef(
    id: 'dss2_red',
    name: 'DSS Red',
    baseUrl: 'https://alasky.cds.unistra.fr/DSS/DSS2Merged',
    attribution: 'DSS2 Red (CDS/Aladin, STScI/NASA)',
  ),
  SurveyLayerDef(
    id: 'dss2_nir',
    name: 'DSS NIR',
    baseUrl: 'https://alasky.cds.unistra.fr/DSS/DSS2-NIR',
    attribution: 'DSS2 NIR (CDS/Aladin, STScI/NASA)',
  ),
];
