import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/main_screen.dart';
import '../views/auth/login_screen.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import 'main_controller.dart';

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
  var isAdmin = false.obs;
  var selectedUserForAdmin = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        isAdmin.value = user.email?.endsWith('@admin.com') ?? false;
        _fetchUserData(user.uid);
      } else {
        currentUser.value = null;
        isAdmin.value = false;
        selectedUserForAdmin.value = null;
      }
    });
  }

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  void _clearForms() {
    loginEmailController.clear();
    loginPasswordController.clear();
    registerNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerShopNameController.clear();
    registerShopAddressController.clear();
  }

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
        _clearForms();
        Get.find<MainController>().changeTabIndex(0);
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
          _clearForms();
          Get.find<MainController>().changeTabIndex(0);
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

  Future<void> updateUserDetails({required String name, required String shopName}) async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'shopName': shopName,
      });

      // Update local state
      if (currentUser.value != null) {
        currentUser.value = UserModel(
          uid: currentUser.value!.uid,
          name: name,
          email: currentUser.value!.email,
          shopName: shopName,
          address: currentUser.value!.address,
          plaintextPassword: currentUser.value!.plaintextPassword,
          createdAt: currentUser.value!.createdAt,
        );
      }

      Get.snackbar("Success", "Profile updated successfully",
          backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e",
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeUserPassword({required String oldPassword, required String newPassword}) async {
    try {
      isLoading.value = true;
      User user = _auth.currentUser!;
      String email = user.email!;

      // 1. Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      // 2. Update password in Firebase Auth
      await user.updatePassword(newPassword);

      // 3. Update plaintext password in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'plaintextPassword': newPassword,
      });

      // Update local state
      if (currentUser.value != null) {
        currentUser.value = UserModel(
          uid: currentUser.value!.uid,
          name: currentUser.value!.name,
          email: currentUser.value!.email,
          shopName: currentUser.value!.shopName,
          address: currentUser.value!.address,
          plaintextPassword: newPassword,
          createdAt: currentUser.value!.createdAt,
        );
      }

      Get.snackbar("Success", "Password changed successfully",
          backgroundColor: AppColors.success, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed to change password",
          backgroundColor: AppColors.error, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserPassword(String uid, String newPassword) async {
    try {
      isLoading.value = true;
      await _firestore.collection('users').doc(uid).update({
        'plaintextPassword': newPassword,
      });
      
      // Update local state if the admin is viewing this user
      if (selectedUserForAdmin.value?.uid == uid) {
        selectedUserForAdmin.value = UserModel(
          uid: selectedUserForAdmin.value!.uid,
          name: selectedUserForAdmin.value!.name,
          email: selectedUserForAdmin.value!.email,
          shopName: selectedUserForAdmin.value!.shopName,
          address: selectedUserForAdmin.value!.address,
          plaintextPassword: newPassword,
          createdAt: selectedUserForAdmin.value!.createdAt,
        );
      }
      
      Get.snackbar("Success", "Password updated in records",
          backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to update password: $e",
          backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => !user.email.endsWith('@admin.com')) // Hide other admins from list
          .toList();
    });
  }

  void selectUserAsAdmin(UserModel? user) {
    selectedUserForAdmin.value = user;
  }

  void logout() async {
    await _auth.signOut();
    Get.find<MainController>().changeTabIndex(0);
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
