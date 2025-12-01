import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<void> printCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Ubicación deshabilitada');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permiso de ubicación denegado');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print('Permiso de ubicación denegado permanentemente');
        return;
      }
      Position pos = await Geolocator.getCurrentPosition();
      print('Latitud: \\${pos.latitude}, Longitud: \\${pos.longitude}');
    } catch (e) {
      print('Error obteniendo ubicación: \\${e.toString()}');
    }
  }
}
