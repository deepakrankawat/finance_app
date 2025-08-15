import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class LockController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  RxBool isLocked = true.obs;
  RxString pinCode = ''.obs;
  RxBool hasPin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initLockState();
  }

  /// Initialize PIN state on app launch
  Future<void> _initLockState() async {
    final pin = await _storage.read(key: "app_pin");
    hasPin.value = pin != null;

    if (hasPin.value) {
      isLocked.value = true; // start locked
      await authenticateWithBiometrics(); // try biometric auto-unlock
    }
  }

  /// Save PIN securely
  Future<void> setPin(String pin) async {
    await _storage.write(key: "app_pin", value: pin);
    pinCode.value = pin;
    hasPin.value = true;
    isLocked.value = true; // Lock after setting PIN
  }

  /// Check entered PIN
  Future<bool> checkPin(String input) async {
    final storedPin = await _storage.read(key: "app_pin");
    if (storedPin != null && input == storedPin) {
      isLocked.value = false;
      return true;
    }
    return false;
  }

  /// Unlock using biometrics
 Future<bool> authenticateWithBiometrics() async {
  try {
    final localAuth = LocalAuthentication();

    // ✅ Check support
    bool isSupported = await localAuth.isDeviceSupported();
    if (!isSupported) {
      Get.snackbar("Biometric Error", "Device not supported");
      return false;
    }

    // ✅ Check available biometrics
    bool canCheck = await localAuth.canCheckBiometrics;
    if (!canCheck) {
      Get.snackbar("Biometric Error", "Biometric not available");
      return false;
    }

    // ✅ Authenticate
    final didAuth = await localAuth.authenticate(
      localizedReason: 'Authenticate to unlock app',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (didAuth) {
      isLocked.value = false;
    }

    return didAuth;
  } catch (e) {
    debugPrint("Biometric error: $e");
    Get.snackbar("Biometric Failed", e.toString());
    return false;
  }
}
  /// Lock the app manually
  void lockApp() {
    isLocked.value = true;
  }

}