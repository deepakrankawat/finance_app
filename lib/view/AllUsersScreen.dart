import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/model/UserDataModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: authController.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.photoUrl!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person);
                            },
                          ),
                        )
                      : const Icon(Icons.person),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: user.isOnline
                    ? const Icon(Icons.circle, color: Colors.green, size: 12)
                    : const Icon(Icons.circle, color: Colors.grey, size: 12),
              );
            },
          );
        },
      ),
    );
  }
}
