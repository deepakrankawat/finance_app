import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_app/model/UserDataModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:finance_app/model/MessageModel.dart';
import 'package:finance_app/model/ChatModel.dart'; // Import ChatModel
// Assuming you have a UserDataModel for fetching users

class ChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxList<UserModel> allUsers = <UserModel>[].obs;
  RxBool isSendingMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchAllUsers(); // Removed as it will be a stream
  }

  // Fetch all users for starting new chats (now a stream)
  Stream<List<UserModel>> fetchAllUsersStream() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }
    return _firestore.collection('users').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .where((user) => user.uid != _auth.currentUser?.uid) // Exclude current user
            .toList());
  }

  // Get chat ID for one-on-one chat
  String getChatId(String userId1, String userId2) {
    // Ensure consistent chat ID by sorting UIDs
    return userId1.compareTo(userId2) < 0 ? '${userId1}_$userId2' : '${userId2}_$userId1';
  }

  // Send a message in a one-on-one chat
  Future<void> sendMessage(String receiverId, String content) async {
    if (_auth.currentUser == null || content.trim().isEmpty) return;

    isSendingMessage.value = true;
    try {
      final String currentUserId = _auth.currentUser!.uid;
      final String chatId = getChatId(currentUserId, receiverId);

      final MessageModel newMessage = MessageModel(
        id: '', // Firestore will generate this
        senderId: currentUserId,
        receiverId: receiverId,
        content: content.trim(),
        timestamp: DateTime.now(),
        type: 'text',
      );

      // Add message to the chat's messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(newMessage.toMap());

      // Update ChatModel (last message, timestamp)
      await _firestore.collection('chats').doc(chatId).set(
        {
          'participantIds': [currentUserId, receiverId],
          'lastMessage': content.trim(),
          'lastMessageTimestamp': Timestamp.fromDate(newMessage.timestamp),
          'lastMessageSenderId': currentUserId,
        },
        SetOptions(merge: true), // Use merge to update existing fields
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Listen for messages in a specific one-on-one chat
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final String currentUserId = _auth.currentUser!.uid;
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

  // New method to get all one-on-one chats for the current user
  Stream<List<ChatModel>> getUserChats() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: _auth.currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}