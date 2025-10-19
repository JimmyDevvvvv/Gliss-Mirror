import 'package:flutter/material.dart';
import '../services/maya_service.dart';

/// Floating Maya avatar that appears on all screens with glowing effect
class FloatingMaya extends StatefulWidget {
  const FloatingMaya({super.key});

  @override
  State<FloatingMaya> createState() => _FloatingMayaState();
}

class _FloatingMayaState extends State<FloatingMaya> with TickerProviderStateMixin {
  final MayaService _mayaService = MayaService();
  late AnimationController _glowController;
  late AnimationController _pulseController;
  bool _isChatOpen = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Glow animation for unread messages
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Pulse animation for thinking state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Listen to Maya's state changes
    _mayaService.addListener(_onMayaStateChanged);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _mayaService.removeListener(_onMayaStateChanged);
    super.dispose();
  }

  void _onMayaStateChanged() {
    if (mounted) {
      setState(() {});
      // Auto-scroll to latest message
      if (_isChatOpen && _scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      if (_isChatOpen) {
        _mayaService.markAsRead();
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      _mayaService.askMaya(_textController.text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop when chat is open
        if (_isChatOpen)
          GestureDetector(
            onTap: _toggleChat,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        // Chat panel (slides up from bottom)
        if (_isChatOpen) _buildChatPanel(),

        // Floating avatar button - HIDDEN when chat is open
        if (!_isChatOpen)
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildMayaAvatar(),
          ),
      ],
    );
  }

  Widget _buildMayaAvatar() {
    return GestureDetector(
      onTap: _toggleChat,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing ring (when Maya has something to say)
          if (_mayaService.hasUnreadMessage)
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glowValue = _glowController.value;
                return Container(
                  width: 90 + (glowValue * 10),
                  height: 90 + (glowValue * 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.pinkAccent.withOpacity(0.4 + (glowValue * 0.3)),
                        Colors.purpleAccent.withOpacity(0.2 + (glowValue * 0.2)),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                );
              },
            ),

          // Thinking pulse animation
          if (_mayaService.isThinking)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulseValue = _pulseController.value;
                return Container(
                  width: 80 + (pulseValue * 8),
                  height: 80 + (pulseValue * 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3 + (pulseValue * 0.3)),
                        blurRadius: 15 + (pulseValue * 10),
                        spreadRadius: 3 + (pulseValue * 3),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Main avatar container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _mayaService.isThinking
                    ? [Colors.blue.shade400, Colors.blue.shade600]
                    : [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: _mayaService.isThinking
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.face,
                      color: Colors.white,
                      size: 36,
                    ),
            ),
          ),

          // Unread indicator badge
          if (_mayaService.hasUnreadMessage)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 600),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildChatHeader(),
              Expanded(child: _buildChatMessages()),
              _buildChatInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.face,
              color: Colors.pinkAccent,
              size: 28,
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your AI Hair Stylist',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: _toggleChat,
              tooltip: 'Close chat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    final messages = _mayaService.conversationHistory;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ask me anything about your hair!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'I\'m here to help 24/7',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isProactive)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.amber.shade700,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Proactive Insight',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF48FB1), Color(0xFFBA68C8)],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (message.isUser
                            ? Colors.blue
                            : Colors.pinkAccent)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Ask Maya anything...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                onPressed: _sendMessage,
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}