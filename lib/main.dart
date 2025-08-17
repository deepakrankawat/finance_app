
import 'package:finance_app/MyApp.dart';
import 'package:finance_app/controller/ChatController.dart';
import 'package:finance_app/controller/auth_controller.dart';
import 'package:finance_app/controller/lock_controller.dart';
import 'package:finance_app/firebase_options.dart';
import 'package:finance_app/services/chat_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/instance_manager.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   await FirebaseAppCheck.instance.activate(
    // For Android, use PlayIntegrityProvider (recommended) or SafetyNetProvider.
    // You must register your app's SHA-256 fingerprint in the Firebase console.
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // androidProvider: AndroidProvider.safetyNet, // Alternative for older devices
    // androidProvider: AndroidProvider.debug, // For local development/testing (requires debug token registration)

    // For iOS, use AppleProvider.appAttest (recommended for iOS 14.0+) or .deviceCheck.
    // You might need to enable App Attest capability in Xcode.
    appleProvider: AppleProvider.appAttest, // Recommended for iOS 14.0+
    // appleProvider: AppleProvider.deviceCheck, // For older iOS versions
    // appleProvider: AppleProvider.debug, // For local development/testing (requires debug token registration)
  );
  if (kDebugMode) {
    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      // ignore: avoid_print
      print("App Check token: $token");
    });
  }
  Get.put(AuthController());     // Initialize auth controller
  Get.put(LockController());     // LockController will auto-run onInit()
     // Initialize ChatController

  runApp(const MyApp());
}

