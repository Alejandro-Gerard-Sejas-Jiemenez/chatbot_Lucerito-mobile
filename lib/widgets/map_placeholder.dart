import 'package:flutter/material.dart';
import '../styles/app_colors.dart';

class MapPlaceholder extends StatelessWidget {
  final double height;
  const MapPlaceholder({Key? key, this.height = 220}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // grid painter
            CustomPaint(
              size: Size.infinite,
              painter: _GridPainter(),
            ),

            // simulated destination pin (top-right-ish)
            const Positioned(
              right: 36,
              top: 30,
              child: _DestPin(),
            ),

            // simulated vehicle marker (bottom-left-ish)
            const Positioned(
              left: 40,
              bottom: 30,
              child: _VehicleMarker(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestPin extends StatelessWidget {
  const _DestPin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
      ),
      child: Icon(Icons.location_on_outlined, color: Colors.red.shade400, size: 20),
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
      ),
      child: const Icon(Icons.navigation, color: Colors.white, size: 24),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
