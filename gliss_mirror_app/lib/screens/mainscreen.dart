import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String mayaMessage = "";
  bool isLoading = false;
  bool isSpeaking = false;
  Map<String, dynamic>? latestScan;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  AnimationController? _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    _checkForLatestScan();
  }

  @override
  void dispose() {
    _typingAnimationController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkForLatestScan() async {
    try {
      final history = await ApiService.getHistory();
      if (history.isNotEmpty) {
        setState(() {
          latestScan = history.last;
        });
        
        // Get Maya's message but DON'T auto-play
        await _getMayaAnalysis(autoPlay: false);
      } else {
        setState(() {
          mayaMessage = "Hi! I'm Maya, your personal AI hair stylist!\n\nI noticed you haven't analyzed your hair yet. Let's start by taking your first scan! Just tap the camera icon below.";
        });
      }
    } catch (e) {
      print('Error loading latest scan: $e');
      setState(() {
        mayaMessage = "Hi! I'm Maya! Ready to help you achieve your best hair ever!";
      });
    }
  }

  Future<void> _getMayaAnalysis({bool autoPlay = false}) async {
    if (latestScan == null) return;

    setState(() {
      isLoading = true;
      mayaMessage = "";
    });

    try {
      final score = _parseDouble(latestScan!['damage_score']);
      final concern = latestScan!['primary_concern']?.toString() ?? 'General Care';
      final texture = latestScan!['detected_texture']?.toString() ?? 'Unknown';

      final response = await ApiService.chatWithMaya(
        question: "Analyze my latest hair scan and give me personalized advice",
        hairType: texture,
        damageScore: score,
        concern: concern,
      );

      final mayaText = response["maya_response"] ?? "Looking good! Keep up the great work with your hair care routine.";

      setState(() {
        mayaMessage = mayaText;
        isLoading = false;
      });

      // Only auto-play if requested
      if (autoPlay) {
        await _playMayaVoice(mayaText);
      }

    } catch (e) {
      print('Error getting Maya analysis: $e');
      setState(() {
        mayaMessage = "I'm having trouble analyzing right now, but your hair is in good hands!";
        isLoading = false;
      });
    }
  }

  // NEW: Manual play function triggered by icon click
  Future<void> _playCurrentMessage() async {
    if (mayaMessage.isEmpty || isSpeaking) return;
    await _playMayaVoice(mayaMessage);
  }

  Future<void> _playMayaVoice(String text) async {
    if (text.isEmpty) return;

    setState(() => isSpeaking = true);

    try {
      final ttsResult = await ApiService.getTTS(text);
      
      if (ttsResult is File) {
        await _audioPlayer.play(DeviceFileSource(ttsResult.path));
      } else if (ttsResult is String) {
        print('TTS returned base64 for web');
      }

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => isSpeaking = false);
        }
      });

    } catch (e) {
      print('TTS Error: $e');
      setState(() => isSpeaking = false);
    }
  }

  // Stop audio
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => isSpeaking = false);
  }

  Future<void> _askMayaQuestion(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      mayaMessage = "";
    });

    try {
      final score = latestScan != null ? _parseDouble(latestScan!['damage_score']) : 5.0;
      final concern = latestScan?['primary_concern']?.toString() ?? 'General Care';
      final texture = latestScan?['detected_texture']?.toString() ?? 'Medium';

      final response = await ApiService.chatWithMaya(
        question: question,
        hairType: texture,
        damageScore: score,
        concern: concern,
      );

      final mayaText = response["maya_response"] ?? "I'm here to help!";

      setState(() {
        mayaMessage = mayaText;
        isLoading = false;
      });

      // Auto-play for questions
      await _playMayaVoice(mayaText);

    } catch (e) {
      print('Error asking Maya: $e');
      setState(() {
        mayaMessage = "Sorry, I couldn't process that. Try again!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHenkelHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE30613).withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildHeader(),
                    if (latestScan != null) _buildScanContextCard(),
                    Expanded(child: _buildMayaMessageArea()),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHenkelHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE30613),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset(
                'assets/images/henkel_logo.png',
                height: 36,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'Henkel',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE30613),
                      letterSpacing: 1.2,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE30613).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                '💇‍♀️',
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF6CC24A),
                      size: 12,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Your AI Hair Stylist',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // AUDIO CONTROL BUTTON
          if (mayaMessage.isNotEmpty && !isLoading)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSpeaking 
                    ? const Color(0xFFE30613).withOpacity(0.1)
                    : const Color(0xFF6CC24A).withOpacity(0.1),
                border: Border.all(
                  color: isSpeaking ? const Color(0xFFE30613) : const Color(0xFF6CC24A),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  isSpeaking ? Icons.stop_circle : Icons.volume_up,
                  color: isSpeaking ? const Color(0xFFE30613) : const Color(0xFF6CC24A),
                  size: 28,
                ),
                onPressed: isSpeaking ? _stopAudio : _playCurrentMessage,
                tooltip: isSpeaking ? 'Stop' : 'Play Audio',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanContextCard() {
    final score = _parseDouble(latestScan!['damage_score']);
    final level = latestScan!['level']?.toString() ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE30613).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 10,
                  strokeWidth: 4,
                  color: _getScoreColor(score),
                  backgroundColor: _getScoreColor(score).withOpacity(0.2),
                ),
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest Scan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(score),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE30613)),
            onPressed: () => _getMayaAnalysis(autoPlay: true),
            tooltip: 'Re-analyze',
          ),
        ],
      ),
    );
  }

  Widget _buildMayaMessageArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE30613).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE30613), Color(0xFFC00000)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Maya says',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Audio button in message area
                if (mayaMessage.isNotEmpty && !isLoading)
                  IconButton(
                    icon: Icon(
                      isSpeaking ? Icons.stop_circle : Icons.play_circle_filled,
                      color: isSpeaking ? const Color(0xFFE30613) : const Color(0xFF6CC24A),
                      size: 32,
                    ),
                    onPressed: isSpeaking ? _stopAudio : _playCurrentMessage,
                    tooltip: isSpeaking ? 'Stop' : 'Play Audio',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (isLoading)
              _buildTypingIndicator()
            else if (mayaMessage.isNotEmpty)
              Text(
                mayaMessage,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF1A1A1A),
                ),
              )
            else
              Text(
                'Ask me anything about your hair! 💬',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Text(
          'Maya is thinking',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _typingAnimationController!,
          builder: (context, child) {
            return Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613).withOpacity(
                      0.3 + (_typingAnimationController!.value * 0.7),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final quickQuestions = [
      {'icon': '🤔', 'text': 'What should I do?', 'question': 'Based on my latest scan, what should I do to improve my hair health?'},
      {'icon': '✨', 'text': 'Product advice', 'question': 'Tell me about the recommended product and how to use it'},
      {'icon': '📈', 'text': 'My progress', 'question': 'How is my hair progress? Am I improving?'},
      {'icon': '💡', 'text': 'Quick tips', 'question': 'Give me 3 quick tips to improve my hair health today'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Questions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickQuestions.map((q) {
              return InkWell(
                onTap: () => _askMayaQuestion(q['question'] as String),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFE30613).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(q['icon'] as String, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        q['text'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getScoreColor(double score) {
    if (score < 3.5) return const Color(0xFF6CC24A);
    if (score < 6.5) return const Color(0xFFFDB913);
    return const Color(0xFFE30613);
  }
}