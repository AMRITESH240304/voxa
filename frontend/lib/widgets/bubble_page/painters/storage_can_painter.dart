import 'package:flutter/material.dart';

class StorageCanPainter extends CustomPainter {
  final Color color;
  final List<Color> colorLayers;

  StorageCanPainter({
    required this.color, 
    this.colorLayers = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple
    ],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double cornerRadius = width * 0.15;
    
    // Draw can shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final RRect shadowRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(2, height * 0.1 + 2, width - 2, height - 2),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
      bottomLeft: Radius.circular(cornerRadius),
      bottomRight: Radius.circular(cornerRadius),
    );
    
    canvas.drawRRect(shadowRRect, shadowPaint);
    
    // Body with gradient and rounded corners
    final RRect bodyRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, height * 0.1, width, height),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
      bottomLeft: Radius.circular(cornerRadius),
      bottomRight: Radius.circular(cornerRadius),
    );
    
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withOpacity(0.8),
          Colors.grey[800]!.withOpacity(0.6),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTRB(0, height * 0.1, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bodyRRect, bodyPaint);
    
    // Add metallic rim at top
    final Paint rimPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey[300]!,
          Colors.grey[600]!,
          Colors.grey[400]!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, height * 0.08, width, height * 0.15));
    
    final RRect rimRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, height * 0.08, width, height * 0.15),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
    );
    
    canvas.drawRRect(rimRRect, rimPaint);

    // Draw color layers with rounded corners and glow
    if (colorLayers.isNotEmpty) {
      final double layerHeight = (height * 0.85) / (colorLayers.length > 0 ? colorLayers.length : 1);
      final double layerPadding = width * 0.08;
      
      for (int i = 0; i < colorLayers.length; i++) {
        final double layerTop = height * 0.15 + i * layerHeight;
        
        // Layer glow
        final Paint glowPaint = Paint()
          ..color = colorLayers[i].withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        
        final RRect glowRRect = RRect.fromRectAndCorners(
          Rect.fromLTRB(
            layerPadding - 2,
            layerTop - 2,
            width - layerPadding + 2,
            layerTop + layerHeight - 2,
          ),
          topLeft: Radius.circular(layerHeight * 0.2),
          topRight: Radius.circular(layerHeight * 0.2),
          bottomLeft: Radius.circular(layerHeight * 0.2),
          bottomRight: Radius.circular(layerHeight * 0.2),
        );
        
        canvas.drawRRect(glowRRect, glowPaint);
        
        // Main layer
        final RRect layerRRect = RRect.fromRectAndCorners(
          Rect.fromLTRB(
            layerPadding,
            layerTop,
            width - layerPadding,
            layerTop + layerHeight - 4,
          ),
          topLeft: Radius.circular(layerHeight * 0.2),
          topRight: Radius.circular(layerHeight * 0.2),
          bottomLeft: Radius.circular(layerHeight * 0.2),
          bottomRight: Radius.circular(layerHeight * 0.2),
        );
        
        final Paint layerPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorLayers[i].withOpacity(1.0),
              colorLayers[i].withOpacity(0.8),
            ],
          ).createShader(layerRRect.outerRect);
        
        canvas.drawRRect(layerRRect, layerPaint);
        
        // Add shine effect to each layer
        final Paint shinePaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.0),
            ],
          ).createShader(layerRRect.outerRect);
        
        // Draw a smaller rounded rectangle for the shine
        final RRect shineRRect = RRect.fromRectAndCorners(
          Rect.fromLTRB(
            layerPadding + 2,
            layerTop + 2,
            width - layerPadding - width * 0.3,
            layerTop + layerHeight * 0.5,
          ),
          topLeft: Radius.circular(layerHeight * 0.2),
          topRight: Radius.circular(layerHeight * 0.2),
          bottomLeft: Radius.circular(layerHeight * 0.2),
          bottomRight: Radius.circular(layerHeight * 0.2),
        );
        
        canvas.drawRRect(shineRRect, shinePaint);
      }
    }
    
    // Add highlight reflection on the can
    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(bodyRRect.outerRect);
    
    // Draw a smaller rounded rectangle for the highlight
    final RRect highlightRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        width * 0.1,
        height * 0.15,
        width * 0.4,
        height * 0.9,
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