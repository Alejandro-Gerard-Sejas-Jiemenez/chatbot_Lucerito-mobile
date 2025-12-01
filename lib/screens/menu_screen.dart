import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../services/pedido_service.dart';
import '../data/mock_data.dart';
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
    MockOrder? _ultimoPedidoMostrado;
  final PedidoService _pedidoService = PedidoService();

  @override
  void initState() {
    super.initState();
    _startPolling();
    LocationHelper.printCurrentLocation();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final pedido = await _pedidoService.getPedidoAsignado();
      if (pedido != null && pedido.id != _ultimoPedidoMostrado?.id) {
        _ultimoPedidoMostrado = pedido;
        if (mounted) {
          _mostrarPopupPedido(pedido);
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _mostrarPopupPedido(MockOrder pedido) {
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


