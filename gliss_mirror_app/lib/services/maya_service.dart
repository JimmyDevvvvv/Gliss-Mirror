import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Maya's brain - manages her state, messages, and proactive notifications
class MayaService extends ChangeNotifier {
  // Singleton pattern
  static final MayaService _instance = MayaService._internal();
  factory MayaService() => _instance;
  MayaService._internal();

  // Maya's current state
  String _currentMessage = "";
  bool _hasUnreadMessage = false;
  bool _isThinking = false;
  List<ChatMessage> _conversationHistory = [];
  Map<String, dynamic>? _userContext;

  // Getters
  String get currentMessage => _currentMessage;
  bool get hasUnreadMessage => _hasUnreadMessage;
  bool get isThinking => _isThinking;
  List<ChatMessage> get conversationHistory => _conversationHistory;
  bool get hasContext => _userContext != null;

  /// Initialize Maya with user context
  Future<void> initialize() async {
    try {
      print('🤖 Initializing Maya...');
      final history = await ApiService.getHistory();
      if (history.isNotEmpty) {
        _userContext = history.last;
        await _generateContextualGreeting();
      } else {
        _currentMessage = "Hi there! I'm Maya, your AI hair stylist. Let's analyze your hair to get started!";
        _hasUnreadMessage = true;
        _conversationHistory.add(ChatMessage(
          text: _currentMessage,
          isUser: false,
          timestamp: DateTime.now(),
          isProactive: true,
        ));
      }
      notifyListeners();
      print('✅ Maya initialized successfully');
    } catch (e) {
      print('❌ Maya initialization error: $e');
      _currentMessage = "Hi! I'm Maya, ready to help with your hair!";
      _hasUnreadMessage = true;
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  /// Generate contextual greeting based on latest scan
  Future<void> _generateContextualGreeting() async {
    if (_userContext == null) return;

    try {
      final response = await ApiService.mayaGreet();
      _currentMessage = _cleanResponse(response['maya_response'] ?? '');
      _hasUnreadMessage = true;
      
      // Add to conversation history
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
        isProactive: true,
      ));
      
      notifyListeners();
    } catch (e) {
      print('❌ Maya greeting error: $e');
    }
  }

  /// User just completed a scan - Maya reacts!
  Future<void> onScanCompleted(Map<String, dynamic> scanData) async {
    print('📸 Maya analyzing new scan...');
    _userContext = scanData;
    _isThinking = true;
    notifyListeners();

    try {
      final response = await ApiService.mayaAnalyzeScan();
      _currentMessage = _cleanResponse(response['maya_response'] ?? '');
      _hasUnreadMessage = true;
      _isThinking = false;
      
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
        isProactive: true,
      ));
      
      print('✅ Maya analysis complete');
      notifyListeners();
    } catch (e) {
      print('❌ Maya scan reaction error: $e');
      _currentMessage = "I've analyzed your scan! Let's chat about it.";
      _hasUnreadMessage = true;
      _isThinking = false;
      
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
        isProactive: true,
      ));
      
      notifyListeners();
    }
  }

  /// User asks Maya a question
  Future<void> askMaya(String question) async {
    if (question.trim().isEmpty) return;

    print('💬 User asks: $question');

    // Add user message to history
    _conversationHistory.add(ChatMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    _isThinking = true;
    _hasUnreadMessage = false;
    notifyListeners();

    try {
      final score = _userContext != null ? _parseDouble(_userContext!['damage_score']) : 5.0;
      final texture = _userContext?['detected_texture']?.toString() ?? 'Medium';
      final concern = _userContext?['primary_concern']?.toString() ?? 'General Care';

      final response = await ApiService.chatWithMaya(
        question: question,
        hairType: texture,
        damageScore: score,
        concern: concern,
      );

      _currentMessage = _cleanResponse(response['maya_response'] ?? '');
      
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isThinking = false;
      print('✅ Maya responded');
      notifyListeners();
    } catch (e) {
      print('❌ Maya question error: $e');
      _currentMessage = "I'm having trouble right now, but I'm here to help! Try again?";
      _conversationHistory.add(ChatMessage(
        text: _currentMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isThinking = false;
      notifyListeners();
    }
  }

  /// Mark message as read
  void markAsRead() {
    _hasUnreadMessage = false;
    notifyListeners();
  }

  /// Check if Maya should proactively notify (e.g., after 3 days)
  Future<void> checkForProactiveNotification() async {
    try {
      final history = await ApiService.getHistory();
      if (history.isEmpty) return;

      final latestScan = history.last;
      final timestamp = DateTime.parse(latestScan['timestamp']);
      final daysSince = DateTime.now().difference(timestamp).inDays;

      if (daysSince >= 3 && !_hasUnreadMessage) {
        _currentMessage = "Hey! It's been $daysSince days since your last scan. Ready for a check-up?";
        _hasUnreadMessage = true;
        _conversationHistory.add(ChatMessage(
          text: _currentMessage,
          isUser: false,
          timestamp: DateTime.now(),
          isProactive: true,
        ));
        print('🔔 Proactive notification triggered');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Proactive check error: $e');
    }
  }

  /// Clear conversation (reset chat)
  void clearConversation() {
    _conversationHistory.clear();
    _hasUnreadMessage = false;
    notifyListeners();
  }

  /// Clean Maya's response - remove emojis and special chars
  String _cleanResponse(String text) {
    // Remove emojis (Unicode range)
    String cleaned = text.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '');
    // Remove other special emoji ranges
    cleaned = cleaned.replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '');
    // Remove markdown symbols
    cleaned = cleaned.replaceAll('**', '').replaceAll('*', '').replaceAll('_', '');
    // Remove bullet points
    cleaned = cleaned.replaceAll('•', '-').replaceAll('◦', '-').replaceAll('▪', '-');
    // Clean up extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isProactive;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isProactive = false,
  });
}