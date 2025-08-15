// lib/view/otp_view.dart
import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/view/Phone_number_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OtpView extends StatelessWidget {
  final otpController = TextEditingController();
  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Obx(() => auth.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      auth.verifyOTP(otpController.text.trim(), "+91");
                    },
                    child: const Text("Verify"),
                  )),
          ],
        ),
      ),
    );
  }
}
