import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final double animationValue;
  
  AudioWaveformPainter({
    required this.waveformData,
    required this.color,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;
    
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final double width = size.width;
    final double height = size.height;
    final double centerY = height / 2;
    
    // Draw circular waveform
    final double radius = math.min(width, height) * 0.4;
    final Offset center = Offset(width / 2, height / 2);
    
    final Path path = Path();
    final int pointCount = waveformData.length;
    
    for (int i = 0; i < pointCount; i++) {
      final double angle = (i / pointCount) * 2 * math.pi + animationValue;
      final double amplitude = waveformData[i] * radius * 0.3;
      final double x = center.dx + (radius + amplitude) * math.cos(angle);
      final double y = center.dy + (radius + amplitude) * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Close the path to form a complete circle
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw inner circle
    final Paint circlePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8, circlePaint);
    
    // Draw outer glow
    final Paint glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(center, radius * 1.1, glowPaint);
  }
  
  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}