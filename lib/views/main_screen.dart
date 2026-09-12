import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import '../controllers/main_controller.dart';
import '../utils/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'inventory/inventory_list_screen.dart';
import 'profile/profile_screen.dart';

import 'history/history_screen.dart';
import 'trade/trade_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    final List<Widget> screens = [
      DashboardScreen(),
      InventoryListScreen(),
      const TradeScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
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
              color: Colors.black.withValues(alpha: .1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Obx(() => GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 4,
              activeColor: AppColors.primary,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppColors.textSecondary,
              tabs: [
                const GButton(
                  icon: LineIcons.pieChart,
                  text: 'Home',
                ),
                const GButton(
                  icon: LineIcons.boxes,
                  text: 'Stock',
                ),
                const GButton(
                  icon: Icons.swap_horiz,
                  text: 'Trade',
                ),
                const GButton(
                  icon: LineIcons.history,
                  text: 'History',
                ),
                const GButton(
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
