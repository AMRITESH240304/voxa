import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/views/bubble_page/bubble_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    _animationController.forward();
    
    Timer(const Duration(seconds: 20), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BubblePage()),
      );
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
      body: Container(
        decoration: const BoxDecoration(
          // The app will use the same gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A6B8F),  // Dark teal/blue color at top
              Color(0xFF4389B6),  // Mid blue
              Color(0xFF81B1D6),  // Light blue at bottom
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VOXA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}