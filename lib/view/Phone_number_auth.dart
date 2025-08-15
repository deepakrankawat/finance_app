// lib/view/phone_login_view.dart
import 'package:finance_app/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PhoneLoginView extends StatelessWidget {
  final phoneController = TextEditingController();
  final auth = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixText: "+91 ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Obx(() => auth.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      auth.verifyPhone("+91${phoneController.text.trim()}");
                    },
                    child: const Text("Send OTP"),
                  )),
          ],
        ),
      ),
    );
  }
}
