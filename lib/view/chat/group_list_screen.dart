import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance_app/controller/GroupChatController.dart';
import 'package:finance_app/model/GroupModel.dart';
import 'package:finance_app/view/chat/group_chat_screen.dart'; // Will create this next
import 'package:finance_app/view/chat/create_group_screen.dart'; // Will create this next

class GroupListScreen extends StatelessWidget {
  final GroupChatController groupChatController = Get.find<GroupChatController>();

  GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Get.to(() => CreateGroupScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (groupChatController.isLoadingGroups.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (groupChatController.userGroups.isEmpty) {
          return const Center(child: Text('No groups found. Create one!'));
        }
        return ListView.builder(
          itemCount: groupChatController.userGroups.length,
          itemBuilder: (context, index) {
            GroupModel group = groupChatController.userGroups[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.group),
              ),
              title: Text(group.name),
              subtitle: Text('Members: ${group.members.length}'),
              onTap: () {
                Get.to(() => GroupChatScreen(
                      groupId: group.id,
                      groupName: group.name,
                    ));
              },
            );
          },
        );
      }),
    );
  }
}
