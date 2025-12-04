import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'dart:math' as math;
import '../data/models/pedido.dart';
import '../utils/route_utils.dart';
import '../services/location_service.dart';
import '../config/api_config.dart';

typedef RouteInfoCallback = void Function(double? distance, double? duration);

class PedidoMap extends StatefulWidget {
  final Pedido pedido;
  final RouteInfoCallback? onRouteInfo;
  final bool toRestaurante;
  final bool toLocal;
  final bool toCliente;

  const PedidoMap({
    Key? key,
    required this.pedido,
    this.onRouteInfo,
    this.toRestaurante = true,
    this.toLocal = false,
    this.toCliente = false,
  }) : super(key: key);

  @override
  State<PedidoMap> createState() => _PedidoMapState();
}

class _PedidoMapState extends State<PedidoMap> {
  void _centrarMapaEntrePuntos(LatLng punto1, LatLng punto2) {
    final centerLat = (punto1.latitude + punto2.latitude) / 2;
    final centerLng = (punto1.longitude + punto2.longitude) / 2;
    final center = LatLng(centerLat, centerLng);
    _mapController.move(center, 15); // 15 es el zoom, ajusta si quieres
  }

  final MapController _mapController = MapController();
  LatLng? _conductorPos;
  bool _loading = true;
  StreamSubscription<Position>? _positionStream;
  Timer? _locationTimer;

  List<LatLng>? _routePoints;
  double? _routeDistance; // metros
  double? _routeDuration; // segundos
  bool _routeLoading = false;
  LatLng?
  _lastRouteFetchPosition; // Última posición desde la que se calculó la ruta

  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _initLocationStream();
    _locationService = LocationService(baseUrl: ApiConfig.baseUrl);
    // Enviar ubicación cada 2 minutos
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_conductorPos != null) {
        _sendLocationToBackend(
          _conductorPos!.latitude,
          _conductorPos!.longitude,
        );
      }
    });
  }

  void _initLocationStream() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }
      // Centrar el mapa cuando se actualiza la posición del conductor
      if (_conductorPos != null) {
        _centrarMapaEntrePuntos(
          _conductorPos!,
          LatLng(
            widget.pedido.ubicacionLocal.latitud,
            widget.pedido.ubicacionLocal.longitud,
          ),
        );
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _loading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loading = false);
        return;
      }
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position pos) {
            final newPos = LatLng(pos.latitude, pos.longitude);
            final shouldUpdate =
                _conductorPos == null ||
                _conductorPos!.latitude != newPos.latitude ||
                _conductorPos!.longitude != newPos.longitude;
            if (shouldUpdate) {
              setState(() {
                _conductorPos = newPos;
                _loading = false;
              });

              // Recalcular ruta si:
              // 1) Es la primera vez (_lastRouteFetchPosition es null)
              // 2) Se movió más de 20 metros desde la última vez que se calculó la ruta
              final shouldFetchRoute =
                  _lastRouteFetchPosition == null ||
                  _calculateDistance(newPos, _lastRouteFetchPosition!) > 20;

              if (shouldFetchRoute && !_routeLoading) {
                _lastRouteFetchPosition = newPos;
                _fetchRoute();
              }
              // No enviar ubicación aquí, ya lo hace el timer cada 2 minutos
            }
          });
    } catch (e) {
      print('Error al obtener ubicación: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _sendLocationToBackend(double lat, double lon) async {
    try {
      final response = await _locationService.sendLocation(
        latitud: lat,
        longitud: lon,
      );

      // Verificar que el widget siga montado antes de usar el context
      if (!mounted) return;

      if (response != null) {
        print('id_orden_actual recibido: ${response['id_orden_actual']}');
        if (response['id_orden_actual'] != null) {
          // Mostrar el popup para aceptar/rechazar
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Nueva orden asignada'),
              content: Text(
                '¿Deseas aceptar la orden #${response['id_orden_actual']}?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Acción de rechazar (puedes agregar lógica aquí)
                  },
                  child: const Text('Rechazar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Acción de aceptar (puedes agregar lógica aquí)
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Error al enviar ubicación: $e');
    }
  }

  Future<void> _fetchRoute() async {
    if (_conductorPos == null || !mounted) return;

    final LatLng destino;
    if (widget.toRestaurante) {
      // Primera fase: ir al restaurante
      destino = LatLng(
        ApiConfig.restauranteLatitud,
        ApiConfig.restauranteLongitud,
      );
    } else if (widget.toLocal) {
      // Segunda fase: ir al local de la orden
      destino = LatLng(
        widget.pedido.ubicacionLocal.latitud,
        widget.pedido.ubicacionLocal.longitud,
      );
    } else {
      // Tercera fase: ir al cliente
      destino = LatLng(
        widget.pedido.ubicacionCliente.latitud,
        widget.pedido.ubicacionCliente.longitud,
      );
    }

    // Centrar el mapa cuando se obtiene la ruta
    try {
      if (_conductorPos != null && mounted) {
        _centrarMapaEntrePuntos(_conductorPos!, destino);
      }
    } catch (e) {
      print('Error al centrar mapa: $e');
    }

    if (!mounted) return;
    setState(() => _routeLoading = true);

    try {
      final result = await RouteUtils.getRoute(_conductorPos!, destino);
      if (!mounted) return;

      setState(() {
        _routePoints = result.points;
        _routeDistance = result.distance;
        _routeDuration = result.duration;
        _routeLoading = false;
      });

      if (widget.onRouteInfo != null) {
        widget.onRouteInfo!(result.distance, result.duration);
      }
    } catch (e) {
      print('Error al obtener ruta: $e');
      if (!mounted) return;

      setState(() => _routeLoading = false);
      if (widget.onRouteInfo != null) {
        widget.onRouteInfo!(null, null);
      }
    }
  }

  // Calcula la distancia en metros entre dos puntos usando la fórmula de Haversine
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros
    final double lat1Rad = point1.latitude * (math.pi / 180);
    final double lat2Rad = point2.latitude * (math.pi / 180);
    final double deltaLat =
        (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLng =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = LatLng(
      widget.pedido.ubicacionLocal.latitud,
      widget.pedido.ubicacionLocal.longitud,
    );
    final cliente = LatLng(
      widget.pedido.ubicacionCliente.latitud,
      widget.pedido.ubicacionCliente.longitud,
    );

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Tarjeta de información de contacto (visible en fase cliente)
        if (widget.toCliente &&
            (widget.pedido.nombreContacto != null ||
                widget.pedido.comentario != null))
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.pedido.nombreContacto != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.pedido.nombreContacto!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.pedido.comentario != null) ...[
                  if (widget.pedido.nombreContacto != null)
                    const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.comment, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.pedido.comentario!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _conductorPos ?? local,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.chatbot_lucerito',
              ),
              if (_routeLoading)
                const Center(child: CircularProgressIndicator()),
              if (_routePoints != null && _routePoints!.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      color: Colors.blueAccent,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Marcador del restaurante (siempre visible)
                  Marker(
                    width: 60,
                    height: 60,
                    point: LatLng(
                      ApiConfig.restauranteLatitud,
                      ApiConfig.restauranteLongitud,
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.orange,
                      size: 36,
                    ),
                  ),
                  // Marcador del local (visible solo en fase local, no en cliente)
                  if (widget.toLocal && !widget.toCliente)
                    Marker(
                      width: 60,
                      height: 60,
                      point: local,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                  // Marcador del cliente (visible solo en fase cliente)
                  if (widget.toCliente)
                    Marker(
                      width: 60,
                      height: 60,
                      point: LatLng(
                        widget.pedido.ubicacionCliente.latitud,
                        widget.pedido.ubicacionCliente.longitud,
                      ),
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  // Marcador del conductor (siempre visible)
                  if (_conductorPos != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: _conductorPos!,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.green,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Espacio para menú inferior
        SizedBox(height: 8),
      ],
    );
  }
}
