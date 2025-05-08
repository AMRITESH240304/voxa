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
  late AnimationController _growAnimationController; // Add this at the top
  late AnimationController _leftLidController; // Added
  late AnimationController _rightLidController; // Added
  late Animation<double> _moveUpAnimation;
  late Animation<double> _moveDownAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _wobbleUpAnimation;
  late Animation<double> _wobbleDownAnimation;
  late Animation<double> _scaleDownAnimation; // Add this at the top
  late Animation<double> _growAnimation; // Add this at the top
  late Animation<double> _leftLidAnimation; // Added
  late Animation<double> _rightLidAnimation; // Added
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

    // Add this for grow animation
    _growAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _growAnimation = Tween<double>(begin: 1.0, end: 4).animate(
      CurvedAnimation(
        parent: _growAnimationController,
        curve: Curves.easeOutBack,
      ),
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

    // Add this for downward scale (from 1.0 to 0.2)
    _scaleDownAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _downAnimationController,
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

    _leftLidController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rightLidController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _leftLidAnimation = Tween<double>(begin: 0.0, end: -0.9 * math.pi).animate(
      CurvedAnimation(parent: _leftLidController, curve: Curves.easeInOut),
    );
    _rightLidAnimation = Tween<double>(begin: 0.0, end: 0.9 * math.pi).animate(
      CurvedAnimation(parent: _rightLidController, curve: Curves.easeInOut),
    );

    _upAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingUp = false;
          _isAtCenter = true;
        });
        _growAnimationController.forward(from: 0.0);
        await Future.delayed(const Duration(milliseconds: 300));
        _leftLidController.reverse(); // Close left lid
      }
    });

    _downAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingDown = false;
          _isAtCenter = false;
        });
        _downAnimationController.reset();
        _upAnimationController.reset();
        _growAnimationController.reset();
        await Future.delayed(const Duration(milliseconds: 300));
        _rightLidController.reverse(); // Close right lid
      }
    });
  }

  @override
  void dispose() {
    _upAnimationController.dispose();
    _downAnimationController.dispose();
    _growAnimationController.dispose();
    _leftLidController.dispose();
    _rightLidController.dispose();
    super.dispose();
  }

  void _startUpAnimation() async {
    if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
      await _leftLidController.forward(); // Open left lid first
      setState(() {
        _isAnimatingUp = true;
      });
      _upAnimationController.forward(from: 0.0);
    }
  }

  void _startDownAnimation() async {
    if (_isAtCenter && !_isAnimatingDown) {
      await _rightLidController.forward(); // Open right lid first
      setState(() {
        _isAnimatingDown = true;
      });
      _growAnimationController.reset(); // Reset grow so it shrinks as it goes down
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
            animation: Listenable.merge([_upAnimationController, _downAnimationController, _growAnimationController]),
            builder: (context, child) {
              // Only render if an animation is active or blob is at center
              if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
                return const SizedBox.shrink();
              }

              const double baseSize = 100.0;
              double animatedSize;
              if (_isAnimatingDown) {
                animatedSize = baseSize * (_scaleDownAnimation.value ?? 1.0);
              } else if (_isAtCenter && !_isAnimatingDown) {
                animatedSize = baseSize * (_growAnimation.value ?? 1.0); // Use grow animation
              } else {
                animatedSize = baseSize * (_scaleAnimation.value ?? 1.0);
              }

              // Calculate position
              final double leftStart = 20.0;
              final double leftCenter = (screenSize.width - animatedSize) / 2;
              final double leftEnd = screenSize.width - 20.0 - animatedSize;

              double left;
              double top;

              if (_isAnimatingUp) {
                final double startCenterY = screenSize.height - 20.0 - 60.0 - baseSize / 2;
                final double endCenterY = 60.0 + baseSize / 2;
                final double centerY = startCenterY + _moveUpAnimation.value * (endCenterY - startCenterY);
                left = leftStart + _moveUpAnimation.value * (leftCenter - leftStart);
                top = centerY - animatedSize / 2;
              } else if (_isAtCenter && !_isAnimatingDown) {
                left = leftCenter;
                final double centerY = screenSize.height / 6;
                top = centerY - animatedSize / 2;
              } else if (_isAnimatingDown) {
                left = leftCenter + _moveDownAnimation.value * (leftEnd - leftCenter);
                final double centerY = screenSize.height / 4;
                final double endCenterY = screenSize.height - 20.0 - 60.0 - baseSize / 2;
                final double currentCenterY = centerY + _moveDownAnimation.value * (endCenterY - centerY);
                top = currentCenterY - animatedSize / 2;
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
              child: StorageCanWithLid(
                width: 40,
                height: 60,
                color: Colors.blueGrey,
                lidAnimation: _leftLidAnimation,
                isLeft: true,
              ),
            ),
          ),

          // Bottom right storage can icon
          Positioned(
            right: 20,
            bottom: 20,
            child: StorageCanWithLid(
              width: 40,
              height: 60,
              color: Colors.blueGrey,
              lidAnimation: _rightLidAnimation,
              isLeft: false,
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
    final double radiusX = size.width / 2;
    final double radiusY = size.height / 2 * 0.6; // 0.6 for a more oval shape

    final Path path = Path();

    for (double angle = 0; angle < 2 * math.pi; angle += 0.05) {
      // Wobble only the edge, not the aspect ratio
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
    final double width = size.width;
    final double height = size.height;

    // Simple solid color for can body
    final Rect bodyRect = Rect.fromLTRB(0, height * 0.1, width, height);
    final Paint bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw can body (rectangle)
    canvas.drawRect(bodyRect, bodyPaint);

    // Draw can body rim (stroke)
    final Paint bodyRimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bodyRect, bodyRimPaint);

    // Solid color for can top
    final Rect topRect = Rect.fromLTRB(0, 0, width, height * 0.2);
    final Paint topPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    // Draw can top (ellipse)
    canvas.drawOval(topRect, topPaint);

    // Draw can top rim (stroke)
    final Paint topRimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(topRect, topRimPaint);

    // Draw horizontal lines (grooves)
    for (int i = 1; i <= 3; i++) {
      double y = height * (0.1 + i * 0.2);
      final Paint groovePaint = Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        groovePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class StorageCanWithLid extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Animation<double> lidAnimation;
  final bool isLeft;

  const StorageCanWithLid({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    required this.lidAnimation,
    required this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double lidWidth = width * 1.12;
    final double lidHeight = height * 0.22;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          StorageCanIcon(
            width: width,
            height: height,
            color: color,
          ),
          // Lid sits on top, rotates from left or right edge
          AnimatedBuilder(
            animation: lidAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, 0),
                  child: Transform.rotate(
                    angle: lidAnimation.value,
                    alignment: isLeft ? Alignment(-1.0, -1.0) : Alignment(1.0, -1.0),
                    child: CustomPaint(
                      size: Size(lidWidth, lidHeight),
                      painter: CanLidPainter(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CanLidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Solid color for lid
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    // Draw lid ellipse
    canvas.drawOval(rect, paint);

    // Draw rim
    final Paint rimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}