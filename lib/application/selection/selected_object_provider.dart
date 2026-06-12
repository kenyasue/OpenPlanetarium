import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/astro/projection.dart';
import '../../domain/models/geo_location.dart';
import '../../domain/models/sky_object.dart';
import '../../domain/models/sky_point.dart';
import '../../domain/models/solar_system.dart';
import '../../domain/models/star.dart';
import '../location/location_controller.dart';
import '../sky/dso_provider.dart';
import '../sky/solar_system_provider.dart';
import '../sky/visible_stars_provider.dart';
import '../time/time_controller.dart';
import '../viewport/viewport_controller.dart';
import 'object_picker.dart';

/// Controller managing the selected celestial object (star / DSO / solar system) (F9).
class SelectedObjectController extends Notifier<SkyObject?> {
  @override
  SkyObject? build() => null;

  void select(SkyObject? object) => state = object;

  void clear() => state = null;

  /// Selects the nearest celestial object at the screen point (deselects if none matches)
  void selectAtScreenPoint(Offset point) {
    final viewState = ref.read(viewportStateProvider);
    state = pickObjectAtPoint(
      stars: ref.read(visibleStarsProvider).value ?? const <Star>[],
      dsos: ref.read(visibleDsosProvider),
      solarBodies: ref.read(solarSystemProvider),
      projection: ViewProjection(viewState),
      point: point,
    );
  }
}

final selectedObjectProvider =
    NotifierProvider<SelectedObjectController, SkyObject?>(
      SelectedObjectController.new,
    );

/// Current RA/Dec of the selected object (solar system bodies track the observation time).
final selectedObjectPositionProvider = Provider<SkyPoint?>((ref) {
  final selected = ref.watch(selectedObjectProvider);
  return switch (selected) {
    null => null,
    StarObject(:final star) => SkyPoint(star.raDeg, star.decDeg),
    DsoObject(:final dso) => SkyPoint(dso.raDeg, dso.decDeg),
    SolarBodyObject(:final body) =>
      ref.watch(solarSystemProvider).firstWhere((p) => p.body == body).position,
  };
});

/// Local observation date (does not change with second-level time updates)
final _observationDateProvider = Provider<DateTime>((ref) {
  return ref.watch(
    timeControllerProvider.select((t) {
      final local = t.toLocal();
      return DateTime(local.year, local.month, local.day);
    }),
  );
});

/// Rise/set and transit times of the selected object.
///
/// riseSetTimes is an expensive computation involving 145 sampled coordinate
/// transforms, so it is recomputed only when the date, object, or observing location
/// changes (not on the 100ms time updates during diurnal playback). Solar system body
/// positions are represented by noon of that day (accurate enough for displaying rise/set times).
final selectedObjectRiseSetProvider = Provider<RiseSetTimes?>((ref) {
  final selected = ref.watch(selectedObjectProvider);
  if (selected == null) return null;
  final date = ref.watch(_observationDateProvider);
  final location =
      ref.watch(locationControllerProvider).value?.location ??
      GeoLocation.tokyo;
  final engine = ref.watch(ephemerisEngineProvider);

  final position = switch (selected) {
    StarObject(:final star) => SkyPoint(star.raDeg, star.decDeg),
    DsoObject(:final dso) => SkyPoint(dso.raDeg, dso.decDeg),
    SolarBodyObject(:final body) => engine.position(
      body,
      DateTime(date.year, date.month, date.day, 12).toUtc(),
    ),
  };
  return engine.riseSetTimes(position, location, date);
});
