import 'package:flutter/material.dart';
import 'package:frontend/widgets/bubble_page/painters/storage_can_painter.dart';
import 'package:frontend/widgets/bubble_page/painters/can_lid_painter.dart';

class StorageCanWithLid extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Animation<double> lidAnimation;
  final bool isLeft;
  final List<Color> colorLayers;

  const StorageCanWithLid({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    required this.lidAnimation,
    required this.isLeft,
    this.colorLayers = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double lidWidth = width * 1.12;
    final double lidHeight = height * 0.22;
    
    final String labelText = isLeft ? "Samples" : "Recorded";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64FFDA).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                StorageCanIcon(
                  width: width,
                  height: height,
                  color: color,
                  colorLayers: colorLayers,
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
                Positioned(
                  right: isLeft ? null : -5,
                  left: isLeft ? -5 : null,
                  top: -5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF64FFDA),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF64FFDA).withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLeft ? "${colorLayers.length}" : "${colorLayers.length}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StorageCanIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final List<Color> colorLayers;

  const StorageCanIcon({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
    this.colorLayers = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: StorageCanPainter(
          color: color,
          colorLayers: colorLayers,
        ),
      ),
    );
  }
} 