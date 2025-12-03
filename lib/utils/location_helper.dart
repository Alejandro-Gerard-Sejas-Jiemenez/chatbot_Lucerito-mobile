import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Ubicación deshabilitada');
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permiso de ubicación denegado');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print('Permiso de ubicación denegado permanentemente');
        return null;
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return pos;
    } catch (e) {
      print('Error obteniendo ubicación: ${e.toString()}');
      return null;
    }
  }

  static Future<void> printCurrentLocation() async {
    try {
      Position? pos = await getCurrentPosition();
      if (pos != null) {
        print('Latitud: ${pos.latitude}, Longitud: ${pos.longitude}');
      }
    } catch (e) {
      print('Error obteniendo ubicación: ${e.toString()}');
    }
  }
}
