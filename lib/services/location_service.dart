import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LocationService {
  Future<Map<String, dynamic>?> pollCurrentOrderWithDummyLocation({
    double latitud = 0.0,
    double longitud = 0.0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print('No hay token disponible para consultar ubicación/orden');
      return null;
    }
    final userId = _authService.getUserIdFromToken(token);
    if (userId == null) {
      print('No se pudo extraer el id del usuario del token');
      return null;
    }
    final url = Uri.parse('$baseUrl/usuarios/$userId/ubicacion');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitud': latitud, 'longitud': longitud}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('Error al consultar ubicación/orden: ${response.body}');
      return null;
    }
  }

  final String baseUrl;
  final AuthService _authService = AuthService();
  LocationService({required this.baseUrl});

  Future<Map<String, dynamic>?> sendLocation({
    required double latitud,
    required double longitud,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print('No hay token disponible para enviar ubicación');
      return null;
    }
    final userId = _authService.getUserIdFromToken(token);
    if (userId == null) {
      print('No se pudo extraer el id del usuario del token');
      return null;
    }
    print('Enviando ubicación para userId: $userId');
    final url = Uri.parse('$baseUrl/usuarios/$userId/ubicacion');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitud': latitud, 'longitud': longitud}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('Error al enviar ubicación: ${response.body}');
      return null;
    }
  }
}
