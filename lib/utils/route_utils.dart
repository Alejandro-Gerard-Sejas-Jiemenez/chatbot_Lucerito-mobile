import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distance; // en metros
  final double duration; // en segundos
  RouteResult({required this.points, required this.distance, required this.duration});
}

class RouteUtils {
  /// Obtiene la ruta siguiendo calles entre dos puntos usando OSRM (API pública demo)
  /// Devuelve puntos, distancia (m) y duración (s)
  static Future<RouteResult> getRoute(LatLng start, LatLng end) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;
      final points = coords.map<LatLng>((c) => LatLng(c[1] as double, c[0] as double)).toList();
      final distance = (route['distance'] as num).toDouble();
      final duration = (route['duration'] as num).toDouble();
      return RouteResult(points: points, distance: distance, duration: duration);
    } else {
      throw Exception('No se pudo obtener la ruta');
    }
  }
}
