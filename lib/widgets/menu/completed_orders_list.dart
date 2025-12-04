import 'package:flutter/material.dart';

class CompletedOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> historial;

  const CompletedOrdersList({Key? key, required this.historial})
    : super(key: key);

  void _mostrarDialogoMapa(BuildContext context, double lat, double lng) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubicación de entrega'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitud: $lat'),
            Text('Longitud: $lng'),
            const SizedBox(height: 12),
            const Text(
              'Copia estas coordenadas para verlas en Google Maps',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getEstadoBadge(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregada':
        return '✓ Entregada';
      case 'cancelada':
        return '✗ Cancelada';
      case 'en_camino':
        return '→ En camino';
      case 'asignada':
        return '● Asignada';
      case 'recogiendo':
        return '↻ Recogiendo';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'en_camino':
        return Colors.blue;
      case 'asignada':
        return Colors.orange;
      case 'recogiendo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 12),
          Text(
            'Pedidos Completados',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'No hay pedidos completados',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Pedidos Completados ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...historial.map((item) {
          final datosEnvio = item['datos_envio'] as Map<String, dynamic>?;
          final nombre = datosEnvio?['nombre_completo'] ?? 'Sin nombre';
          final telefono = datosEnvio?['telefono'] ?? '';
          final comentario = datosEnvio?['comentario'] as String?;
          final estado = item['estado'] ?? '';
          final ordenCod = item['orden_cod'] ?? 0;
          final lat = (item['latitud'] as num?)?.toDouble() ?? 0.0;
          final lng = (item['longitud'] as num?)?.toDouble() ?? 0.0;

          return Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: lat != 0.0 && lng != 0.0
                      ? () => _mostrarDialogoMapa(context, lat, lng)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Orden #$ordenCod',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getEstadoColor(estado).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getEstadoColor(estado),
                                ),
                              ),
                              child: Text(
                                _getEstadoBadge(estado),
                                style: TextStyle(
                                  color: _getEstadoColor(estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        if (telefono.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                telefono,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                        if (comentario != null && comentario.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.comment,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  comentario,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (lat != 0.0 && lng != 0.0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Toca para ver ubicación',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }
}
