import 'package:geolocator/geolocator.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/geo_location.dart';

/// Interface for retrieving the device location (referenced from the application layer).
abstract class DeviceLocationProvider {
  /// Gets the current location.
  ///
  /// Throws [LocationUnavailableException] on permission denial or timeout.
  Future<GeoLocation> getCurrentLocation();
}

/// Implementation backed by geolocator.
///
/// Location data is used only on the device and never sent externally
/// (PRD security requirement).
class GeolocatorLocationProvider implements DeviceLocationProvider {
  const GeolocatorLocationProvider({
    this.timeout = const Duration(seconds: 10),
  });

  final Duration timeout;

  @override
  Future<GeoLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationUnavailableException(
        'Location services are disabled',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableException(
        'Location permission was denied',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low, // Low accuracy is enough for sky chart use
          timeLimit: timeout,
        ),
      );
      return GeoLocation(
        latitudeDeg: position.latitude,
        longitudeDeg: position.longitude,
        name: 'Current location',
      );
    } on Exception catch (e) {
      throw LocationUnavailableException(
        'Could not get the current location: $e',
      );
    }
  }
}
