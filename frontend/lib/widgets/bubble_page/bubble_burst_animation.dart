import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleBurstPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final List<Offset> particles;
  
  BubbleBurstPainter({
    required this.animationValue,
    required this.color,
    required this.particles,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(math.max(0, 1 - animationValue * 1.5))
      ..style = PaintingStyle.fill;
    
    // Draw exploding particles
    for (int i = 0; i < particles.length; i++) {
      final double particleSize = size.width * 0.1 * (1 - animationValue);
      final Offset particlePosition = Offset(
        particles[i].dx * animationValue * size.width,
        particles[i].dy * animationValue * size.height,
      );
      
      final Offset center = Offset(size.width / 2, size.height / 2);
      final Offset position = center + particlePosition;
      
      canvas.drawCircle(position, particleSize, paint);
    }
    
    // Draw shrinking main bubble
    if (animationValue < 0.5) {
      final double mainBubbleSize = size.width * (1 - animationValue * 2) * 0.5;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        mainBubbleSize,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(BubbleBurstPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class BubbleBurst extends StatelessWidget {
  final double size;
  final double animationValue;
  final Color color;
  
  BubbleBurst({
    Key? key,
    required this.size,
    required this.animationValue,
    required this.color,
  }) : super(key: key);
  
  // Generate random particle directions
  final List<Offset> particles = List.generate(
    20,
    (index) => Offset(
      math.cos(index * math.pi / 10) * (0.5 + math.Random().nextDouble() * 0.5),
      math.sin(index * math.pi / 10) * (0.5 + math.Random().nextDouble() * 0.5),
    ),
  );
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: BubbleBurstPainter(
          animationValue: animationValue,
          color: color,
          particles: particles,
        ),
      ),
    );
  }
}