import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/main_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../inventory/add_edit_inventory_screen.dart';
import '../inventory/product_details_screen.dart';
import '../inventory/buy_product_screen.dart';
import '../inventory/sell_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final InventoryController inventoryController = Get.find<InventoryController>();
  final TransactionController transactionController = Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () => Get.to(() => const AddEditInventoryScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            inventoryController.update();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildFinanceOverview(context),
                const SizedBox(height: 24),
                _buildPeriodFilter(),
                const SizedBox(height: 16),
                _buildTransactionStats(),
                const SizedBox(height: 32),
                _buildChartSection(context),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.recentMobiles,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.find<MainController>().changeTabIndex(1);
                      },
                      child: const Text('View All', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRecentInventoryList(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good Morning,",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          "Shop Administrator",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: "Buy",
            icon: Icons.add_shopping_cart,
            color: AppColors.primary,
            onTap: () => Get.to(() => const BuyProductScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: "Sell",
            icon: Icons.sell_outlined,
            color: AppColors.success,
            onTap: () => Get.to(() => const SellProductScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceOverview(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Current Stock Value",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "PKR ${inventoryController.totalInvestment.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniFinanceItem(
                  label: "Profit Potential",
                  value: "PKR ${inventoryController.expectedProfit.toStringAsFixed(0)}",
                  icon: Icons.trending_up,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildMiniFinanceItem(
                  label: "Available",
                  value: "${inventoryController.totalDevicesAvailable} Units",
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMiniFinanceItem({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          final isSelected = transactionController.selectedPeriod.value == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) => transactionController.selectedPeriod.value = period,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildTransactionStats() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _TransactionStatTile(
              label: "Inflow (Sales)",
              value: "PKR ${transactionController.totalInflow.toStringAsFixed(0)}",
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TransactionStatTile(
              label: "Outflow (Purch)",
              value: "PKR ${transactionController.totalOutflow.toStringAsFixed(0)}",
              color: AppColors.error,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stock Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Obx(() {
            final data = inventoryController.brandDistribution;
            if (data.isEmpty) return const Center(child: Text("No stock data."));

            final colors = [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.success, AppColors.warning];
            int index = 0;

            return Column(
              children: [
                SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.entries.map((e) {
                        final color = colors[index++ % colors.length];
                        return PieChartSectionData(
                          color: color,
                          value: e.value,
                          title: "",
                          radius: 20,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: data.entries.toList().asMap().entries.map((entry) {
                    final color = colors[entry.key % colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(entry.value.key, style: const TextStyle(fontSize: 11)),
                      ],
                    );
                  }).toList(),
                )
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecentInventoryList(BuildContext context) {
    return Obx(() {
      final recentItems = inventoryController.inventoryList.reversed.take(5).toList();
      if (recentItems.isEmpty) return const Center(child: Text("Nothing here yet."));
      return Column(
        children: recentItems.map((item) => _ActivityTile(item: item)).toList(),
      );
    });
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TransactionStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TransactionStatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final dynamic item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(device: item)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${item.brand} ${item.model}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("${item.ram}/${item.storage} • ${item.networkStatus}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("PKR ${item.sellingPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (item.status == 'Available' ? AppColors.success : AppColors.textSecondary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.status == 'Available' ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
