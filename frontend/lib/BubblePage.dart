import 'package:flutter/material.dart';
import 'dart:math' as math;

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _wobbleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Movement animation from left to right
    _moveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Scale animation: start small, grow, then shrink
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1), // Start small, grow to full size
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.2), // Shrink back to small
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Wobble animation for blob effect
    _wobbleAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_isAnimating) {
      setState(() {
        _isAnimating = true;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Page'),
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startAnimation,
                  child: const Text("Move Bubble"),
                ),
              ],
            ),
          ),

          // Animated bubble blob
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Base size of the blob
              const double baseSize = 100.0;
              // Scale the size based on animation
              final double animatedSize = baseSize * _scaleAnimation.value;

              // Calculate position
              final double leftStart = 20.0; // Align with left storage can
              final double leftEnd = screenSize.width - 20.0 - animatedSize; // Align with right storage can
              final double left = leftStart + _moveAnimation.value * (leftEnd - leftStart);

              // Vertical position: start at bottom, rise, then descend
              const double bottomOffset = 20.0 + 60.0; // Align with storage can height
              final double topStart = screenSize.height - bottomOffset - animatedSize;
              final double top = topStart - math.sin(_moveAnimation.value * math.pi) * 600; // Arc motion

              return _isAnimating
                  ? Positioned(
                      left: left,
                      top: top,
                      child: BubbleBlob(
                        size: animatedSize,
                        wobbleValue: _wobbleAnimation.value,
                        color: Colors.blue.withOpacity(0.7),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Bottom left storage can icon
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _startAnimation,
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

class BubbleBlob extends StatelessWidget {
  final double size;
  final double wobbleValue;
  final Color color;

  const BubbleBlob({
    Key? key,
    required this.size,
    required this.wobbleValue,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BubbleBlobPainter(
          color: color,
          wobbleValue: wobbleValue,
        ),
      ),
    );
  }
}

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
    final double radius = size.width / 2;

    final Path path = Path();

    // Create a blob shape with some wobble
    for (double angle = 0; angle < 2 * math.pi; angle += 0.1) {
      final double wobbleAmount = math.sin(angle * 4 + wobbleValue) * 0.1;
      final double currRadius = radius * (1 + wobbleAmount);

      final double x = centerX + currRadius * math.cos(angle);
      final double y = centerY + currRadius * math.sin(angle);

      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleBlobPainter oldDelegate) {
    return oldDelegate.wobbleValue != wobbleValue || oldDelegate.color != color;
  }
}

class StorageCanIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const StorageCanIcon({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: StorageCanPainter(color: color),
      ),
    );
  }
}

class StorageCanPainter extends CustomPainter {
  final Color color;

  StorageCanPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double width = size.width;
    final double height = size.height;

    // Draw the can body (rectangle)
    canvas.drawRect(
      Rect.fromLTRB(0, height * 0.1, width, height),
      paint,
    );

    // Draw the can lid (oval at top)
    canvas.drawOval(
      Rect.fromLTRB(0, 0, width, height * 0.2),
      paint,
    );

    // Draw horizontal lines on can (like ridges)
    for (int i = 1; i <= 3; i++) {
      double y = height * (0.1 + i * 0.2);
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}