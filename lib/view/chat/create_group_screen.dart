import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance_app/controller/GroupChatController.dart';
import 'package:finance_app/controller/ChatController.dart'; // To get all users
import 'package:finance_app/model/UserDataModel.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final GroupChatController groupChatController = Get.find<GroupChatController>();
  final ChatController chatController = Get.find<ChatController>(); // To fetch all users
  final RxList<UserModel> _selectedMembers = <UserModel>[].obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                // Use StreamBuilder for fetching users
                return StreamBuilder<List<UserModel>>(
                  stream: chatController.fetchAllUsersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users available to add to group.'));
                }
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    UserModel user = users[index];
                    return Obx(() => CheckboxListTile(
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          value: _selectedMembers.contains(user),
                          onChanged: (bool? value) {
                            if (value == true) {
                              _selectedMembers.add(user);
                            } else {
                              _selectedMembers.remove(user);
                            }
                          },
                        ));
                  },
                ); // Close ListView.builder
                  }, // Close builder
                ); // Close StreamBuilder
              }),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: groupChatController.isCreatingGroup.value
                      ? null
                      : () {
                          if (_groupNameController.text.isNotEmpty && _selectedMembers.isNotEmpty) {
                            groupChatController.createGroup(
                              _groupNameController.text,
                              _selectedMembers.toList(),
                            );
                            Get.back(); // Go back after creating group
                          } else {
                            Get.snackbar('Error', 'Please enter group name and select at least one member.');
                          }
                        },
                  child: groupChatController.isCreatingGroup.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Group'),
                )),
          ],
        ),
      ),
    );
  }
}
