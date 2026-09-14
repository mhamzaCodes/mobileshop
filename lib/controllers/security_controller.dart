import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityController extends GetxController {
  final LocalAuthentication _auth = LocalAuthentication();
  final _storage = GetStorage();
  
  var isLockEnabled = false.obs;
  var isBiometricAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLockEnabled.value = _storage.read('isLockEnabled') ?? false;
    checkBiometrics();
  }

  Future<void> checkBiometrics() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();
      isBiometricAvailable.value = canCheck || isDeviceSupported;
    } catch (e) {
      isBiometricAvailable.value = false;
    }
  }

  void toggleAppLock(bool value) {
    isLockEnabled.value = value;
    _storage.write('isLockEnabled', value);
  }

  Future<bool> authenticate() async {
    if (!isLockEnabled.value) return true;

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to access your shop data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows PIN/Pattern/Password fallback
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      debugPrint("Authentication error: $e");
      return false;
    }
  }
}
