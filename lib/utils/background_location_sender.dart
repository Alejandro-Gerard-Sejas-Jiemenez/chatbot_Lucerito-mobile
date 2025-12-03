import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../config/api_config.dart';

class BackgroundLocationSender {
  static final BackgroundLocationSender _instance =
      BackgroundLocationSender._internal();

  factory BackgroundLocationSender() {
    return _instance;
  }

  BackgroundLocationSender._internal();

  final LocationService _locationService = LocationService(
    baseUrl: ApiConfig.baseUrl,
  );
  Timer? _timer;

  // Callback para notificar cuando se recibe una nueva orden
  Function(int idOrden)? onNewOrderReceived;

  Future<void> _sendCurrentLocation() async {
    try {
      // Verificar permisos primero
      LocationPermission permission = await Geolocator.checkPermission();
      print('Estado de permisos de ubicación: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permisos de ubicación denegados permanentemente');
        return;
      }

      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Servicio de ubicación habilitado: $serviceEnabled');

      if (!serviceEnabled) {
        print('El servicio de ubicación está deshabilitado');
        return;
      }

      print('Obteniendo ubicación actual...');
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      print(
        'Ubicación obtenida exitosamente: Latitud ${pos.latitude}, Longitud ${pos.longitude}',
      );

      final result = await _locationService.sendLocation(
        latitud: pos.latitude,
        longitud: pos.longitude,
      );

      if (result != null) {
        print('Ubicación enviada correctamente al servidor');
        print('Respuesta del servidor: $result');

        // Verificar si hay una nueva orden asignada
        if (result['id_orden_actual'] != null) {
          final idOrden = result['id_orden_actual'] as int;
          print('¡Nueva orden detectada! ID: $idOrden');

          // Llamar al callback si está registrado
          if (onNewOrderReceived != null) {
            onNewOrderReceived!(idOrden);
          } else {
            print(
              'ADVERTENCIA: Hay una nueva orden pero no hay callback registrado para mostrarla',
            );
          }
        }
      } else {
        print('Falló el envío de ubicación al servidor');
      }
    } catch (e) {
      print('Error al obtener/enviar ubicación: $e');
    }
  }

  void start() {
    // Evitar iniciar múltiples timers
    if (_timer != null && _timer!.isActive) {
      print('BackgroundLocationSender ya está activo');
      return;
    }

    print(
      'Iniciando BackgroundLocationSender - enviará ubicación cada 2 minutos',
    );

    // Enviar ubicación inmediatamente al iniciar
    _sendCurrentLocation();

    // Luego programar envíos periódicos cada 2 minutos
    _timer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _sendCurrentLocation();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    print('BackgroundLocationSender detenido');
  }
}
