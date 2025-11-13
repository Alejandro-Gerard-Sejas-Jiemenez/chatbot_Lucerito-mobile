import 'package:flutter/material.dart';
import '../widgets/info_tile.dart';
import '../styles/app_colors.dart';
import '../widgets/map_placeholder.dart';
import '../data/mock_data.dart';

class OrderScreen extends StatelessWidget {
  final MockOrder order;

  const OrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14))),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 6),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pedido #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)), Text(order.client, style: const TextStyle(fontSize: 12))])),
                  const SizedBox(width: 6),
                  Chip(label: Text(order.status)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Map placeholder
            const MapPlaceholder(height: 220),

            const SizedBox(height: 12),

            // Status and info
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Order status (recovered)
                  const Text('Estado del Pedido', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.shopping_bag_outlined, color: Colors.black45),
                          title: const Text('Pedido Recogido del Restaurante'),
                          subtitle: const Text(''),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.local_shipping_outlined, color: Colors.black45),
                          title: const Text('En camino'),
                          subtitle: const Text('Viaje iniciado'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.check_circle_outline, color: Colors.black45),
                          title: const Text('Entregado'),
                          subtitle: const Text('Pedido completado'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Customer info card
                  const Text('Informacion del Cliente', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: Column(
                      children: [
                        InfoTile(icon: Icons.person, title: 'Cliente', subtitle: order.client, iconColor: AppColors.primary),
                        const SizedBox(height: 6),
                        InfoTile(icon: Icons.phone, title: 'Telefono', subtitle: order.phone, iconColor: AppColors.primary),
                        const SizedBox(height: 6),
                        InfoTile(icon: Icons.location_on, title: 'Direccion de Entrega', subtitle: order.address, iconColor: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Order details
                  const Text('Detalles del Pedido', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Articulos x${order.items.length}', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        ...order.items.map((it) => Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.circle, size: 8, color: AppColors.primary),
                                ),
                                Expanded(child: Text(it)),
                              ],
                            )),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(child: Text('Distancia', style: TextStyle(color: Colors.black54))),
                            Text('${order.distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(child: Text('Tiempo estimado', style: TextStyle(color: Colors.black54))),
                            Text('${order.etaMinutes} min', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(child: Text('Total del Pedido', style: TextStyle(fontWeight: FontWeight.w600))),
                            Text('Bs ${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Comentario del Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                          child: Text(order.comment.isNotEmpty ? order.comment : 'No hay comentarios', style: const TextStyle(color: Colors.black87)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: iniciar viaje action
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iniciar viaje')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Iniciar Viaje', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: cancelar pedido action
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancelar pedido')));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar Pedido', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
