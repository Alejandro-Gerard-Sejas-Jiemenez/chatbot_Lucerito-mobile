

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import '../data/models/pedido.dart';
import '../utils/route_utils.dart';

typedef RouteInfoCallback = void Function(double? distance, double? duration);

class PedidoMap extends StatefulWidget {
  final Pedido pedido;
  final RouteInfoCallback? onRouteInfo;
  final bool toCliente;

  const PedidoMap({
    Key? key,
    required this.pedido,
    this.onRouteInfo,
    this.toCliente = false,
  }) : super(key: key);

  @override
  State<PedidoMap> createState() => _PedidoMapState();
}

class _PedidoMapState extends State<PedidoMap> {
  LatLng? _conductorPos;
  bool _loading = true;
  StreamSubscription<Position>? _positionStream;

  List<LatLng>? _routePoints;
  double? _routeDistance; // metros
  double? _routeDuration; // segundos
  bool _routeLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocationStream();
  }

  void _initLocationStream() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
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
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((Position pos) {
        final newPos = LatLng(pos.latitude, pos.longitude);
        final shouldUpdate = _conductorPos == null ||
            _conductorPos!.latitude != newPos.latitude ||
            _conductorPos!.longitude != newPos.longitude;
        if (shouldUpdate) {
          setState(() {
            _conductorPos = newPos;
            _loading = false;
          });
          _fetchRoute();
        }
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchRoute() async {
    if (_conductorPos == null) return;
    final destino = widget.toCliente
        ? LatLng(widget.pedido.ubicacionCliente.latitud, widget.pedido.ubicacionCliente.longitud)
        : LatLng(widget.pedido.ubicacionLocal.latitud, widget.pedido.ubicacionLocal.longitud);
    setState(() => _routeLoading = true);
    try {
      final result = await RouteUtils.getRoute(_conductorPos!, destino);
      setState(() {
        _routePoints = result.points;
        _routeDistance = result.distance;
        _routeDuration = result.duration;
        _routeLoading = false;
      });
      if (widget.onRouteInfo != null) {
        widget.onRouteInfo!(result.distance, result.duration);
      }
    } catch (_) {
      setState(() => _routeLoading = false);
      if (widget.onRouteInfo != null) {
        widget.onRouteInfo!(null, null);
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = LatLng(widget.pedido.ubicacionLocal.latitud, widget.pedido.ubicacionLocal.longitud);
    final cliente = LatLng(widget.pedido.ubicacionCliente.latitud, widget.pedido.ubicacionCliente.longitud);

    if (_loading)
      return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _conductorPos ?? local,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
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
                  if (!widget.toCliente)
                    Marker(
                      width: 60,
                      height: 60,
                      point: local,
                      child: const Icon(Icons.store, color: Colors.blue, size: 36),
                    ),
                  if (widget.toCliente)
                    Marker(
                      width: 60,
                      height: 60,
                      point: LatLng(widget.pedido.ubicacionCliente.latitud, widget.pedido.ubicacionCliente.longitud),
                      child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 36),
                    ),
                  if (_conductorPos != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: _conductorPos!,
                      child: const Icon(Icons.directions_car, color: Colors.green, size: 36),
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
