import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/controller/UploadDataController.dart';

class Profileview extends StatefulWidget {
  const Profileview({super.key});

  @override
  State<Profileview> createState() => _ProfileviewState();
}

class _ProfileviewState extends State<Profileview> {
  final AuthController authController = Get.find<AuthController>();
  final UploadDataController uploadDataController = Get.put(UploadDataController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Ensure the imageUrl in UploadDataController is initialized with current user's photoURL
    uploadDataController.imageUrl.value = _auth.currentUser?.photoURL ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 60,
                    backgroundImage: uploadDataController.imageUrl.value.isNotEmpty
                        ? NetworkImage(uploadDataController.imageUrl.value)
                        : const NetworkImage('https://www.gravatar.com/avatar?d=mp'), // Placeholder image
                  )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo, size: 30),
                      onPressed: uploadDataController.pickAndUploadImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'N/A',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                user?.email ?? 'N/A',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  authController.logout();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
