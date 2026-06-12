import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/platform/location_provider.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/geo_location.dart';
import '../settings/settings_persistence.dart';

/// DI point for DeviceLocationProvider (overridable in tests).
final deviceLocationProviderProvider = Provider<DeviceLocationProvider>(
  (ref) => const GeolocatorLocationProvider(),
);

/// Controller managing the observing location.
///
/// Attempts a GPS fix at startup and falls back to the default (Tokyo) on failure
/// (graceful degradation, error classification in docs/functional-design.md).
class LocationController extends AsyncNotifier<LocationFix> {
  static const _key = 'settings.manualLocation';

  @override
  Future<LocationFix> build() async {
    // If a manually set observing location exists, restore it with top priority
    // (settings storage failures are ignored, falling back to GPS — settings must not break the app)
    String? saved;
    try {
      saved = await ref.watch(settingsRepositoryProvider).read(_key);
    } on Exception {
      // Storage initialization failure or I/O error — fall back to GPS
      saved = null;
    }
    if (saved != null) {
      try {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        return LocationFix(
          location: GeoLocation(
            latitudeDeg: (json['lat'] as num).toDouble(),
            longitudeDeg: (json['lon'] as num).toDouble(),
            name: json['name'] as String?,
          ),
          source: LocationSource.manual,
        );
      } on FormatException {
        // Ignore corrupted settings and fall back to GPS
      }
    }

    final provider = ref.watch(deviceLocationProviderProvider);
    try {
      final location = await provider.getCurrentLocation();
      return LocationFix(location: location, source: LocationSource.gps);
    } on LocationUnavailableException {
      // On permission denial or timeout, continue with the default location (unexpected exceptions propagate)
      return const LocationFix(
        location: GeoLocation.tokyo,
        source: LocationSource.fallback,
      );
    }
  }

  /// Sets the observing location manually (persisted)
  void setManualLocation(GeoLocation location) {
    state = AsyncValue.data(
      LocationFix(location: location, source: LocationSource.manual),
    );
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .write(
            _key,
            jsonEncode({
              'lat': location.latitudeDeg,
              'lon': location.longitudeDeg,
              'name': location.name,
            }),
          ),
    );
  }

  /// Attempts to re-acquire the location via GPS
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final provider = ref.read(deviceLocationProviderProvider);
      final location = await provider.getCurrentLocation();
      return LocationFix(location: location, source: LocationSource.gps);
    });
    // On failure, do not stay in the error state; continue with the default
    if (state.hasError) {
      state = const AsyncValue.data(
        LocationFix(
          location: GeoLocation.tokyo,
          source: LocationSource.fallback,
        ),
      );
    }
  }
}

final locationControllerProvider =
    AsyncNotifierProvider<LocationController, LocationFix>(
      LocationController.new,
    );
