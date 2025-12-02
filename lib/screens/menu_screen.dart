import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../services/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/pedido.dart';
import 'dart:async';
import '../utils/location_helper.dart';
import '../widgets/menu/menu_header.dart';
import '../widgets/menu/stat_card.dart';
import '../widgets/menu/assigned_orders_list.dart';
import '../widgets/menu/completed_orders_list.dart';
import '../widgets/menu/order_popup.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _pollingTimer;
  Pedido? _ultimoPedidoMostrado;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _startPolling();
    LocationHelper.printCurrentLocation();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final deliveryId = prefs.getInt('user_id'); // Asegúrate de guardar el id al hacer login
      if (deliveryId == null) return;
      final orders = await _orderService.getOrdersByDelivery(deliveryId);
      if (orders.isNotEmpty) {
        final pedido = Pedido.fromJson(orders.first);
        if (_ultimoPedidoMostrado == null || pedido.id != _ultimoPedidoMostrado?.id) {
          _ultimoPedidoMostrado = pedido;
          if (mounted) {
            _mostrarPopupPedido(pedido);
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

  void _mostrarPopupPedido(Pedido pedido) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderPopup(pedido: pedido),
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


