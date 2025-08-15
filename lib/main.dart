
import 'package:finance_app/controller/ChatController.dart';
import 'package:finance_app/controller/GroupChatController.dart';
import 'package:finance_app/view/lock_create_view.dart';
import 'package:finance_app/view/lock_view.dart';
import 'package:finance_app/view/login_view.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'MyApp.dart';
import 'controller/auth_controller.dart';
import 'controller/lock_controller.dart';
import 'firebase_options.dart';
import 'view/home_view.dart';
import 'view/otp_screen.dart';
import 'view/phone_number_auth.dart';
import 'view/signup_view.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await FirebaseAppCheck.instance.activate(
    // For Android, use PlayIntegrityProvider (recommended) or SafetyNetProvider.
    // You must register your app's SHA-256 fingerprint in the Firebase console.
    androidProvider: AndroidProvider.playIntegrity, // Recommended for new apps
    // androidProvider: AndroidProvider.safetyNet, // Alternative for older devices
    // androidProvider: AndroidProvider.debug, // For local development/testing (requires debug token registration)

    // For iOS, use AppleProvider.appAttest (recommended for iOS 14.0+) or .deviceCheck.
    // You might need to enable App Attest capability in Xcode.
    appleProvider: AppleProvider.appAttest, // Recommended for iOS 14.0+
    // appleProvider: AppleProvider.deviceCheck, // For older iOS versions
    // appleProvider: AppleProvider.debug, // For local development/testing (requires debug token registration)
  );
  Get.put(AuthController());     // Initialize auth controller
  Get.put(LockController());     // LockController will auto-run onInit()
  Get.put(ChatController());     // Initialize ChatController
  Get.put(GroupChatController()); // Initialize GroupChatController
  runApp(const MyApp());
}

