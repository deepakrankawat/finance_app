
import 'dart:async';
import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/controller/lock_controller.dart';
import 'package:finance_app/view/home_view.dart';
import 'package:finance_app/view/lock_create_view.dart';
import 'package:finance_app/view/lock_view.dart';
import 'package:finance_app/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        final authController = Get.find<AuthController>();
        final lockController = Get.find<LockController>();

        Get.off(
          () {
            if (lockController.hasPin.value == false && lockController.isLocked.value == false) {
              return const CreatePinScreen();
            }
            if (!lockController.hasPin.value) {
              return const CreatePinScreen();  // 1️⃣ No PIN created
            }

            if (lockController.isLocked.value) {
              return const LockScreen();       // 2️⃣ PIN exists but locked
            }

            if (authController.isLoggedIn.value) {
              return const HomeView();         // 3️⃣ Logged in
            }

            return const LoginView();          // 4️⃣ Default = Login
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Finance App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
