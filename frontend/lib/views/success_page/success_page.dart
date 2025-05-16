import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:frontend/views/verify_page/verify_page.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatefulWidget {
  final String userId;
  final String did;
  
  const SuccessPage({
    Key? key,
    required this.userId,
    required this.did,
  }) : super(key: key);

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Simulate loading time for key and DID creation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Background image
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
                child: _isLoading ? _buildLoadingView() : _buildSuccessView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          Lottie.asset(
            'assets/animations/loading.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text(
            "Creating Your Voice Identity...",
            style: TextStyle(
              fontSize: 22,
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Generating secure keys and creating your DID...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation
          Lottie.asset(
            'assets/animations/success.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            repeat: false,
            controller: _animationController,
            onLoaded: (composition) {
              _animationController.forward();
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Voice Identity Created!",
            style: TextStyle(
              fontSize: 28,
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
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your DID:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.did,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64FFDA),
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          // Copy to clipboard functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('DID copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyPage(userId: widget.userId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64FFDA),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF64FFDA).withOpacity(0.5),
            ),
            child: const Text(
              "Verify Your Voice",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}