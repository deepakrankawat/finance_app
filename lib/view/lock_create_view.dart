import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/lock_controller.dart';
import 'lock_view.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController pinController = TextEditingController();
  final LockController lockController = Get.find<LockController>();

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = pinController.text.trim();

    // ✅ Check if pin is 4 or 6 digits and only numbers
    if (!RegExp(r'^\d{4}$|^\d{6}$').hasMatch(pin)) {
      Get.snackbar("Invalid PIN", "PIN must be 4 or 6 digits long.");
      return;
    }

    await lockController.setPin(pin);
    lockController.isLocked.value = true;
    lockController.hasPin.value = true;

    Get.offAll(() => LockScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Set a 4 or 6 digit PIN to secure your app",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Enter new PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text("Save PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
