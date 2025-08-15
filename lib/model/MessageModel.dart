import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String? receiverId; // Null for group messages
  final String? groupId;    // Null for one-on-one messages
  final String content;
  final DateTime timestamp;
  final String type; // e.g., 'text', 'image', 'video'

  MessageModel({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  // Factory constructor to create a MessageModel from a Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MessageModel(
      id: documentId,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String?,
      groupId: data['groupId'] as String?,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] as String,
    );
  }

  // Method to convert a MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
    };
  }
}
