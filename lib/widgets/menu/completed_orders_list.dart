import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/order_card.dart';

class CompletedOrdersList extends StatelessWidget {
  const CompletedOrdersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text('Pedidos Completados Hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ...completedToday.map((o) => Column(
              children: [
                OrderCard(
                  title: o.client,
                  subtitle: o.address,
                  meta: '${o.etaMinutes} min · ${o.items.length} items · Bs ${o.total.toStringAsFixed(0)}',
                  status: o.status,
                ),
                const SizedBox(height: 12),
              ],
            )),
      ],
    );
  }
}
