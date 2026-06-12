import 'dart:ui';

import 'geo_location.dart';
import 'sky_point.dart';

/// Display layer identifier (F2: enabledLayers).
enum LayerId { stars, constellations, deepSky, solarSystem, survey, grid }

/// Snapshot of the sky chart canvas display state (immutable, not persisted).
///
/// [viewportId] is a generation ID incremented on each state change. It
/// identifies which display state an async query result belongs to, used to
/// discard stale results (F2).
class ViewportState {
  const ViewportState({
    required this.center,
    required this.fovDeg,
    required this.screenSize,
    required this.observationTime,
    required this.location,
    required this.viewportId,
    this.limitingMagnitude = 6.5,
    this.enabledLayers = const {LayerId.grid},
  });

  /// Celestial coordinates of the screen center (J2000)
  final SkyPoint center;

  /// Vertical field of view (FOV) [deg] (the substance of the zoom level)
  final double fovDeg;

  /// Screen size [logical px]
  final Size screenSize;

  /// Observation time (UTC)
  final DateTime observationTime;

  /// Observing location
  final GeoLocation location;

  /// Generation ID (monotonically increasing on each change)
  final int viewportId;

  /// Display limiting magnitude (derived from LOD. Dynamic in M2, default in M1)
  final double limitingMagnitude;

  /// Enabled display layers
  final Set<LayerId> enabledLayers;

  ViewportState copyWith({
    SkyPoint? center,
    double? fovDeg,
    Size? screenSize,
    DateTime? observationTime,
    GeoLocation? location,
    int? viewportId,
    double? limitingMagnitude,
    Set<LayerId>? enabledLayers,
  }) {
    return ViewportState(
      center: center ?? this.center,
      fovDeg: fovDeg ?? this.fovDeg,
      screenSize: screenSize ?? this.screenSize,
      observationTime: observationTime ?? this.observationTime,
      location: location ?? this.location,
      viewportId: viewportId ?? this.viewportId,
      limitingMagnitude: limitingMagnitude ?? this.limitingMagnitude,
      enabledLayers: enabledLayers ?? this.enabledLayers,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ViewportState &&
      other.center == center &&
      other.fovDeg == fovDeg &&
      other.screenSize == screenSize &&
      other.observationTime == observationTime &&
      other.location == location &&
      other.viewportId == viewportId &&
      other.limitingMagnitude == limitingMagnitude &&
      _setEquals(other.enabledLayers, enabledLayers);

  @override
  int get hashCode => Object.hash(
    center,
    fovDeg,
    screenSize,
    observationTime,
    location,
    viewportId,
    limitingMagnitude,
    Object.hashAllUnordered(enabledLayers),
  );

  static bool _setEquals(Set<LayerId> a, Set<LayerId> b) =>
      a.length == b.length && a.containsAll(b);
}
