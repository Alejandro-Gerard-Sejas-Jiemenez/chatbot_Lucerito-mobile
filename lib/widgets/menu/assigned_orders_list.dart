import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/order_card.dart';
import '../../screens/order_screen.dart';

class AssignedOrdersList extends StatelessWidget {
  const AssignedOrdersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Pedidos Asignados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ...assignedOrders.map((o) => Column(
              children: [
                OrderCard(
                  title: o.client,
                  subtitle: o.address,
                  meta: '${o.etaMinutes} min · ${o.items.length} items · Bs ${o.total.toStringAsFixed(0)}',
                  status: o.status,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderScreen(order: o)));
                  },
                ),
                const SizedBox(height: 12),
              ],
            )),
      ],
    );
  }
}
