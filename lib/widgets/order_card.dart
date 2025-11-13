import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String meta;
  final String status;
  final VoidCallback? onTap;

  const OrderCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.status,
    this.onTap,
  }) : super(key: key);

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0,2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Colors.black45),
                        const SizedBox(width: 6),
                        Text(meta, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(text: status, color: color, icon: status.toLowerCase()== 'entregado' ? Icons.check_circle : Icons.local_shipping),
                  const SizedBox(height: 8),
                  const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
