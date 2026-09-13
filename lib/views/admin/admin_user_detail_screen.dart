import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/main_controller.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final UserModel user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final AuthController authController = Get.find<AuthController>();
  final MainController mainController = Get.find<MainController>();
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.user.plaintextPassword ?? "");
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _impersonateUser() {
    authController.selectUserAsAdmin(widget.user);
    mainController.changeTabIndex(0); // Go to Dashboard
    Get.snackbar(
      "Mode Switched", 
      "You are now viewing as ${widget.user.shopName}",
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.back(); // Back to list
  }

  void _updatePassword() {
    if (_passwordController.text.trim().length < 6) {
      Get.snackbar("Error", "Password too short", backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }
    authController.updateUserPassword(widget.user.uid, _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 32),
            const Text("Manage Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPasswordCard(),
            const SizedBox(height: 32),
            const Text("Access Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.store, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(widget.user.shopName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(widget.user.address, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Chip(
            label: Text(widget.user.email),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Recorded Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text("Update Record", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _ActionButton(
          label: "View This Shop's Dashboard",
          icon: Icons.dashboard_outlined,
          color: AppColors.primary,
          onTap: _impersonateUser,
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: "Reset to My Own View",
          icon: Icons.refresh_outlined,
          color: AppColors.textSecondary,
          onTap: () {
            authController.selectUserAsAdmin(null);
            Get.snackbar("Reset", "Now viewing your own data");
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
