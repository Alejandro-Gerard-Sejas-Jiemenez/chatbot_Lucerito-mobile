import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../config/api_config.dart';

class BackgroundLocationSender {
  final LocationService _locationService = LocationService(baseUrl: ApiConfig.baseUrl);
  Timer? _timer;

  BackgroundLocationSender();

  void start() {
    _timer = Timer.periodic(const Duration(minutes: 2), (_) async {
      try {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await _locationService.sendLocation(latitud: pos.latitude, longitud: pos.longitude);
      } catch (_) {}
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
