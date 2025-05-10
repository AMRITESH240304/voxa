import 'package:flutter/material.dart';
import 'dart:math' as math;

class BubbleBlobPainter extends CustomPainter {
  final Color color;
  final double wobbleValue;

  BubbleBlobPainter({required this.color, required this.wobbleValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radiusX = size.width / 2;
    final double radiusY = size.height / 2 * 0.6;

    final Path path = Path();

    for (double angle = 0; angle < 2 * math.pi; angle += 0.05) {
      final double wobble = 1 + math.sin(angle * 4 + wobbleValue) * 0.08;
      final double x = centerX + radiusX * math.cos(angle) * wobble;
      final double y = centerY + radiusY * math.sin(angle) * wobble;

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
    
    // Add inner highlight for depth
    final Paint highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
        center: Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: radiusX))
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant BubbleBlobPainter oldDelegate) {
    return oldDelegate.wobbleValue != wobbleValue || oldDelegate.color != color;
  }
} 