import 'package:finance_app/view/AllUsersScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Dashboard Screen", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const AllUsersScreen());
            },
            child: const Text('View All Users'),
          ),
        ],
      ),
    );
  }
}
