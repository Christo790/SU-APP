import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String   id;
  final String   name;
  final String   text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.name,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id:        doc.id,
      name:      data['name']      as String?    ?? 'Anonymous',
      text:      data['text']      as String?    ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name':      name,
    'text':      text,
    'timestamp': FieldValue.serverTimestamp(),
  };
}