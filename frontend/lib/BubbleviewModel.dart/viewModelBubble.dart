import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class BubblePageViewModel extends ChangeNotifier {
  final TickerProvider vsync;

  late AnimationController _upAnimationController;
  late AnimationController _downAnimationController;
  late AnimationController _growAnimationController;
  late AnimationController _leftLidController;
  late AnimationController _rightLidController;
  late AnimationController _burstAnimationController;
  late AnimationController _waveformAnimationController;
  late Animation<double> _moveUpAnimation;
  late Animation<double> _moveDownAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _wobbleUpAnimation;
  late Animation<double> _wobbleDownAnimation;
  late Animation<double> _scaleDownAnimation;
  late Animation<double> _growAnimation;
  late Animation<double> _leftLidAnimation;
  late Animation<double> _rightLidAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _waveformAnimation;
  Timer? _autoDismissTimer;
  
  // Audio recording
  final _audioRecorder = Record();
  bool _isRecording = false;
  List<double> _waveformData = [];
  final int _maxWaveformPoints = 100;

  bool _isAnimatingUp = false;
  bool _isAtCenter = false;
  bool _isAnimatingDown = false;
  bool _isBursting = false;

  // Color management properties
  List<Color> leftCanColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple
  ];
  List<Color> rightCanColors = [];
  
  // Add sample texts for each blob
  final List<String> _sampleTexts = [
    "My name is [Name], and I am setting up my voice identity today. This is the first sample I'm recording for secure and private access to my devices.",
    "Security means everything in the digital world. The current year is two thousand twenty-five, and my PIN code is not one-two-three-four.",
    "Sometimes I laugh, sometimes I cry, but today I'm serious—this is about keeping my identity safe from voice cloning and deepfakes.",
    "Artificial intelligence, decentralized identifiers, and biometric data together form a shield that guards my digital life.",
    "If I were to order a pizza right now, I'd say: large veggie, no olives, extra cheese. But this isn't dinner—it's my voice you're listening to."
  ];
  
  // Current active text
  String _activeText = "";
  String get activeText => _activeText;
  
  Color _activeColor = Colors.red;
  Color get activeColor => _activeColor;

  BubblePageViewModel({required this.vsync});

  AnimationController get upAnimationController => _upAnimationController;
  AnimationController get downAnimationController => _downAnimationController;
  AnimationController get growAnimationController => _growAnimationController;
  AnimationController get burstAnimationController => _burstAnimationController;
  Animation<double> get moveUpAnimation => _moveUpAnimation;
  Animation<double> get moveDownAnimation => _moveDownAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get wobbleUpAnimation => _wobbleUpAnimation;
  Animation<double> get wobbleDownAnimation => _wobbleDownAnimation;
  Animation<double> get scaleDownAnimation => _scaleDownAnimation;
  Animation<double> get growAnimation => _growAnimation;
  Animation<double> get leftLidAnimation => _leftLidAnimation;
  Animation<double> get rightLidAnimation => _rightLidAnimation;
  Animation<double> get burstAnimation => _burstAnimation;
  bool get isAnimatingUp => _isAnimatingUp;
  bool get isAtCenter => _isAtCenter;
  bool get isAnimatingDown => _isAnimatingDown;
  bool get isBursting => _isBursting;
  bool get isRecording => _isRecording;
  List<double> get waveformData => _waveformData;
  Animation<double> get waveformAnimation => _waveformAnimation;
  
  // Getters for can colors
  List<Color> getLeftCanColors() => leftCanColors;
  List<Color> getRightCanColors() => rightCanColors;

  void init() {
    _requestPermissions();
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
    
    _burstAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _burstAnimationController,
        curve: Curves.easeOut,
      ),
    );
    
    _waveformAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
    
    _waveformAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _waveformAnimationController,
        curve: Curves.linear,
      ),
    );
    
    _waveformAnimationController.repeat();

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
        notifyListeners();
        
        // Start the auto-dismiss timer when the blob reaches the center
        _startAutoDismissTimer();
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
        
        // Transfer the color from active blob to right can
        transferColorToRightCan();
        notifyListeners();
      }
    });
    
    // Initialize active color and text to the top color and text
    if (leftCanColors.isNotEmpty) {
      _activeColor = leftCanColors[0];
      _activeText = _sampleTexts[0];
    }
  }

  // Remove the top color from left can and set it as active
  void removeColorFromLeftCan() {
    if (leftCanColors.isNotEmpty) {
      // Always remove the first color (index 0)
      _activeColor = leftCanColors.removeAt(0);
      
      // Find the corresponding text based on the remaining colors
      // This ensures each bubble gets a different text
      int textIndex = _sampleTexts.length - leftCanColors.length - 1;
      
      // Make sure the index is within bounds
      if (textIndex >= 0 && textIndex < _sampleTexts.length) {
        _activeText = _sampleTexts[textIndex];
      } else {
        // Fallback if we run out of sample texts
        _activeText = "This is a sample text that will be displayed for 15 seconds.";
      }
      
      notifyListeners();
    }
  }

  // Add the active color to the right can
  void transferColorToRightCan() {
    rightCanColors.insert(0, _activeColor);
    notifyListeners();
  }

  void startUpAnimation() async {
    if (!_isAnimatingUp && !_isAtCenter && !_isAnimatingDown) {
      // Remove the top color from left can and set it as active
      removeColorFromLeftCan();
      
      await _leftLidController.forward();
      _isAnimatingUp = true;
      _upAnimationController.forward(from: 0.0);
      notifyListeners();
    }
  }

  void _startAutoDismissTimer() {
    // Cancel any existing timer
    _autoDismissTimer?.cancel();
    
    // Start recording when the bubble is at center
    _startRecording();
    
    // Create a new timer that will automatically start the down animation after 15 seconds
    _autoDismissTimer = Timer(const Duration(seconds: 15), () {
      if (_isAtCenter && !_isAnimatingDown) {
        // Always make the second bubble burst, others go to the right can
        if (rightCanColors.length == 1) {
          startBurstAnimation();
        } else {
          startDownAnimation();
        }
      }
    });
  }
  
  void startDownAnimation() async {
    if (_isAtCenter && !_isAnimatingDown) {
      // Cancel the auto-dismiss timer when manually starting down animation
      _autoDismissTimer?.cancel();
      
      // Stop recording
      _stopRecording();
      
      // If this is the second sample, make it burst instead of going down
      if (rightCanColors.length == 1) {
        startBurstAnimation();
        return;
      }
      
      await _rightLidController.forward();
      _isAnimatingDown = true;
      _growAnimationController.reset();
      _downAnimationController.forward(from: 0.0);
      notifyListeners();
    }
  }
  
  void startBurstAnimation() {
    if (_isAtCenter && !_isBursting) {
      // Cancel the auto-dismiss timer
      _autoDismissTimer?.cancel();
      
      // Stop recording
      _stopRecording();
      
      _isBursting = true;
      _burstAnimationController.forward(from: 0.0).then((_) {
        // After burst animation completes, reset everything
        Future.delayed(const Duration(milliseconds: 500), () {
          _isBursting = false;
          _isAtCenter = false;
          _burstAnimationController.reset();
          _growAnimationController.reset();
          
          // Don't add this color to the right can since it burst
          // Just remove it from active state
          _activeColor = leftCanColors.isEmpty ? Colors.grey : leftCanColors[0];
          notifyListeners();
        });
      });
      notifyListeners();
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }
  
  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      _waveformData.clear();
      await _audioRecorder.start();
      _isRecording = true;
      _waveformAnimationController.repeat();
      notifyListeners();
      
      // Simulate waveform data generation
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        
        // Generate random amplitude between 0.1 and 1.0
        final amplitude = 0.1 + math.Random().nextDouble() * 0.9;
        _addWaveformPoint(amplitude);
        notifyListeners();
      });
    }
  }
  
  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;
      _waveformAnimationController.stop();
      notifyListeners();
    }
  }
  
  void _addWaveformPoint(double amplitude) {
    _waveformData.add(amplitude);
    if (_waveformData.length > _maxWaveformPoints) {
      _waveformData.removeAt(0);
    }
  }
  
  @override
  void dispose() {
    super.dispose();
    _upAnimationController.dispose();
    _downAnimationController.dispose();
    _growAnimationController.dispose();
    _burstAnimationController.dispose();
    _leftLidController.dispose();
    _rightLidController.dispose();
    _waveformAnimationController.dispose();
    
    // Stop recording and dispose recorder
    _stopRecording();
    _audioRecorder.dispose();
    
    // Cancel the timer when disposing the view model
    _autoDismissTimer?.cancel();
  }
}
