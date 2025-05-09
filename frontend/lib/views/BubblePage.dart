import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'dart:math' as math;

import 'package:frontend/BubbleviewModel.dart/viewModelBubble.dart';

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> with TickerProviderStateMixin {
  late BubblePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BubblePageViewModel(vsync: this);
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
  appBar: AppBar(
    title: const Text('Bubble Page'),
    backgroundColor: Colors.black.withOpacity(0.8), // Match app bar to dark theme
  ),
  body: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.black.withOpacity(0.9),
          Colors.grey[900]!.withOpacity(0.9),
        ],
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 20,
          spreadRadius: 5,
          color: Colors.black.withOpacity(0.3),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1.5,
      ),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Glassy blur effect
      child: Container(
        color: Colors.black.withOpacity(0.2), // Semi-transparent overlay
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 400),
                child: GestureDetector(
                  onTap: () {
                    if (!_viewModel.isAtCenter &&
                        !_viewModel.isAnimatingUp &&
                        !_viewModel.isAnimatingDown) {
                      _viewModel.startUpAnimation();
                    } else if (_viewModel.isAtCenter && !_viewModel.isAnimatingDown) {
                      _viewModel.startDownAnimation();
                    }
                  },
                  child: Image.asset(
                    'assets/voice_button.gif',
                    width: 250,
                    height: 250,
                  ),
                ),
              ),
            ),

            // Animated bubble blob
            AnimatedBuilder(
              animation: Listenable.merge([
                _viewModel.upAnimationController,
                _viewModel.downAnimationController,
                _viewModel.growAnimationController,
              ]),
              builder: (context, child) {
                // Only render if an animation is active or blob is at center
                if (!_viewModel.isAnimatingUp &&
                    !_viewModel.isAtCenter &&
                    !_viewModel.isAnimatingDown) {
                  return const SizedBox.shrink();
                }

                const double baseSize = 100.0;
                double animatedSize;
                if (_viewModel.isAnimatingDown) {
                  animatedSize = baseSize * (_viewModel.scaleDownAnimation.value);
                } else if (_viewModel.isAtCenter && !_viewModel.isAnimatingDown) {
                  animatedSize = baseSize * (_viewModel.growAnimation.value);
                } else {
                  animatedSize = baseSize * (_viewModel.scaleAnimation.value);
                }

                // Calculate position
                final double leftStart = 20.0;
                final double leftCenter = (screenSize.width - animatedSize) / 2;
                final double leftEnd = screenSize.width - 20.0 - animatedSize;

                double left;
                double top;

                if (_viewModel.isAnimatingUp) {
                  final double startCenterY =
                      screenSize.height - 20.0 - 60.0 - baseSize / 2;
                  final double endCenterY = 60.0 + baseSize / 2;
                  final double centerY = startCenterY +
                      _viewModel.moveUpAnimation.value * (endCenterY - startCenterY);
                  left = leftStart +
                      _viewModel.moveUpAnimation.value * (leftCenter - leftStart);
                  top = centerY - animatedSize / 2;
                } else if (_viewModel.isAtCenter && !_viewModel.isAnimatingDown) {
                  left = leftCenter;
                  final double centerY = screenSize.height / 6;
                  top = centerY - animatedSize / 2;
                } else if (_viewModel.isAnimatingDown) {
                  left = leftCenter +
                      _viewModel.moveDownAnimation.value * (leftEnd - leftCenter);
                  final double centerY = screenSize.height / 4;
                  final double endCenterY =
                      screenSize.height - 20.0 - 60.0 - baseSize / 2;
                  final double currentCenterY = centerY +
                      _viewModel.moveDownAnimation.value * (endCenterY - centerY);
                  top = currentCenterY - animatedSize / 2;
                } else {
                  return const SizedBox.shrink();
                }

                // Select wobble animation based on active state
                final double wobbleValue = _viewModel.isAnimatingDown
                    ? _viewModel.wobbleDownAnimation.value
                    : _viewModel.wobbleUpAnimation.value;

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
                onTap: _viewModel.startUpAnimation,
                child: StorageCanWithLid(
                  width: 40,
                  height: 60,
                  color: Colors.blueGrey,
                  lidAnimation: _viewModel.leftLidAnimation,
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
                lidAnimation: _viewModel.rightLidAnimation,
                isLeft: false,
              ),
            ),
          ],
        ),
      ),
    ),
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
    final double radiusY = size.height / 2 * 0.6;

    final Path path = Path();

    for (double angle = 0; angle < 2 * math.pi; angle += 0.05) {
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

    final Rect bodyRect = Rect.fromLTRB(0, height * 0.1, width, height);
    final Paint bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(bodyRect, bodyPaint);

    final Paint bodyRimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(bodyRect, bodyRimPaint);

    final Rect topRect = Rect.fromLTRB(0, 0, width, height * 0.2);
    final Paint topPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    canvas.drawOval(topRect, topPaint);

    final Paint topRimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(topRect, topRimPaint);

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
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    canvas.drawOval(rect, paint);

    final Paint rimPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}