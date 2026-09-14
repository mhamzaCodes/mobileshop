import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'controllers/auth_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/main_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/security_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'utils/app_strings.dart';
import 'utils/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/app_lock_screen.dart';
import 'views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(MainController());
  Get.put(InventoryController());
  Get.put(TransactionController());
  Get.put(SecurityController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    final user = FirebaseAuth.instance.currentUser;
    final securityController = Get.find<SecurityController>();
    
    if (user != null) {
      if (securityController.isLockEnabled.value) {
        return const AppLockScreen();
      }
      return const MainScreen();
    }
    return LoginScreen();
  }
}
