import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final String lastMessageSenderId;

  ChatModel({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSenderId,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatModel(
      id: documentId,
      participantIds: List<String>.from(data['participantIds'] as List),
      lastMessage: data['lastMessage'] as String,
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp).toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'lastMessageSenderId': lastMessageSenderId,
    };
  }
}
