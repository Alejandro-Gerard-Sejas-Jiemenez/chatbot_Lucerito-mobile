import 'package:flutter/material.dart';


class MapBottomMenu extends StatelessWidget {
  final VoidCallback? onArrived;
  final VoidCallback? onCancel;
  final bool arrivedEnabled;
  final double? distance; // metros
  final double? duration; // segundos
  final bool toCliente;

  const MapBottomMenu({
    Key? key,
    this.onArrived,
    this.onCancel,
    this.arrivedEnabled = true,
    this.distance,
    this.duration,
    this.toCliente = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (distance != null && duration != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions, color: Colors.blueGrey[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${(distance! / 1000).toStringAsFixed(2)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, color: Colors.blueGrey[700]),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(duration!),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!toCliente)
                ElevatedButton.icon(
                  onPressed: onArrived,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirmar llegada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (!toCliente)
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (toCliente)
                ElevatedButton.icon(
                  onPressed: onArrived,
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('Confirmar entrega al cliente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int min = (seconds / 60).floor();
    final int sec = (seconds % 60).round();
    if (min > 0) {
      return '$min min${sec > 0 ? ' $sec s' : ''}';
    } else {
      return '$sec s';
    }
  }
}
