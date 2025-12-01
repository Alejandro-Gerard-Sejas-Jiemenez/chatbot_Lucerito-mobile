import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/models/pedido.dart';
import '../../data/models/usuario.dart';
import '../../data/models/ubicacion.dart';
import '../../screens/mapa_screen.dart';

class OrderPopup extends StatelessWidget {
  final MockOrder pedido;
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
              const Icon(Icons.person_outline, color: Color(0xFF757575), size: 20),
              const SizedBox(width: 8),
              Text(pedido.client, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              Text(pedido.status, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15)),
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
                onPressed: () => Navigator.of(context).pop(),
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
                onPressed: () {
                  Navigator.of(context).pop();
                  // Crear ubicaciones de ejemplo para el local y el cliente
                  final pedido = Pedido(
                    id: int.tryParse(this.pedido.id) ?? 0,
                    usuario: Usuario(
                      id: 1,
                      nombre: this.pedido.client,
                      correo: '',
                      telefono: this.pedido.phone,
                      direccion: this.pedido.address,
                    ),
                    productos: [],
                    total: this.pedido.total,
                    estado: this.pedido.status,
                    ubicacionLocal: Ubicacion(latitud: -17.783327, longitud: -63.18213), // Ejemplo SCZ centro
                    ubicacionCliente: Ubicacion(latitud: -17.789, longitud: -63.180), // Ejemplo cercano
                  );
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => MapaScreen(pedido: pedido),
                  ));
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
