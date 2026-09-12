import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/main_screen.dart';
import '../views/auth/login_screen.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login Form
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Register Form
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();
  final TextEditingController registerShopNameController = TextEditingController();
  final TextEditingController registerShopAddressController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  var currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  void login() async {
    if (loginFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        await _auth.signInWithEmailAndPassword(
          email: loginEmailController.text.trim(),
          password: loginPasswordController.text.trim(),
        );
        Get.offAll(() => const MainScreen());
      } on FirebaseAuthException catch (e) {
        Get.snackbar("Login Error", e.message ?? "An error occurred",
            backgroundColor: AppColors.error, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void register() async {
    if (registerFormKey.currentState!.validate()) {
      if (registerPasswordController.text != registerConfirmPasswordController.text) {
        Get.snackbar("Error", "Passwords do not match",
            backgroundColor: AppColors.error, colorText: Colors.white);
        return;
      }

      try {
        isLoading.value = true;
        // 1. Create User in Firebase Auth
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: registerEmailController.text.trim(),
          password: registerPasswordController.text.trim(),
        );

        if (result.user != null) {
          // 2. Prepare User Data (storing both for requirement)
          UserModel newUser = UserModel(
            uid: result.user!.uid,
            name: registerNameController.text.trim(),
            email: registerEmailController.text.trim(),
            shopName: registerShopNameController.text.trim(),
            address: registerShopAddressController.text.trim(),
            plaintextPassword: registerPasswordController.text, // User requirement
            createdAt: DateTime.now(),
          );

          // 3. Save to Firestore
          await _firestore.collection('users').doc(result.user!.uid).set(newUser.toMap());
          
          currentUser.value = newUser;
          Get.offAll(() => const MainScreen());
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar("Registration Error", e.message ?? "An error occurred",
            backgroundColor: AppColors.error, colorText: Colors.white);
      } catch (e) {
        Get.snackbar("Error", "Something went wrong",
            backgroundColor: AppColors.error, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerShopNameController.dispose();
    registerShopAddressController.dispose();
    super.onClose();
  }
}
