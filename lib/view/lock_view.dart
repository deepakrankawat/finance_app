import 'package:finance_app/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/lock_controller.dart';
import '../controller/auth_controller.dart';
import 'home_view.dart';


class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController pinController = TextEditingController();
  final LockController lockController = Get.find<LockController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void _navigatePostUnlock() {
    if (authController.isLoggedIn.value) {
      Get.offAll(() => const HomeView());
    } else {
      Get.offAll(() => const LoginView());
    }
  }

  Future<void> _handlePinUnlock() async {
    final inputPin = pinController.text.trim();
    final success = await lockController.checkPin(inputPin);
    if (success) {
      lockController.isLocked.value = false;
      _navigatePostUnlock();
    } else {
      Get.snackbar("Error", "Incorrect PIN");
    }
  }

  Future<void> _handleBiometricUnlock() async {
    final success = await lockController.authenticateWithBiometrics();
    if (success) {
      lockController.isLocked.value = false;
      _navigatePostUnlock();
    } else {
      Get.snackbar("Error", "Biometric authentication failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unlock App")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 60),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Enter PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handlePinUnlock,
              child: const Text("Unlock with PIN"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleBiometricUnlock,
              child: const Text("Use Biometric"),
            ),
          ],
        ),
      ),
    );
  }
}
