import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final List<String> members;
  final String adminId;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;
  final String? lastMessageSenderId;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
    required this.adminId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTimestamp,
    this.lastMessageSenderId,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GroupModel(
      id: documentId,
      name: data['name'] as String,
      members: List<String>.from(data['members'] as List),
      adminId: data['adminId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'] as String?,
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'adminId': adminId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp != null ? Timestamp.fromDate(lastMessageTimestamp!) : null,
      'lastMessageSenderId': lastMessageSenderId,
    };
  }
}
