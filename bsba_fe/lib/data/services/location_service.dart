import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Wraps device geolocation. Returns `null` whenever location is unavailable
/// (service off, permission denied, or any error) so callers can fall back to
/// a location-less request instead of crashing.
class LocationService {
  Future<(double lat, double lng)?> getCurrentLatLng() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      return (position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }
}
