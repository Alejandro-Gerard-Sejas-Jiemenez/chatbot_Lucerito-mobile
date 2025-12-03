
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  final String baseUrl = ApiConfig.baseUrl;

  // Obtiene la orden asignada al delivery (puedes filtrar por estado en Flutter)
  Future<List<dynamic>> getOrdersByDelivery(int deliveryId) async {
    final url = Uri.parse('$baseUrl/orden/usuario/$deliveryId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  // Rechaza una orden asignada
  Future<bool> rejectOrder(int ordenCod, dynamic deliveryId) async {
    final url = Uri.parse('$baseUrl/orden/$ordenCod/rechazar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'delivery_id': deliveryId}),
    );
    return response.statusCode == 200;
  }

  // Obtiene los detalles de una orden específica por su ID
  Future<Map<String, dynamic>?> getOrderById(int ordenId) async {
    final url = Uri.parse('$baseUrl/orden/$ordenId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error al obtener orden: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener orden: $e');
      return null;
    }
  }


    Future<Map<String, double>?> obtenerUbicacionOrden(int idOrden) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/orden/$idOrden/ubicacion');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'latitud': (data['latitud'] as num).toDouble(),
        'longitud': (data['longitud'] as num).toDouble(),
      };
    }
    return null;
  }
}
