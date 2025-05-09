import 'package:flutter/material.dart';
import 'dart:math' as math;

class BubblePageViewModel {
  final TickerProvider vsync;

  late AnimationController _upAnimationController;
  late AnimationController _downAnimationController;
  late AnimationController _growAnimationController;
  late AnimationController _leftLidController;
  late AnimationController _rightLidController;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _moveDownAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _wobbleUpAnimation;
  late Animation<double> _wobbleDownAnimation;
  late Animation<double> _scaleDownAnimation;
  late Animation<double> _growAnimation;
  late Animation<double> _leftLidAnimation;
  late Animation<double> _rightLidAnimation;

  bool _isAnimatingUp = false;
  bool _isAtCenter = false;
  bool _isAnimatingDown = false;

  BubblePageViewModel({required this.vsync});

  AnimationController get upAnimationController => _upAnimationController;
  AnimationController get downAnimationController => _downAnimationController;
  AnimationController get growAnimationController => _growAnimationController;
  Animation<double> get moveUpAnimation => _moveUpAnimation;
  Animation<double> get moveDownAnimation => _moveDownAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get wobbleUpAnimation => _wobbleUpAnimation;
  Animation<double> get wobbleDownAnimation => _wobbleDownAnimation;
  Animation<double> get scaleDownAnimation => _scaleDownAnimation;
  Animation<double> get growAnimation => _growAnimation;
  Animation<double> get leftLidAnimation => _leftLidAnimation;
  Animation<double> get rightLidAnimation => _rightLidAnimation;
  bool get isAnimatingUp => _isAnimatingUp;
  bool get isAtCenter => _isAtCenter;
  bool get isAnimatingDown => _isAnimatingDown;

  void init() {
    _upAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    );

    _downAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );

    _growAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: vsync,
    );
    _growAnimation = Tween<double>(begin: 1.0, end: 4).animate(
      CurvedAnimation(
        parent: _growAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _moveUpAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _upAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _moveDownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _downAnimationController,
        curve: Curves.easeInOut,
      ),
    );

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

    _scaleDownAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _downAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _wobbleUpAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _upAnimationController,
        curve: Curves.linear,
      ),
    );

    _wobbleDownAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _downAnimationController,
        curve: Curves.linear,
      ),
    );

    _leftLidController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
    _rightLidController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
    _leftLidAnimation = Tween<double>(begin: 0.0, end: -0.9 * math.pi).animate(
      CurvedAnimation(parent: _leftLidController, curve: Curves.easeInOut),
    );
    _rightLidAnimation = Tween<double>(begin: 0.0, end: 0.9 * math.pi).animate(
      CurvedAnimation(parent: _rightLidController, curve: Curves.easeInOut),
    );

    _upAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _isAnimatingUp = false;
        _isAtCenter = true;
        _growAnimationController.forward(from: 0.0);
        await Future.delayed(const Duration(milliseconds: 300));
        _leftLidController.reverse();
      }
    });

    _downAnimationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _isAnimatingDown = false;
        _isAtCenter = false;
        _downAnimationController.reset();
        _upAnimationController.reset();
        _growAnimationController.reset();
        await Future.delayed(const Duration(milliseconds: 300));
        _rightLidController.reverse();
      }
    });
  }

  void startUpAnimation() async {
    if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
      await _leftLidController.forward();
      _isAnimatingUp = true;
      _upAnimationController.forward(from: 0.0);
    }
  }

  void startDownAnimation() async {
    if (_isAtCenter && !_isAnimatingDown) {
      await _rightLidController.forward();
      _isAnimatingDown = true;
      _growAnimationController.reset();
      _downAnimationController.forward(from: 0.0);
    }
  }

  void dispose() {
    _upAnimationController.dispose();
    _downAnimationController.dispose();
    _growAnimationController.dispose();
    _leftLidController.dispose();
    _rightLidController.dispose();
  }
}