import 'package:finance_app/Home_screen.dart';
import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/view/AllUsersScreen.dart';
import 'package:finance_app/view/FullScreenImageView.dart';
import 'package:finance_app/view/NotesScreen.dart';
import 'package:finance_app/view/ProfileScreen.dart';



import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
        
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.swap_horiz), text: 'Transactions'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Budget'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            NotesScreen(),
            const Center(child: Text('Home')),
            Profileview(),
          ],
        ),
      ),
    );
  }
}