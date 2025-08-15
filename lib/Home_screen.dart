import 'package:flutter/material.dart';
import 'package:finance_app/view/ProfileScreen.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:finance_app/view/chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Increased length to 5
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finance App', style: TextStyle(color: Colors.black),),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.swap_horiz), text: 'Transactions'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Budget'),
              Tab(icon: Icon(Icons.chat), text: 'Chat'), // Added Chat tab
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeTabPage(),
            TransactionsTabPage(),
            BudgetTabPage(),
            ChatScreen(), // Added ChatScreen
            ProfileScreen(),
          ],
        ),
      ),
    );
  }
}

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Tab'),
          ],
        ),
      ),
    );
  }
}

class TransactionsTabPage extends StatelessWidget {
  const TransactionsTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: const Center(
        child: Text('Transactions Tab'),
      ),
    );
  }
}

class BudgetTabPage extends StatelessWidget {
  const BudgetTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: const Center(
        child: Text('Budget Tab'),
      ),
    );
  }
}

