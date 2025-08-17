
import 'package:get/get.dart';
import 'package:finance_app/services/chat_service.dart';
import 'package:finance_app/model/MessageModel.dart';
import 'package:finance_app/model/ChatModel.dart';
import 'package:finance_app/model/GroupModel.dart';
import 'package:finance_app/model/UserDataModel.dart';

class ChatController extends GetxController {
  final ChatService chatService;

  ChatController({required this.chatService});

  // Observables
  final RxList<ChatModel> userChats = <ChatModel>[].obs;
  final RxList<GroupModel> userGroups = <GroupModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind streams to observables
    userChats.bindStream(chatService.getUserChats());
    userGroups.bindStream(chatService.getUserGroupsStream());
  }

  // Get messages for a specific chat (one-on-one or group)
  void getMessages(String chatId, bool isGroup) {
    messages.bindStream(isGroup
        ? chatService.getGroupMessages(chatId)
        : chatService.getMessages(chatId));
  }

  // Send a message
  Future<void> sendMessage(String chatId, String content, bool isGroup) async {
    isLoading.value = true;
    if (isGroup) {
      await chatService.sendGroupMessage(chatId, content);
    } else {
      await chatService.sendMessage(chatId, content);
    }
    isLoading.value = false;
  }

  // Create a group
  Future<void> createGroup(String groupName, List<UserModel> selectedMembers) async {
    isLoading.value = true;
    await chatService.createGroup(groupName, selectedMembers);
    isLoading.value = false;
  }

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return chatService.getAllUsersStream();
  }
}
