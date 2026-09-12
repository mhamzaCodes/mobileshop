import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: authController.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Professional Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                
                // Shop Name
                _buildTextField(
                  controller: authController.registerShopNameController,
                  label: "Shop Name",
                  icon: Icons.store_mall_directory_outlined,
                  validator: (v) => v!.isEmpty ? "Enter shop name" : null,
                ),
                const SizedBox(height: 16),
                
                // Shop Address
                _buildTextField(
                  controller: authController.registerShopAddressController,
                  label: "Shop Address",
                  icon: Icons.location_on_outlined,
                  validator: (v) => v!.isEmpty ? "Enter shop address" : null,
                ),
                const SizedBox(height: 24),
                
                const Text(
                  "Account Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),

                // Name
                _buildTextField(
                  controller: authController.registerNameController,
                  label: AppStrings.nameLabel,
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? AppStrings.errorEmptyName : null,
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: authController.registerEmailController,
                  label: AppStrings.emailLabel,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !GetUtils.isEmail(v!) ? AppStrings.errorInvalidEmail : null,
                ),
                const SizedBox(height: 16),
                
                // Password
                Obx(() => _buildTextField(
                  controller: authController.registerPasswordController,
                  label: AppStrings.passwordLabel,
                  icon: Icons.lock_outline,
                  obscureText: authController.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(authController.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
                    onPressed: authController.togglePasswordVisibility,
                  ),
                  validator: (v) => v!.length < 6 ? AppStrings.errorShortPassword : null,
                )),
                const SizedBox(height: 16),

                // Confirm Password
                Obx(() => _buildTextField(
                  controller: authController.registerConfirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_reset_outlined,
                  obscureText: authController.isConfirmPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(authController.isConfirmPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
                    onPressed: authController.toggleConfirmPasswordVisibility,
                  ),
                  validator: (v) => v != authController.registerPasswordController.text ? "Passwords match error" : null,
                )),
                
                const SizedBox(height: 32),
                
                Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value ? null : authController.register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(AppStrings.registerButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.haveAccountText),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(AppStrings.loginNow, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
