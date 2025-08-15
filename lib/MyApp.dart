import 'package:finance_app/view/ProfileScreen.dart';
import 'package:finance_app/view/splash_screen.dart';
import 'package:finance_app/view/chat/chat_screen.dart';
import 'package:finance_app/view/chat/create_group_screen.dart';
import 'package:finance_app/view/chat/group_chat_screen.dart';
import 'package:finance_app/view/chat/group_list_screen.dart';
import 'package:finance_app/view/chat/user_list_screen.dart';
import 'package:finance_app/view/lock_create_view.dart';
import 'package:finance_app/view/lock_view.dart';
import 'package:finance_app/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controller/auth_controller.dart';
import 'controller/lock_controller.dart';
import 'firebase_options.dart';
import 'view/home_view.dart';
import 'view/otp_screen.dart';
import 'view/phone_number_auth.dart';
import 'view/signup_view.dart';
import 'package:finance_app/view/chat/chat_list_screen.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final lockController = Get.find<LockController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',

      // 🌟 Main Home Logic: Fully Reactive
      home: const SplashScreen(),

      // Optional: App routes
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/signup', page: () => const SignupView()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/phone', page: () => PhoneLoginView()),
        GetPage(name: '/otp', page: () => OtpView()),
        GetPage(name: '/chat/list', page: () => ChatListScreen()),
        GetPage(name: '/chat/users', page: () => UserListScreen()),
        GetPage(name: '/chat/one_on_one', page: () => ChatScreen(receiverId: Get.arguments['receiverId'], receiverName: Get.arguments['receiverName'])),
        GetPage(name: '/chat/groups', page: () => GroupListScreen()),
        GetPage(name: '/chat/create_group', page: () => CreateGroupScreen()),
        GetPage(name: '/chat/group_chat', page: () => GroupChatScreen(groupId: Get.arguments['groupId'], groupName: Get.arguments['groupName'])),
      ],
    );
  }
}
