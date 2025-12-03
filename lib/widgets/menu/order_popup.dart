
import 'package:flutter/material.dart';
import '../../data/models/pedido.dart';
import '../../screens/mapa_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class OrderPopup extends StatelessWidget {
  final Pedido pedido;
  const OrderPopup({Key? key, required this.pedido}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 18, top: 8),
      title: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFF9A825), size: 36),
          ),
          const SizedBox(height: 16),
          Text('¡Nuevo pedido asignado!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF222222))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.confirmation_number, color: Color(0xFF757575), size: 20),
              const SizedBox(width: 8),
              Text('ID: ${pedido.id}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Color(0xFF757575), size: 20),
              const SizedBox(width: 8),
              Text(pedido.usuario.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFF43A047), size: 20),
              const SizedBox(width: 8),
              Text('Bs ${pedido.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF1976D2), size: 20),
              const SizedBox(width: 8),
              Text(pedido.estado, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),
          const Text('¿Aceptar la entrega?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF757575),
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // Obtener el deliveryId desde el token guardado
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('jwt_token');
                  int? deliveryId;
                  if (token != null) {
                    deliveryId = AuthService().getUserIdFromToken(token);
                  }
                  if (deliveryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo obtener el ID del delivery')),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                  final url = Uri.parse('${ApiConfig.baseUrl}/orden/${pedido.id}/rechazar');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'delivery_id': deliveryId,
                      'comentario': 'Orden rechazada por el delivery',
                    }),
                  );
                  Navigator.of(context).pop();
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Orden rechazada exitosamente')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al rechazar la orden: ${response.body}')),
                    );
                  }
                },
                child: const Text('No aceptar', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () async {
                  // Actualizar estado de la orden a 'completada' antes de procesar
                  final estadoUrl = Uri.parse('${ApiConfig.baseUrl}/orden/${pedido.id}/estado');
                  final estadoResponse = await http.put(
                    estadoUrl,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'estado': 'pendiente'}),
                  );
                  if (estadoResponse.statusCode == 200) {
                    // Obtener ubicación actual del cliente
                    double latitudCliente = 0.0;
                    double longitudCliente = 0.0;
                    // Si tienes un LocationHelper, úsalo aquí
                    // Ejemplo:
                    // final position = await LocationHelper.getCurrentPosition();
                    // latitudCliente = position?.latitude ?? 0.0;
                    // longitudCliente = position?.longitude ?? 0.0;

                    final url = Uri.parse('${ApiConfig.baseUrl}/orden/${pedido.id}/procesar');
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'latitud_cliente': latitudCliente,
                        'longitud_cliente': longitudCliente,
                      }),
                    );
                    Navigator.of(context).pop();
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Orden aceptada y procesada exitosamente')),
                      );
                      // Puedes navegar al mapa o refrescar la UI aquí
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MapaScreen(pedido: pedido),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al procesar la orden: ${response.body}')),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                    String errorMsg = 'Error al actualizar estado';
                    try {
                      final errorJson = jsonDecode(estadoResponse.body);
                      if (errorJson is Map && errorJson.containsKey('error')) {
                        errorMsg = errorJson['error'];
                      } else {
                        errorMsg = estadoResponse.body;
                      }
                    } catch (_) {
                      errorMsg = estadoResponse.body;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMsg)),
                    );
                  }
                },
                child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
