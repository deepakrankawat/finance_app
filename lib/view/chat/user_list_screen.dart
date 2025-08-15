import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance_app/controller/ChatController.dart';
import 'package:finance_app/model/UserDataModel.dart';
import 'package:finance_app/view/chat/chat_screen.dart';

class UserListScreen extends StatelessWidget {
  final ChatController chatController = Get.find<ChatController>();

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a New Chat'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: chatController.fetchAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserModel user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                title: Row(
                  children: [
                    Text(user.name),
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(user.email),
                onTap: () {
                  Get.to(() => ChatScreen(
                        receiverId: user.uid,
                        receiverName: user.name,
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }
}