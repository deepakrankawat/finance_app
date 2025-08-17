
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:finance_app/model/MessageModel.dart';
import 'package:finance_app/model/ChatModel.dart';
import 'package:finance_app/model/GroupModel.dart';
import 'package:finance_app/model/UserDataModel.dart';

class ChatService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Get all users stream
  Stream<List<UserModel>> getAllUsersStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((user) => user.uid != currentUser?.uid)
        .toList());
  }

  // Get chat ID for one-on-one chat
  String getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Send a message in a one-on-one chat
  Future<void> sendMessage(String receiverId, String content) async {
    if (currentUser == null || content.trim().isEmpty) return;

    final String currentUserId = currentUser!.uid;
    final String chatId = getChatId(currentUserId, receiverId);

    final MessageModel newMessage = MessageModel(
      id: '', // Firestore will generate this
      senderId: currentUserId,
      receiverId: receiverId,
      content: content.trim(),
      timestamp: DateTime.now(),
      type: 'text',
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());

    await _firestore.collection('chats').doc(chatId).set(
      {
        'participantIds': [currentUserId, receiverId],
        'lastMessage': content.trim(),
        'lastMessageTimestamp': Timestamp.fromDate(newMessage.timestamp),
        'lastMessageSenderId': currentUserId,
      },
      SetOptions(merge: true),
    );
  }

  // Get messages for a one-on-one chat
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final String currentUserId = currentUser!.uid;
    final String chatId = getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all one-on-one chats for the current user
  Stream<List<ChatModel>> getUserChats() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create a new group
  Future<void> createGroup(String groupName, List<UserModel> selectedMembers) async {
    if (currentUser == null ||
        groupName.trim().isEmpty ||
        selectedMembers.isEmpty) {
      Get.snackbar('Error', 'Group name and members cannot be empty.');
      return;
    }

    final String currentUserId = currentUser!.uid;
    List<String> memberUids =
        selectedMembers.map((user) => user.uid).toList();
    if (!memberUids.contains(currentUserId)) {
      memberUids.add(currentUserId);
    }

    final GroupModel newGroup = GroupModel(
      id: '', // Firestore will generate this
      name: groupName.trim(),
      members: memberUids,
      adminId: currentUserId,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('groups').add(newGroup.toMap());
    Get.snackbar('Success', 'Group "$groupName" created successfully!');
  }

  // Send a message in a group chat
  Future<void> sendGroupMessage(String groupId, String content) async {
    if (currentUser == null || content.trim().isEmpty) return;

    final String currentUserId = currentUser!.uid;

    final MessageModel newMessage = MessageModel(
      id: '', // Firestore will generate this
      senderId: currentUserId,
      groupId: groupId,
      content: content.trim(),
      timestamp: DateTime.now(),
      type: 'text',
    );

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(newMessage.toMap());

    await _firestore.collection('groups').doc(groupId).set(
      {
        'lastMessage': content.trim(),
        'lastMessageTimestamp': Timestamp.fromDate(newMessage.timestamp),
        'lastMessageSenderId': currentUserId,
      },
      SetOptions(merge: true),
    );
  }

  // Get messages for a group chat
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all groups for the current user
  Stream<List<GroupModel>> getUserGroupsStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
