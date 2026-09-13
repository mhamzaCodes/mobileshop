import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Obx(() => Text(
                authController.currentUser.value?.name ?? 'Shop Admin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                authController.currentUser.value?.shopName ?? 'Store Name',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(height: 8),
              Obx(() => Text(
                authController.currentUser.value?.email ?? 'admin@mobileshop.com',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                authController.currentUser.value?.address ?? 'Shop Address',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              )),
              const SizedBox(height: 48),
              
              // Settings Options
              // _buildProfileOption(
              //   context,
              //   icon: Icons.store,
              //   title: 'Shop Details',
              //   onTap: () {},
              // ),

              _buildProfileOption(
                context,
                icon: Icons.edit,
                title: 'Update Profile',
                onTap: () => _showUpdateProfileDialog(context),
              ),

              _buildProfileOption(
                context,
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              
              // Theme Toggle
              Card(
                color: Theme.of(context).cardColor,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.grey[800]! : AppColors.border),
                ),
                child: Obx(() => SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                  title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  value: themeController.isDarkMode.value,
                  onChanged: (val) => themeController.toggleTheme(),
                  activeColor: AppColors.primary,
                )),
              ),

              // _buildProfileOption(
              //   context,
              //   icon: Icons.settings,
              //   title: 'Settings',
              //   onTap: () {},
              // ),
              // _buildProfileOption(
              //   context,
              //   icon: Icons.help_outline,
              //   title: 'Help & Support',
              //   onTap: () {},
              // ),
              
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => authController.logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final nameController = TextEditingController(text: authController.currentUser.value?.name);
    final shopNameController = TextEditingController(text: authController.currentUser.value?.shopName);

    Get.dialog(
      AlertDialog(
        title: const Text("Update Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: shopNameController,
              decoration: const InputDecoration(labelText: "Shop Name"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              authController.updateUserDetails(
                name: nameController.text.trim(),
                shopName: shopNameController.text.trim(),
              );
              Get.back();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar("Error", "Passwords do not match", backgroundColor: AppColors.error, colorText: Colors.white);
                return;
              }
              authController.changeUserPassword(
                oldPassword: oldPasswordController.text,
                newPassword: newPasswordController.text,
              );
              Get.back();
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
        trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
