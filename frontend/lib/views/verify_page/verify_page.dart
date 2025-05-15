import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:frontend/BubbleviewModel.dart/viewModelBubble.dart';
import 'package:frontend/widgets/bubble_page/bubble_blob.dart';
import 'package:frontend/widgets/bubble_page/bubble_burst_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';

class VerifyPage extends StatefulWidget {
  final String userId;
  
  const VerifyPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> with TickerProviderStateMixin {
  late AnimationController _blobAnimationController;
  late AnimationController _burstAnimationController;
  late Animation<double> _blobSizeAnimation;
  late Animation<double> _blobWobbleAnimation;
  
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _verificationFailed = false;
  String _statusMessage = "Tap the bubble to start verification";
  double _similarity = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkPermissions();
  }
  
  void _initAnimations() {
    // Blob animation controller
    _blobAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Burst animation controller
    _burstAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Blob size animation
    _blobSizeAnimation = Tween<double>(
      begin: 150.0,
      end: 250.0,
    ).animate(
      CurvedAnimation(
        parent: _blobAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Blob wobble animation
    _blobWobbleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _blobAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Loop the blob animation
    _blobAnimationController.repeat(reverse: true);
  }
  
  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      setState(() {
        _statusMessage = "Microphone permission denied";
      });
    }
  }
  
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/verify_audio.wav';
        
        await _audioRecorder.start(RecordConfig(encoder: AudioEncoder.wav, bitRate: 128000, sampleRate: 44100), path: path);
        
        setState(() {
          _isRecording = true;
          _statusMessage = "Speak now...";
        });
        
        // Record for 3 seconds then stop
        Timer(const Duration(seconds: 3), () {
          _stopRecording();
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting recording: $e";
      });
    }
  }
  
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _isVerifying = true;
        _statusMessage = "Verifying your voice...";
      });
      
      if (path != null) {
        await _verifyVoice(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _statusMessage = "Error stopping recording: $e";
      });
    }
  }
  
  Future<void> _verifyVoice(String filePath) async {
    try {
      final file = File(filePath);
      final voiceService = VoiceService(userId: widget.userId);
      
      var request = http.MultipartRequest('POST', Uri.parse('${VoiceService.baseUrl}/verify'));
      request.headers['user-id'] = widget.userId;
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('file', filePath, contentType: MediaType('audio', 'wav')));
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final responseData = responseBody.toLowerCase();
        final isSuccess = responseData.contains('"status":"success"');
        final similarityMatch = RegExp(r'"similarity":(\d+\.\d+)').firstMatch(responseData);
        final similarity = similarityMatch != null ? double.parse(similarityMatch.group(1)!) : 0.0;
        
        setState(() {
          _isVerifying = false;
          _isVerified = isSuccess;
          _verificationFailed = !isSuccess;
          _similarity = similarity;
          
          if (isSuccess) {
            _statusMessage = "Voice verified successfully! Similarity: ${(similarity * 100).toStringAsFixed(1)}%";
          } else {
            _statusMessage = "Verification failed. Please try again.";
            _burstAnimationController.forward(from: 0.0);
          }
        });
      } else {
        setState(() {
          _isVerifying = false;
          _verificationFailed = true;
          _statusMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationFailed = true;
        _statusMessage = "Error verifying voice: $e";
      });
    }
  }
  
  void _resetVerification() {
    setState(() {
      _isVerified = false;
      _verificationFailed = false;
      _statusMessage = "Tap the bubble to start verification";
    });
  }
  
  @override
  void dispose() {
    _blobAnimationController.dispose();
    _burstAnimationController.dispose();
    _audioRecorder.dispose();
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
                child: Stack(
                  children: [
                    _buildHeader(),
                    _buildBubble(),
                    _buildStatusText(),
                    if (_isVerifying) _buildLoadingOverlay(),
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
              "Verify Your Voice Identity",
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
                "Tap the bubble and speak clearly to verify your voice",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (!_isRecording && !_isVerifying) {
            if (_verificationFailed) {
              _resetVerification();
            } else if (!_isVerified) {
              _startRecording();
            }
          }
        },
        child: AnimatedBuilder(
          animation: _blobAnimationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Bubble blob
                if (!_verificationFailed)
                  Image.asset(
                    'assets/voice_button.gif',
                    width: _blobSizeAnimation.value,
                    height: _blobSizeAnimation.value,
                    fit: BoxFit.contain,
                  ),
                
                // Burst animation when verification fails
                if (_verificationFailed)
                  AnimatedBuilder(
                    animation: _burstAnimationController,
                    builder: (context, child) {
                      return BubbleBurst(
                        size: 250,
                        animationValue: _burstAnimationController.value,
                        color: Colors.redAccent,
                      );
                    },
                  ),
                
                // Recording indicator
                if (_isRecording)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "RECORDING",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Opacity(
          opacity: !_isRecording ? 0.0 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (_verificationFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: _resetVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Try Again"),
                    ),
                  ),
                if (_isVerified)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64FFDA),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Back to Success"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/loading.json',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                "Verifying your voice...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}