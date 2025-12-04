import 'package:flutter/material.dart';
import '../data/models/pedido.dart';
import '../widgets/pedido_map.dart';
import '../widgets/map_bottom_menu.dart';
import '../services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/traking.dart';
import '../utils/location_helper.dart';

class MapaScreen extends StatefulWidget {
  final Pedido pedido;
  const MapaScreen({Key? key, required this.pedido}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  double? _distance;
  double? _duration;
  bool _toRestaurante = true; // Primero al restaurante
  bool _toLocal = false; // Luego al local
  bool _toCliente = false; // Finalmente al cliente
  bool _entregaConfirmada = false;
  final OrderService _orderService = OrderService();

  void _onArrived() async {
    // Guardar contexto antes de operaciones asíncronas
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Determinar qué estado actualizar en el tracking
    String nuevoEstado = '';
    if (_toRestaurante) {
      nuevoEstado = 'recogiendo';
    } else if (_toLocal) {
      nuevoEstado = 'en_camino';
    } else if (_toCliente) {
      nuevoEstado = 'entregada';
    }

    // Actualizar tracking con el nuevo estado
    if (nuevoEstado.isNotEmpty) {
      await _actualizarTracking(nuevoEstado);
    }

    setState(() {
      if (_toRestaurante) {
        // Llegó al restaurante, ahora va al local
        _toRestaurante = false;
        _toLocal = true;
      } else if (_toLocal) {
        // Llegó al local, ahora va al cliente
        _toLocal = false;
        _toCliente = true;
      } else if (_toCliente) {
        // Llegó al cliente, entrega confirmada
        _entregaConfirmada = true;
      }
    });
    // Forzar actualización de la ruta
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {});
      if (_entregaConfirmada) {
        // Mostrar mensaje y redirigir al menú principal
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('¡Entrega confirmada al cliente!'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) navigator.pop(true);
        });
      }
    });
  }

  void _onCancel() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Actualizar tracking a cancelada antes de salir
    await _actualizarTracking('cancelada');

    // Reasignar la orden a otro delivery
    print('Reasignando orden #${widget.pedido.id}...');
    final reassigned = await _orderService.reassignOrder(widget.pedido.id);

    if (reassigned) {
      print('Orden #${widget.pedido.id} reasignada exitosamente');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Orden cancelada y reasignada')),
        );
      }
    } else {
      print('Error al reasignar orden #${widget.pedido.id}');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Orden cancelada pero no se pudo reasignar'),
          ),
        );
      }
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  // Método para actualizar el tracking
  Future<void> _actualizarTracking(String nuevoEstado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackingId = prefs.getInt('tracking_id_${widget.pedido.id}');

      if (trackingId == null) {
        print('No se encontró tracking ID para la orden ${widget.pedido.id}');
        return;
      }

      // Obtener ubicación actual
      final currentPosition = await LocationHelper.getCurrentPosition();

      // Obtener el delivery ID del token
      final token = prefs.getString('jwt_token');
      if (token == null) {
        print('No se encontró token JWT');
        return;
      }

      // Extraer delivery ID del token (puedes usar AuthService si lo prefieres)
      // Por simplicidad, lo obtengo de SharedPreferences si está guardado
      final deliveryIdStr = prefs.getString('delivery_id');

      final trackingData = Traking(
        id: trackingId,
        latitud: currentPosition?.latitude.toString() ?? '0.0',
        longitud: currentPosition?.longitude.toString() ?? '0.0',
        userDeliveryID: deliveryIdStr ?? '0',
        estado: nuevoEstado,
        ordenCod: widget.pedido.id.toString(),
        comentario: 'Actualización de estado a $nuevoEstado',
      );

      print('Actualizando tracking #$trackingId a estado: $nuevoEstado');
      final result = await _orderService.updateTracking(trackingData);

      if (result != null) {
        print('Tracking actualizado exitosamente a estado: $nuevoEstado');
      } else {
        print('Error al actualizar tracking');
      }
    } catch (e) {
      print('Error al actualizar tracking: $e');
    }
  }

  void _onRouteInfo(double? distance, double? duration) {
    setState(() {
      _distance = distance;
      _duration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa del Pedido')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PedidoMap(
                key: ValueKey('$_toRestaurante-$_toLocal-$_toCliente'),
                pedido: widget.pedido,
                onRouteInfo: _onRouteInfo,
                toRestaurante: _toRestaurante,
                toLocal: _toLocal,
                toCliente: _toCliente,
              ),
            ),
          ),
          if (!_entregaConfirmada)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapBottomMenu(
                onArrived: _onArrived,
                onCancel: _toRestaurante ? _onCancel : null,
                arrivedEnabled: true,
                distance: _distance,
                duration: _duration,
                toRestaurante: _toRestaurante,
                toLocal: _toLocal,
                toCliente: _toCliente,
              ),
            ),
          if (_entregaConfirmada)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: const Center(
                  child: Text(
                    '¡Entrega confirmada al cliente!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
