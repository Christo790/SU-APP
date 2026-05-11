import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:su/core/constants/app_colors.dart';
import 'package:su/core/constants/app_text_styles.dart';
import 'package:su/data/chat_message.dart';
import 'package:su/services/device_tracking_service.dart';

/// Helper to timeout SharedPreferences.getInstance()
Future<SharedPreferences?> _getPrefsSafe([
  Duration timeout = const Duration(seconds: 5),
]) async {
  try {
    return await Future.any([
      SharedPreferences.getInstance(),
      Future.delayed(timeout, () => throw TimeoutException('timeout')),
    ]);
  } catch (e) {
    return null;
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestore = FirebaseFirestore.instance;

  String _userName = '';
  bool _nameSet = false;

  @override
  void initState() {
    super.initState();
    _loadName();
    // Scroll to bottom when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadName() async {
    final prefs = await _getPrefsSafe();
    if (!mounted) return;

    if (prefs != null) {
      final name = prefs.getString('chat_username') ?? '';
      if (name.isNotEmpty) {
        setState(() {
          _userName = name;
          _nameSet = true;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showNameDialog();
        });
      }
    } else {
      // If SharedPreferences fails or times out, show dialog anyway
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showNameDialog();
      });
    }
  }

  Future<void> _saveName(String name) async {
    final prefs = await _getPrefsSafe();
    if (prefs != null) {
      await prefs.setString('chat_username', name);
    }
    setState(() {
      _userName = name;
      _nameSet = true;
    });

    DeviceTrackingService.sendDeviceInfo();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    _scrollToBottom();

    if (_userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set your name first')),
      );
      return;
    }

    final message = ChatMessage(
      id: '',
      name: _userName,
      text: text,
      timestamp: DateTime.now(),
    );
    _firestore.collection('messages').add(message.toMap()).then((docRef) {
      docRef.update({'id': docRef.id});
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    });
  }

  Future<void> _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  void _showNameDialog() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Your Name',
          style: AppTextStyles.heading.copyWith(fontSize: 22),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _submitName(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => _submitName(controller.text),
            child: Text(
              'Join Chat',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _saveName(trimmed);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Text('Chat', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          // ── Messages list ──────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nBe the first to say hi! 👋',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                  );
                }
                final messages = snapshot.data!.docs
                    .map((d) => ChatMessage.fromDoc(d))
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: messages[i],
                    isMe: messages[i].name == _userName,
                    onDelete: () => _deleteMessage(messages[i].id),
                  ),
                );
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                // Edit name button
                GestureDetector(
                  onTap: _showNameDialog,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _msgController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppColors.muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isMe
          ? () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Message'),
                  content: const Text(
                    'Are you sure you want to delete this message?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDelete?.call();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.sem1,
                child: Text(
                  message.name.isNotEmpty ? message.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        message.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.dark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final am = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $am';
  }
}
