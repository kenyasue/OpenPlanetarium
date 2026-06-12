import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/astro/astro_engine.dart';
import '../../domain/astro/projection.dart';
import '../../domain/models/geo_location.dart';
import '../../domain/models/horizontal_coord.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/viewport_state.dart';
import '../location/location_controller.dart';
import '../time/time_controller.dart';

/// Clamp range of the field of view [degrees]
const double kMinFovDeg = 0.5;
const double kMaxFovDeg = 120.0;

/// Viewport geometry that changes with user interaction.
///
/// Date/time and observing location are held by TimeController / LocationController,
/// and the complete ViewportState is assembled by [viewportStateProvider].
class ViewportGeometry {
  const ViewportGeometry({
    required this.center,
    required this.fovDeg,
    required this.screenSize,
    required this.generation,
  });

  final SkyPoint center;
  final double fovDeg;
  final Size screenSize;

  /// Generation counter incremented on each user interaction
  final int generation;

  ViewportGeometry copyWith({
    SkyPoint? center,
    double? fovDeg,
    Size? screenSize,
  }) {
    return ViewportGeometry(
      center: center ?? this.center,
      fovDeg: fovDeg ?? this.fovDeg,
      screenSize: screenSize ?? this.screenSize,
      generation: generation + 1,
    );
  }
}

/// Controller managing pan, zoom, and centering.
class ViewportController extends Notifier<ViewportGeometry> {
  static const _engine = AstroEngine();

  @override
  ViewportGeometry build() {
    // When the time changes, keep the view center fixed in Alt/Az (horizontal coordinates).
    // Fixing RA/Dec would rotate the viewpoint along with the sky, contradicting the intuition
    // of looking up from the ground (the expected behavior is that moving the time makes stars
    // drift through the field of view with diurnal motion).
    ref.listen(timeControllerProvider, (previous, next) {
      if (previous == null || previous == next) return;
      final location =
          ref.read(locationControllerProvider).value?.location ??
          GeoLocation.tokyo;
      final horizontal = _engine.equatorialToHorizontal(
        state.center,
        location,
        previous,
      );
      state = state.copyWith(
        center: _engine.horizontalToEquatorial(horizontal, location, next),
      );
    });

    // Initial view: southern sky, altitude 35° (first time only; later location changes do not re-center)
    final time = ref.read(timeControllerProvider);
    final location =
        ref.read(locationControllerProvider).value?.location ??
        GeoLocation.tokyo;
    final center = _engine.horizontalToEquatorial(
      const HorizontalCoord(altDeg: 35, azDeg: 180),
      location,
      time,
    );
    return ViewportGeometry(
      center: center,
      fovDeg: 70,
      screenSize: const Size(1280, 720),
      generation: 0,
    );
  }

  /// Moves the view center according to the screen drag amount [px].
  ///
  /// Unprojects "the screen point offset from the center by delta in the opposite direction"
  /// in the current projection and uses it as the new center (a natural feel where the
  /// dragged star follows the finger).
  void pan(Offset deltaPx) {
    final viewState = _assembleState();
    final proj = ViewProjection(viewState);
    final newCenterScreen = Offset(
      state.screenSize.width / 2 - deltaPx.dx,
      state.screenSize.height / 2 - deltaPx.dy,
    );
    final newCenter = proj.unproject(newCenterScreen);
    state = state.copyWith(center: newCenter);
  }

  /// Zoom. [scaleFactor] > 1 zooms in (the field of view narrows).
  ///
  /// When [focalPoint] (screen coordinates) is given, the center is adjusted so that
  /// the sky at that point stays put (focal zoom for pinch and mouse wheel).
  void zoom(double scaleFactor, {Offset? focalPoint}) {
    if (scaleFactor <= 0) return;
    final newFov = (state.fovDeg / scaleFactor).clamp(kMinFovDeg, kMaxFovDeg);
    if (newFov == state.fovDeg) return;

    if (focalPoint == null) {
      state = state.copyWith(fovDeg: newFov);
      return;
    }

    // Keep the celestial coordinates under the focal point fixed across the zoom
    final before = ViewProjection(_assembleState()).unproject(focalPoint);
    state = state.copyWith(fovDeg: newFov);
    final after = ViewProjection(_assembleState()).project(before);
    if (after != null) {
      pan(focalPoint - after);
    }
  }

  /// Centers on the given object or coordinates
  void centerOn(SkyPoint target, {double? fovDeg}) {
    state = state.copyWith(
      center: target,
      fovDeg: fovDeg?.clamp(kMinFovDeg, kMaxFovDeg),
    );
  }

  /// Applies a screen size change (resize, rotation)
  void resize(Size size) {
    if (size == state.screenSize || size.isEmpty) return;
    state = state.copyWith(screenSize: size);
  }

  ViewportState _assembleState() {
    final time = ref.read(timeControllerProvider);
    final location =
        ref.read(locationControllerProvider).value?.location ??
        GeoLocation.tokyo;
    return ViewportState(
      center: state.center,
      fovDeg: state.fovDeg,
      screenSize: state.screenSize,
      observationTime: time,
      location: location,
      viewportId: state.generation,
    );
  }
}

final viewportControllerProvider =
    NotifierProvider<ViewportController, ViewportGeometry>(
      ViewportController.new,
    );

/// Complete view state combining geometry + observation time + observing location.
///
/// viewportId matches the geometry interaction generation (ViewportGeometry.generation).
/// Changes in time or observing location are detected via ViewportState equality
/// (M2's query generation management uses the identity of the whole ViewportState).
final viewportStateProvider = Provider<ViewportState>((ref) {
  final geometry = ref.watch(viewportControllerProvider);
  final time = ref.watch(timeControllerProvider);
  final location =
      ref.watch(locationControllerProvider).value?.location ??
      GeoLocation.tokyo;
  return ViewportState(
    center: geometry.center,
    fovDeg: geometry.fovDeg,
    screenSize: geometry.screenSize,
    observationTime: time,
    location: location,
    viewportId: geometry.generation,
  );
});
