
import 'package:finance_app/controller/ChatController.dart';
import 'package:get/get.dart';
import 'package:finance_app/services/chat_service.dart';


class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatService());
    Get.lazyPut(() => ChatController(chatService: Get.find<ChatService>()));
  }
}
