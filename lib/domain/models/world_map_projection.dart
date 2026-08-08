/// Equirectangular (plate carrée) projection between geographic coordinates
/// and normalized map coordinates.
///
/// Normalized coordinates: x ∈ [0,1] left→right = lon -180°→+180°,
/// y ∈ [0,1] top→bottom = lat +90°→-90°. Multiply by the widget size to get
/// pixel positions. Pure functions so the painter and hit-testing share one
/// definition.
library;

/// Longitude [deg] → normalized x [0,1]
double lonToMapX(double lonDeg) => (lonDeg + 180.0) / 360.0;

/// Latitude [deg] → normalized y [0,1]
double latToMapY(double latDeg) => (90.0 - latDeg) / 180.0;

/// Normalized x [0,1] → longitude [deg]
double mapXToLon(double x) => x * 360.0 - 180.0;

/// Normalized y [0,1] → latitude [deg]
double mapYToLat(double y) => 90.0 - y * 180.0;

/// Whether the normalized point lies on the map (used to ignore taps on the
/// letterboxed area around the map)
bool isOnMap(double x, double y) => x >= 0 && x <= 1 && y >= 0 && y <= 1;
