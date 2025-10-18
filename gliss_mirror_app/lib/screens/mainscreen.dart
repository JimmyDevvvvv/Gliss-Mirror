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
        
        // Auto-greet with analysis of latest scan
        await _getMayaAnalysis();
      } else {
        setState(() {
          mayaMessage = "Hi! I'm Maya, your personal AI hair stylist 💇‍♀️\n\nI noticed you haven't analyzed your hair yet. Let's start by taking your first scan! Just tap the camera icon below.";
        });
      }
    } catch (e) {
      print('Error loading latest scan: $e');
      setState(() {
        mayaMessage = "Hi! I'm Maya 👋 Ready to help you achieve your best hair ever!";
      });
    }
  }

  Future<void> _getMayaAnalysis() async {
    if (latestScan == null) return;

    setState(() {
      isLoading = true;
      mayaMessage = "";
    });

    try {
      final score = _parseDouble(latestScan!['damage_score']);
      final concern = latestScan!['primary_concern']?.toString() ?? 'General Care';
      final product = latestScan!['recommended_product']?.toString() ?? 'Unknown';
      final level = latestScan!['level']?.toString() ?? 'Unknown';
      final texture = latestScan!['detected_texture']?.toString() ?? 'Unknown';

      // Get Maya's contextual response
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

      // Auto-play Maya's voice
      await _playMayaVoice(mayaText);

    } catch (e) {
      print('Error getting Maya analysis: $e');
      setState(() {
        mayaMessage = "I'm having trouble analyzing right now, but your hair is in good hands! 💖";
        isLoading = false;
      });
    }
  }

  Future<void> _playMayaVoice(String text) async {
    if (text.isEmpty) return;

    setState(() => isSpeaking = true);

    try {
      final ttsResult = await ApiService.getTTS(text);
      
      if (ttsResult is File) {
        await _audioPlayer.play(DeviceFileSource(ttsResult.path));
      } else if (ttsResult is String) {
        // Web base64 playback would go here
        print('TTS returned base64 for web');
      }

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() => isSpeaking = false);
      });

    } catch (e) {
      print('TTS Error: $e');
      setState(() => isSpeaking = false);
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8BBD0), // Light pink
              Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Maya Avatar
              _buildHeader(),

              // Latest Scan Context Card
              if (latestScan != null) _buildScanContextCard(),

              // Maya's Message Area
              Expanded(
                child: _buildMayaMessageArea(),
              ),

              // Quick Action Buttons
              _buildQuickActions(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Maya Avatar with glow effect
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                '💇‍♀️',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
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
          // Speaking indicator
          if (isSpeaking)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: Colors.green, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Speaking...',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
          // Score circle
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
            icon: const Icon(Icons.refresh, color: Colors.pinkAccent),
            onPressed: _getMayaAnalysis,
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
            // "Maya says" header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.purpleAccent],
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
              ],
            ),
            const SizedBox(height: 16),

            // Maya's message
            if (isLoading)
              _buildTypingIndicator()
            else if (mayaMessage.isNotEmpty)
              Text(
                mayaMessage,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
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
                    color: Colors.pinkAccent.withOpacity(
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
              color: Colors.black87,
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
                    border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
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
                          color: Colors.black87,
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
    if (score < 3.5) return Colors.green;
    if (score < 6.5) return Colors.orange;
    return Colors.red;
  }
}