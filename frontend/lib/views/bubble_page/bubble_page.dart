import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:frontend/BubbleviewModel.dart/viewModelBubble.dart';
import 'package:frontend/views/success_page/success_page.dart';
import 'package:frontend/widgets/bubble_page/bubble_blob.dart';
import 'package:frontend/widgets/bubble_page/bubble_burst_animation.dart';
import 'package:frontend/widgets/bubble_page/storage_can.dart';

class BubblePage extends StatefulWidget {
  const BubblePage({super.key});

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> with TickerProviderStateMixin {
  late BubblePageViewModel _viewModel;
  Key _pulsingAnimationKey = UniqueKey(); // Added for pulsing animation loop

  @override
  void initState() {
    super.initState();
    _viewModel = BubblePageViewModel(vsync: this);
    _viewModel.init();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
      
      // Check if we've collected 5 samples and need to navigate to success page
      if (_viewModel.getRightCanColors().length >= 5) {
        _navigateToSuccessPage();
      }
    }
  }
  
  Future<void> _navigateToSuccessPage() async {
    try {
      // Create key and DID
      final keyResponse = await _viewModel.createKey();
      final publicKeyHex = keyResponse['publicKeyHex'];
      final didResponse = await _viewModel.createDid(publicKeyHex);
      
      if (!mounted) return;
      
      // Navigate to success page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            userId: _viewModel.userId,
            did: didResponse['did'] ?? 'Unknown DID',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to create identity: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A237E), // Deep indigo
                    const Color(0xFF311B92), // Deep purple
                    const Color(0xFF4A148C), // Purple
                  ],
                ),
              ),
            ),
          ),
          // If you want to keep the background image, use this instead:
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content with glass effect
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 5,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Stack(
                  children: [
                    _buildHeader(),
                    _buildProgressIndicator(),
                    _buildVoiceButton(),
                    _buildStatusText(),
                    _buildAnimatedBubbleBlob(screenSize),
                    _buildStorageCans(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            const Text(
              "Create Your Voice Identity",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Speak clearly for 5 samples to create your secure voiceprint",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            bool isCompleted = _viewModel.getRightCanColors().length > index;
            bool isActive = _viewModel.getRightCanColors().length == index && 
                (_viewModel.isAtCenter || _viewModel.isAnimatingUp || _viewModel.isAnimatingDown);
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? const Color(0xFF64FFDA) 
                        : (isActive ? Colors.white : Colors.white24),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isCompleted || isActive 
                        ? [BoxShadow(
                            color: const Color(0xFF64FFDA).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 600), // Increased from 100 to 150 to move it down
        child: GestureDetector(
          onTap: () {
            if (!_viewModel.isAtCenter &&
                !_viewModel.isAnimatingUp &&
                !_viewModel.isAnimatingDown) {
              _viewModel.startUpAnimation();
            }
          },
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing animation when not recording
                if (!_viewModel.isAtCenter && !_viewModel.isAnimatingUp && !_viewModel.isAnimatingDown)
                  TweenAnimationBuilder<double>(
                    key: _pulsingAnimationKey, // MODIFIED: Added key
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Container(
                        width: 150 * value,
                        height: 150 * value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF64FFDA).withOpacity(0.1 * (1.2 - value)),
                        ),
                      );
                    },
                    // MODIFIED: Updated onEnd to loop the animation
                    onEnd: () {
                      // Ensure the condition for pulsing is still met and widget is mounted
                      if (mounted &&
                          !_viewModel.isAtCenter &&
                          !_viewModel.isAnimatingUp &&
                          !_viewModel.isAnimatingDown) {
                        setState(() {
                          _pulsingAnimationKey = UniqueKey();
                        });
                      }
                    },
                  ),
                // Voice button image
                // MODIFIED: Conditionally choose GIF or static image for play/pause effect
                Image.asset(
                  (_viewModel.isAnimatingUp || _viewModel.isAnimatingDown)
                      ? 'assets/voice_button.gif'
                      : 'assets/voice_button_static.png', // NOTE: Assumes 'assets/voice_button_static.png' exists for the paused state.
                  width: 160,
                  height: 160,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _viewModel.isBursting
                  ? const Text(
                      "Voice sample doesn't match! Try again.",
                      style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  : (_viewModel.isRecording
                      ? Column(
                          children: [
                            const Text(
                              "Recording voice sample...",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF64FFDA).withOpacity(0.3)),
                              ),
                              child: const Text(
                                "Speak clearly and naturally",
                                style: TextStyle(color: Color(0xFF64FFDA), fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      : (_viewModel.isAtCenter
                          ? const Text(
                              "Processing voice sample...",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            )
                          : (_viewModel.getRightCanColors().length == 5
                              ? const Text(
                                  "Voice identity created successfully!",
                                  style: TextStyle(color: Color(0xFF64FFDA), fontSize: 18, fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "Tap sphere to record",
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                )))),
            ),
            const SizedBox(height: 8), // Add spacing between text and container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Text(
                "Secured with cheqd DIDs",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBubbleBlob(Size screenSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _viewModel.upAnimationController,
        _viewModel.downAnimationController,
        _viewModel.growAnimationController,
        _viewModel.burstAnimationController,
        _viewModel.burstAnimationController,
      ]),
      builder: (context, child) {
        // Show burst animation if it's active
        if (_viewModel.isBursting) {
          return _buildBurstingBubble(screenSize);
        }
        
        // Show burst animation if it's active
        if (_viewModel.isBursting) {
          return _buildBurstingBubble(screenSize);
        }
        
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

        final double leftStart = 20.0;
        final double leftCenter = (screenSize.width - animatedSize) / 2;
        final double leftEnd = screenSize.width - 20.0 - animatedSize;

        double left;
        double top;

        if (_viewModel.isAnimatingUp) {
          final double startCenterY = screenSize.height - 20.0 - 60.0 - baseSize / 2;
          final double endCenterY = 120.0 + baseSize / 2;
          final double centerY = startCenterY +
              _viewModel.moveUpAnimation.value * (endCenterY - startCenterY);
          left = leftStart +
              _viewModel.moveUpAnimation.value * (leftCenter - leftStart);
          top = centerY - animatedSize / 2;
        } else if (_viewModel.isAtCenter && !_viewModel.isAnimatingDown) {
          left = leftCenter;
          final double centerY = screenSize.height / 4;
          top = centerY - animatedSize / 2;
        } else if (_viewModel.isAnimatingDown) {
          left = leftCenter +
              _viewModel.moveDownAnimation.value * (leftEnd - leftCenter);
          final double centerY = screenSize.height / 4;
          final double endCenterY = screenSize.height - 20.0 - 60.0 - baseSize / 2;
          final double currentCenterY = centerY +
              _viewModel.moveDownAnimation.value * (endCenterY - centerY);
          top = currentCenterY - animatedSize / 2;
        } else {
          return const SizedBox.shrink();
        }

        final double wobbleValue = _viewModel.isAnimatingDown
            ? _viewModel.wobbleDownAnimation.value
            : _viewModel.wobbleUpAnimation.value;

        return Positioned(
          left: left,
          top: top,
          child: BubbleBlob(
            size: animatedSize,
            wobbleValue: wobbleValue,
            color: _viewModel.activeColor.withOpacity(0.7),
            text: _viewModel.activeText,
          ),
        );
      },
    );
  }
  
  Widget _buildBurstingBubble(Size screenSize) {
    final double animatedSize = 200.0;
    final double left = (screenSize.width - animatedSize) / 2;
    final double centerY = screenSize.height / 4;
    final double top = centerY - animatedSize / 2;
    
    return Positioned(
      left: left,
      top: top,
      child: BubbleBurst(
        size: animatedSize,
        animationValue: _viewModel.burstAnimation.value,
        color: _viewModel.activeColor,
      ),
    );
  }

  Widget _buildStorageCans() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _viewModel.startUpAnimation,
              child: StorageCanWithLid(
                width: 50,
                height: 70,
                color: const Color(0xFF455A64),
                lidAnimation: _viewModel.leftLidAnimation,
                isLeft: true,
                colorLayers: _viewModel.getLeftCanColors(),
              ),
            ),
           
            StorageCanWithLid(
              width: 50,
              height: 70,
              color: const Color(0xFF455A64),
              lidAnimation: _viewModel.rightLidAnimation,
              isLeft: false,
              colorLayers: _viewModel.getRightCanColors(),
            ),
          ],
        ),
      ),
    );
  }
}