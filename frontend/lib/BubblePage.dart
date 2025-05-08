import 'package:flutter/material.dart';
import 'dart:math' as math;

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> with TickerProviderStateMixin {
  late AnimationController _upAnimationController;
  late AnimationController _downAnimationController;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _moveDownAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _wobbleUpAnimation;
  late Animation<double> _wobbleDownAnimation;
  bool _isAnimatingUp = false;
  bool _isAtCenter = false;
  bool _isAnimatingDown = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller for moving up to center
    _upAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize controller for moving down to right can
    _downAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Move up animation: from left to center
    _moveUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _upAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Move down animation: from center to right can
    _moveDownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _downAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Scale animation: start small, grow, stay at size
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _upAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Wobble animation for upward movement
    _wobbleUpAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _upAnimationController,
        curve: Curves.linear,
      ),
    );

    // Wobble animation for downward movement
    _wobbleDownAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _downAnimationController,
        curve: Curves.linear,
      ),
    );

    _upAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingUp = false;
          _isAtCenter = true;
        });
      }
    });

    _downAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingDown = false;
          _isAtCenter = false;
        });
        _downAnimationController.reset();
        _upAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _upAnimationController.dispose();
    _downAnimationController.dispose();
    super.dispose();
  }

  void _startUpAnimation() {
    if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
      setState(() {
        _isAnimatingUp = true;
      });
      _upAnimationController.forward(from: 0.0);
    }
  }

  void _startDownAnimation() {
    if (_isAtCenter && !_isAnimatingDown) {
      setState(() {
        _isAnimatingDown = true;
      });
      _downAnimationController.forward(from: 0.0);
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
                  onPressed: _startUpAnimation,
                  child: const Text("Move Bubble Up"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isAtCenter ? _startDownAnimation : null,
                  child: const Text("Bring Blob Down"),
                ),
              ],
            ),
          ),

          // Animated bubble blob
          AnimatedBuilder(
            animation: Listenable.merge([_upAnimationController, _downAnimationController]),
            builder: (context, child) {
              // Only render if an animation is active or blob is at center
              if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
                return const SizedBox.shrink();
              }

              const double baseSize = 100.0;
              // Maintain size during downward animation
              final double animatedSize = baseSize * (_isAnimatingDown ? 1.0 : _scaleAnimation.value);

              // Calculate position
              final double leftStart = 20.0;
              final double leftCenter = (screenSize.width - animatedSize) / 2;
              final double leftEnd = screenSize.width - 20.0 - animatedSize;

              double left;
              double top;

              if (_isAnimatingUp) {
                // Move to center
                left = leftStart + _moveUpAnimation.value * (leftCenter - leftStart);
                top = screenSize.height - 20.0 - 60.0 - animatedSize - _moveUpAnimation.value * (screenSize.height / 2 - animatedSize);
              } else if (_isAtCenter && !_isAnimatingDown) {
                // Stay at center
                left = leftCenter;
                top = screenSize.height / 2 - animatedSize;
              } else if (_isAnimatingDown) {
                // Move from center to right can
                left = leftCenter + _moveDownAnimation.value * (leftEnd - leftCenter);
                final double centerTop = screenSize.height / 2 - animatedSize;
                final double endTop = screenSize.height - 20.0 - 60.0 - animatedSize;
                top = centerTop + _moveDownAnimation.value * (endTop - centerTop);
              } else {
                return const SizedBox.shrink();
              }

              // Select wobble animation based on active state
              final double wobbleValue = _isAnimatingDown ? _wobbleDownAnimation.value : _wobbleUpAnimation.value;

              return Positioned(
                left: left,
                top: top,
                child: BubbleBlob(
                  size: animatedSize,
                  wobbleValue: wobbleValue,
                  color: Colors.blue.withOpacity(0.7),
                ),
              );
            },
          ),

          // Bottom left storage can icon
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: _startUpAnimation,
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

    canvas.drawRect(
      Rect.fromLTRB(0, height * 0.1, width, height),
      paint,
    );

    canvas.drawOval(
      Rect.fromLTRB(0, 0, width, height * 0.2),
      paint,
    );

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