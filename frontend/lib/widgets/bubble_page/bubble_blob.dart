import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:frontend/widgets/bubble_page/painters/bubble_blob_painter.dart';
import 'package:frontend/widgets/bubble_page/painters/sound_wave_painter.dart';
import 'package:frontend/widgets/bubble_page/scrolling_text_wheel.dart';

class BubbleBlob extends StatelessWidget {
  final double size;
  final double wobbleValue;
  final Color color;
  final String text;

  const BubbleBlob({
    Key? key,
    required this.size,
    required this.wobbleValue,
    required this.color,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showText = size > 150;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          if (size > 100)
            Container(
              width: size * 1.1,
              height: size * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: BubbleBlobPainter(
              color: color,
              wobbleValue: wobbleValue,
            ),
          ),
          if (showText)
            Positioned.fill(
              child: CustomPaint(
                painter: SoundWavePainter(
                  color: Colors.white.withOpacity(0.2),
                  waveCount: 3,
                  animationValue: wobbleValue,
                ),
              ),
            ),
          if (showText)
            Positioned.fill(
              child: Center(
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      height: size * 0.7,
                      width: size * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: ScrollingTextWheel(
                        sampleText: text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showText)
            Positioned(
              top: 10,
              right: 10,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 