import 'package:flutter/material.dart';
import '../data/models/pedido.dart';
import '../widgets/pedido_map.dart';
import '../widgets/map_bottom_menu.dart';

class MapaScreen extends StatefulWidget {
  final Pedido pedido;
  const MapaScreen({Key? key, required this.pedido}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  bool _arrived = false;
  double? _distance;
  double? _duration;
  bool _toCliente = false;
  bool _entregaConfirmada = false;

  void _onArrived() {
    setState(() {
      if (!_toCliente) {
        _arrived = true;
        _toCliente = true;
      } else {
        _entregaConfirmada = true;
      }
    });
    // Forzar actualización de la ruta al cliente
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {});
      if (_entregaConfirmada) {
        // Mostrar mensaje y redirigir al menú principal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Entrega confirmada al cliente!'), duration: Duration(seconds: 2)),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  void _onCancel() {
    Navigator.of(context).pop();
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
      appBar: AppBar(
        title: const Text('Mapa del Pedido'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PedidoMap(
                key: ValueKey(_toCliente),
                pedido: widget.pedido,
                onRouteInfo: _onRouteInfo,
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
                onCancel: !_toCliente ? _onCancel : null,
                arrivedEnabled: true,
                distance: _distance,
                duration: _duration,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
