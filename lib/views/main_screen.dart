import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import '../controllers/main_controller.dart';
import '../utils/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'inventory/inventory_list_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    final List<Widget> screens = [
      DashboardScreen(),
      InventoryListScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Obx(() => GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: AppColors.primary,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withOpacity(0.1),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.textSecondary,
              tabs: const [
                GButton(
                  icon: LineIcons.pieChart,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: LineIcons.boxes,
                  text: 'Inventory',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: controller.selectedIndex.value,
              onTabChange: controller.changeTabIndex,
            )),
          ),
        ),
      ),
    );
  }
}
