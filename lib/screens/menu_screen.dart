import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import 'order_screen.dart';
import 'login_screen.dart';
import '../styles/text_styles.dart';
import '../data/mock_data.dart';
import '../widgets/order_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

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
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4.5,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -45),
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person_outline, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                Transform.translate(
                                  offset: const Offset(0, -45),
                                  child: Text('Hola: ${currentUser.username}', style: TextStyles.title.copyWith(color: Colors.white)),
                                ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -45),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatCard(title: 'Pendientes', value: '${assignedOrders.length}'),
                      _StatCard(title: 'En Camino', value: '${assignedOrders.where((o) => o.status == "En Camino").length}'),
                      _StatCard(title: 'Hoy', value: '${completedToday.length}'),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  Text('Pedidos Asignados', style: TextStyles.title),
                  const SizedBox(height: 8),
                  // build assigned orders from mock data
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
                  const SizedBox(height: 12),
                  Text('Pedidos Completados Hoy', style: TextStyles.title),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
