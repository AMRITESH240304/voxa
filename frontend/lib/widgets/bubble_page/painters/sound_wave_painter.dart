import 'package:flutter/material.dart';
import 'dart:math' as math;

class SoundWavePainter extends CustomPainter {
  final Color color;
  final int waveCount;
  final double animationValue;
  
  SoundWavePainter({
    required this.color,
    required this.waveCount,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    for (int i = 0; i < waveCount; i++) {
      final double waveRadius = (size.width / 2) * (0.5 + (i * 0.15));
      final double wavePhase = animationValue + (i * math.pi / waveCount);
      
      final Paint wavePaint = Paint()
        ..color = color.withOpacity(0.3 - (i * 0.05))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      final Path wavePath = Path();
      
      for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
        final double amplitude = 5.0 + (i * 2.0);
        final double wave = amplitude * math.sin(6 * angle + wavePhase);
        final double x = centerX + (waveRadius + wave) * math.cos(angle);
        final double y = centerY + (waveRadius + wave) * math.sin(angle);
        
        if (angle == 0) {
          wavePath.moveTo(x, y);
        } else {
          wavePath.lineTo(x, y);
        }
      }
      
      wavePath.close();
      canvas.drawPath(wavePath, wavePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant SoundWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.color != color || 
           oldDelegate.waveCount != waveCount;
  }
} 