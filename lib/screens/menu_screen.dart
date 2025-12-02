import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/pedido.dart';
import 'dart:async';
import '../utils/location_helper.dart';
import '../widgets/menu/menu_header.dart';
import '../widgets/menu/stat_card.dart';
import '../widgets/menu/assigned_orders_list.dart';
import '../widgets/menu/completed_orders_list.dart';
import '../widgets/menu/order_popup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _pollingTimer;
  int? _ultimoIdOrdenMostrado;
  final LocationService _locationService = LocationService(baseUrl: ApiConfig.baseUrl);

  @override
  void initState() {
    super.initState();
    _startPolling();
    LocationHelper.printCurrentLocation();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      // Puedes usar lat/lon dummy o los últimos conocidos si tienes acceso
      final response = await _locationService.pollCurrentOrderWithDummyLocation(latitud: 0.0, longitud: 0.0);
      if (response != null && response['id_orden_actual'] != null) {
        final idOrden = response['id_orden_actual'];
        if (_ultimoIdOrdenMostrado == null || idOrden != _ultimoIdOrdenMostrado) {
          _ultimoIdOrdenMostrado = idOrden;
          if (mounted) {
            _mostrarPopupOrden(idOrden);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  final OrderService _orderService = OrderService();

  void _mostrarPopupOrden(int idOrden) async {
    final prefs = await SharedPreferences.getInstance();
    final deliveryId = prefs.getInt('user_id');
    if (deliveryId == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Nueva orden asignada'),
        content: Text('¿Deseas aceptar la orden #$idOrden?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Rechazar la orden
              final success = await _orderService.rejectOrder(idOrden, deliveryId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orden rechazada exitosamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al rechazar la orden')),
                );
              }
            },
            child: const Text('Rechazar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Aceptar la orden (actualizar estado a "en camino")
              final url = Uri.parse('${ApiConfig.baseUrl}/orden/$idOrden/estado');
              final response = await http.put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'estado': 'en camino'}),
              );
              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orden aceptada exitosamente')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al aceptar la orden')),
                );
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const MenuHeader(),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      StatCard(title: 'Pendientes', value: ''),
                      StatCard(title: 'En Camino', value: ''),
                      StatCard(title: 'Hoy', value: ''),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: const [
                  AssignedOrdersList(),
                  CompletedOrdersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


