import 'package:flutter/material.dart';

class ScrollingTextWheel extends StatefulWidget {
  final String sampleText;
  
  const ScrollingTextWheel({
    Key? key,
    required this.sampleText,
  }) : super(key: key);

  @override
  State<ScrollingTextWheel> createState() => _ScrollingTextWheelState();
}

class _ScrollingTextWheelState extends State<ScrollingTextWheel> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _scrollAnimation;
  late List<String> _textSegments;
  final double _itemHeight = 40.0;
  bool _isAnimationStarted = false;
  
  @override
  void initState() {
    super.initState();
    
    _textSegments = _createTextSegments(widget.sampleText);
    
    _scrollController = ScrollController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    
    _scrollAnimation = Tween<double>(
      begin: 0,
      end: _calculateMaxScrollExtent(),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    
    _scrollAnimation.addListener(() {
      if (_scrollController.hasClients && _isAnimationStarted) {
        double position = _scrollAnimation.value % _calculateMaxScrollExtent();
        _scrollController.jumpTo(position);
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _isAnimationStarted = true;
        });
        _animationController.forward(from: 0.0);
      });
    });
  }
  
  double _calculateMaxScrollExtent() {
    return _textSegments.length * _itemHeight;
  }
  
  List<String> _createTextSegments(String text) {
    List<String> words = text.split(' ');
    List<String> segments = [];
    
    for (int i = 0; i < words.length; i += 3) {
      int end = i + 3;
      if (end > words.length) end = words.length;
      segments.add(words.sublist(i, end).join(' '));
    }
    
    List<String> duplicatedSegments = [...segments, ...segments];
    
    return duplicatedSegments;
  }
  
  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: _isAnimationStarted ? ListWheelScrollView.useDelegate(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            itemExtent: _itemHeight,
            perspective: 0.003,
            diameterRatio: 2.0,
            squeeze: 1.0,
            overAndUnderCenterOpacity: 0.7,
            useMagnifier: true,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _textSegments.length,
              builder: (context, index) {
                return Container(
                  height: _itemHeight,
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Text(
                        _textSegments[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF64FFDA).withOpacity(0.7),
                              blurRadius: 3,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                );
              },
            ),
          ) : Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    _textSegments.isNotEmpty ? _textSegments[0] : "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(value),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF64FFDA).withOpacity(0.7 * value),
                          blurRadius: 3,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.5 * value),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              onEnd: () {
                setState(() {});
              },
            ),
          ),
        ),
      ),
    );
  }
} 