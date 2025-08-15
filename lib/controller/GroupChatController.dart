import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_app/model/UserDataModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:finance_app/model/GroupModel.dart';
import 'package:finance_app/model/MessageModel.dart';
// Assuming UserDataModel for selecting members

class GroupChatController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<GroupModel> userGroups = <GroupModel>[].obs;
  RxList<MessageModel> groupMessages = <MessageModel>[].obs;
  RxBool isLoadingGroups = false.obs;
  RxBool isCreatingGroup = false.obs;
  RxBool isSendingGroupMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserGroups();
  }

  // Fetch groups the current user is a member of
  void fetchUserGroups() {
    if (_auth.currentUser == null) return;

    isLoadingGroups.value = true;
    _firestore
        .collection('groups')
        .where('members', arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      userGroups.value = snapshot.docs
          .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
          .toList();
      isLoadingGroups.value = false;
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to fetch groups: $error');
      isLoadingGroups.value = false;
    });
  }

  // Create a new group
  Future<void> createGroup(String groupName, List<UserModel> selectedMembers) async {
    if (_auth.currentUser == null || groupName.trim().isEmpty || selectedMembers.isEmpty) {
      Get.snackbar('Error', 'Group name and members cannot be empty.');
      return;
    }

    isCreatingGroup.value = true;
    try {
      final String currentUserId = _auth.currentUser!.uid;
      List<String> memberUids = selectedMembers.map((user) => user.uid).toList();
      if (!memberUids.contains(currentUserId)) {
        memberUids.add(currentUserId); // Ensure creator is a member
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
    } finally {
      isCreatingGroup.value = false;
    }
  }

  // Send a message in a group chat
  Future<void> sendGroupMessage(String groupId, String content) async {
    if (_auth.currentUser == null || content.trim().isEmpty) return;

    isSendingGroupMessage.value = true;
    try {
      final String currentUserId = _auth.currentUser!.uid;

      final MessageModel newMessage = MessageModel(
        id: '', // Firestore will generate this
        senderId: currentUserId,
        groupId: groupId,
        content: content.trim(),
        timestamp: DateTime.now(),
        type: 'text',
      );

      // Add message to the group's messages subcollection
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add(newMessage.toMap());

      // Update GroupModel (last message, timestamp)
      await _firestore.collection('groups').doc(groupId).set(
        {
          'lastMessage': content.trim(),
          'lastMessageTimestamp': Timestamp.fromDate(newMessage.timestamp),
          'lastMessageSenderId': currentUserId,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send group message: $e');
    } finally {
      isSendingGroupMessage.value = false;
    }
  }

  // Listen for messages in a specific group chat
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

  // New method to get all groups for the current user
  Stream<List<GroupModel>> getUserGroupsStream() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('groups')
        .where('members', arrayContains: _auth.currentUser!.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
