import 'package:flutter/material.dart';
// Add this import if StorageCanIcon is in another file
import 'BubblePage.dart';

class Ballonpage extends StatefulWidget {
  const Ballonpage({super.key});

  @override
  State<Ballonpage> createState() => _BallonpageState();
}

class _BallonpageState extends State<Ballonpage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ballon Page'),
      ),
      body: Stack(
        children: [
          // Balloon animation above the left can
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: 20,
                bottom: 80, // just above the can
                child: BalloonFillAnimation(
                  progress: _controller.value,
                  maxHeight: MediaQuery.of(context).size.height - 150,
                ),
              );
            },
          ),
          // Bottom left storage can icon
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                _controller.reset();
                _controller.forward();
              },
              child: StorageCanIcon(
                width: 40,
                height: 60,
                color: Colors.blueGrey,
              ),
            ),
          ),
          // Bottom right storage can icon
          Positioned(
            right: 20,
            bottom: 20,
            child: StorageCanIcon(
              width: 40,
              height: 60,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// Balloon animation widget
class BalloonFillAnimation extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double maxHeight;

  const BalloonFillAnimation({
    super.key,
    required this.progress,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double minHeight = 40;
    final double maxBalloonHeight = maxHeight * 0.6; // Top half
    final double minWidth = 20;
    final double maxWidth = 180;

    double balloonHeight, balloonWidth, pinchPhase, verticalOffset;

    if (progress < 0.5) {
      // Phase 1: Grow vertically
      final grow = progress / 0.5;
      balloonHeight = minHeight + (maxBalloonHeight - minHeight) * grow;
      balloonWidth = minWidth + (maxWidth - minWidth) * 0.2 * grow; // Slight width increase
      pinchPhase = 1.0; // Pinched
      verticalOffset = 0.0;
    } else {
      // Phase 2: Shrink from bottom, expand width, move up, become oval
      final phase = (progress - 0.5) / 0.5;
      balloonHeight = maxBalloonHeight - (maxBalloonHeight - minHeight) * 0.7 * phase;
      balloonWidth = minWidth + (maxWidth - minWidth) * (0.2 + 0.8 * phase);
      pinchPhase = 1.0 - phase; // Goes to round
      verticalOffset = (maxHeight * 0.4) * phase + 20; // Move up
    }

    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: Transform.translate(
        offset: Offset(0, -verticalOffset),
        child: CustomPaint(
          painter: BalloonPainter(
            width: balloonWidth,
            height: balloonHeight,
            pinchPhase: pinchPhase,
          ),
        ),
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  final double width;
  final double height;
  final double pinchPhase; // 1 = pinched, 0 = round

  BalloonPainter({
    required this.width,
    required this.height,
    required this.pinchPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    // Pinch: 1.0 (pinched) to 0.0 (round)
    final double pinch = 0.7 * pinchPhase + 0.3 * (1 - pinchPhase);
    final double pinchWidth = width * pinch;

    final path = Path();
    // Bottom center (pinch point)
    path.moveTo(size.width / 2, size.height);

    // If fully round, make the bottom round as well
    if (pinchPhase <= 0.01) {
      path.addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height - height / 2),
        width: width,
        height: height,
      ));
    } else {
      // Left curve: pinch at bottom, round at top
      path.cubicTo(
        size.width / 2 - pinchWidth / 2, size.height - height * 0.15,
        size.width / 2 - width / 2, size.height - height * 0.7,
        size.width / 2, size.height - height,
      );
      // Right curve: mirror of left
      path.cubicTo(
        size.width / 2 + width / 2, size.height - height * 0.7,
        size.width / 2 + pinchWidth / 2, size.height - height * 0.15,
        size.width / 2, size.height,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) {
    return oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.pinchPhase != pinchPhase;
  }
}