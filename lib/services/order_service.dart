import 'dart:convert';
import 'package:chatbot_lucerito/data/models/traking.dart';
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

  // Rechaza una orden asignada y automáticamente la reasigna
  Future<bool> rejectOrder(int ordenCod, dynamic deliveryId) async {
    print('Rechazando orden #$ordenCod para delivery $deliveryId');
    final url = Uri.parse('$baseUrl/orden/$ordenCod/rechazar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'delivery_id': deliveryId}),
    );

    if (response.statusCode == 200) {
      print('Orden rechazada exitosamente, procediendo a reasignar...');
      // Llamar automáticamente a reasignar después de rechazar
      final reassigned = await reassignOrder(ordenCod);
      if (reassigned) {
        print('Orden #$ordenCod reasignada exitosamente');
      } else {
        print('Advertencia: Orden rechazada pero falló la reasignación');
      }
      return true;
    }

    print('Error al rechazar orden #$ordenCod');
    return false;
  }

  // Reasignar una orden a otro delivery
  Future<bool> reassignOrder(int ordenCod) async {
    final url = Uri.parse('$baseUrl/orden/$ordenCod/reasignar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    return response.statusCode == 200;
  }

  // Crear Traking para una orden y devuelve el ID del tracking creado
  Future<int?> createTracking(Traking trackingData) async {
    final url = Uri.parse('$baseUrl/tracking/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trackingData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Extraer el ID desde responseData['tracking']['id']
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('tracking') &&
            responseData['tracking'] is Map<String, dynamic>) {
          final tracking = responseData['tracking'] as Map<String, dynamic>;
          if (tracking.containsKey('id')) {
            final trackingId = tracking['id'] as int;
            print('Tracking creado exitosamente con ID: $trackingId');
            return trackingId;
          }
        }
        print('Tracking creado pero no se pudo obtener el ID de la respuesta');
        print('Respuesta del servidor: $responseData');
        return null;
      } else {
        print('Error al crear tracking: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al crear tracking: $e');
      return null;
    }
  }

  // Actualizar Traking para una orden y devuelve el ID del tracking actualizado
  Future<int?> updateTracking(Traking trackingData) async {
    final url = Uri.parse('$baseUrl/tracking/${trackingData.id}');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trackingData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Extraer el ID desde responseData['tracking']['id']
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('tracking') &&
            responseData['tracking'] is Map<String, dynamic>) {
          final tracking = responseData['tracking'] as Map<String, dynamic>;
          if (tracking.containsKey('id')) {
            final trackingId = tracking['id'] as int;
            print('Tracking actualizado exitosamente con ID: $trackingId');
            return trackingId;
          }
        }
        print(
          'Tracking actualizado pero no se pudo obtener el ID de la respuesta',
        );
        return null;
      } else {
        print('Error al actualizar tracking: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al actualizar tracking: $e');
      return null;
    }
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

  // Obtiene latitud, longitud, nombre de contacto y comentario de la orden
  Future<Map<String, dynamic>?> obtenerUbicacionOrden(int idOrden) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/datos-envio/$idOrden/ubicacion',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La latitud y longitud están dentro del objeto 'ubicacion'
        final ubicacion = data['ubicacion'];
        if (ubicacion != null) {
          final contacto = ubicacion['contacto'];
          return {
            'latitud': (ubicacion['latitud'] as num?)?.toDouble() ?? 0.0,
            'longitud': (ubicacion['longitud'] as num?)?.toDouble() ?? 0.0,
            'nombre_contacto': contacto != null
                ? contacto['nombre_completo'] as String?
                : null,
            'comentario': contacto != null
                ? contacto['comentario'] as String?
                : null,
          };
        }
        return null;
      } else {
        print('Error al obtener ubicación: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener ubicación: $e');
      return null;
    }
  }

  // Obtiene el historial de entregas del delivery
  Future<Map<String, dynamic>?> obtenerHistorialDelivery(int deliveryId) async {
    final url = Uri.parse('$baseUrl/tracking/delivery/$deliveryId/historial');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error al obtener historial: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener historial: $e');
      return null;
    }
  }
}
