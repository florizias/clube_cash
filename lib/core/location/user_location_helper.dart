import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationData {
  final double latitude;
  final double longitude;
  final String address;

  const UserLocationData({required this.latitude, required this.longitude, required this.address});
}

class UserLocationHelper {
  static Future<UserLocationData?> getCurrentLocation() async {
    final Geocoding geocoding = Geocoding();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

    String address = '';

    try {
      final placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final parts = <String?>[
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

        address = parts.join(', ');
      }
    } catch (_) {
      address = '';
    }

    return UserLocationData(latitude: position.latitude, longitude: position.longitude, address: address);
  }
}
