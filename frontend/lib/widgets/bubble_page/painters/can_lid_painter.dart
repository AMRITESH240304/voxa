import 'package:flutter/material.dart';

class CanLidPainter extends CustomPainter {
  CanLidPainter();
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double cornerRadius = width * 0.1;
    
    // Draw lid shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final RRect shadowRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(2, 2, width - 2, height - 2),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
      bottomLeft: Radius.circular(cornerRadius),
      bottomRight: Radius.circular(cornerRadius),
    );
    
    canvas.drawRRect(shadowRRect, shadowPaint);
    
    // Main lid with gradient
    final RRect lidRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, 0, width, height),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
      bottomLeft: Radius.circular(cornerRadius),
      bottomRight: Radius.circular(cornerRadius),
    );
    
    final Paint lidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[400]!,
          Colors.grey[600]!,
          Colors.grey[500]!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, 0, width, height));
    
    canvas.drawRRect(lidRRect, lidPaint);
    
    // Add highlight reflection on the lid
    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(lidRRect.outerRect);
    
    // Draw a smaller rounded rectangle for the highlight
    final RRect highlightRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        width * 0.1,
        height * 0.1,
        width * 0.6,
        height * 0.6,
      ),
      topLeft: Radius.circular(cornerRadius * 0.8),
      topRight: Radius.circular(cornerRadius * 0.8),
      bottomLeft: Radius.circular(cornerRadius * 0.8),
      bottomRight: Radius.circular(cornerRadius * 0.8),
    );
    
    canvas.drawRRect(highlightRRect, highlightPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 