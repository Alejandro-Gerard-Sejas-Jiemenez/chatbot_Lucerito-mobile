import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({Key? key}) : super(key: key);

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  LatLng? _currentPosition;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Los servicios de ubicación están desactivados.';
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permiso de ubicación denegado.';
            _loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permiso de ubicación denegado permanentemente.';
          _loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error obteniendo la ubicación: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_currentPosition == null) {
      return const Center(child: Text('No se pudo obtener la ubicación.'));
    }
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 16.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWxlamFuZHJvZ2VyYXJkIiwiYSI6ImNtaW04aTU2eTF3NGMzZXB4NjYwZTZveTMifQ.mt9J6le2UKPcz6xq2nerzQ',
          additionalOptions: const {
            'accessToken': 'pk.eyJ1IjoiYWxlamFuZHJvZ2VyYXJkIiwiYSI6ImNtaW04aTU2eTF3NGMzZXB4NjYwZTZveTMifQ.mt9J6le2UKPcz6xq2nerzQ',
            'id': 'mapbox.streets',
          },
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 60.0,
              height: 60.0,
              point: _currentPosition!,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
