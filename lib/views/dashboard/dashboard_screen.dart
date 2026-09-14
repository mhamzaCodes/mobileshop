import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../inventory/product_details_screen.dart';
import '../inventory/buy_product_screen.dart';
import '../inventory/sell_product_screen.dart';
import '../../utils/formatters.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final InventoryController inventoryController = Get.find<InventoryController>();
  final TransactionController transactionController = Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 24),
                _buildFinanceSummary(context),
                const SizedBox(height: 24),
                _buildQuickActionsTitle(),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 32),
                _buildSectionHeader("Cash Flow Cockpit", trailing: _buildPeriodSelector(context)),
                const SizedBox(height: 16),
                _buildTransactionMatrix(),
                const SizedBox(height: 24),
                _buildBarChart(context),
                const SizedBox(height: 32),
                _buildSectionHeader("Stock Insights"),
                const SizedBox(height: 16),
                _buildInventoryChart(context),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  AppStrings.recentMobiles,
                  trailing: TextButton(
                    onPressed: () => Get.find<MainController>().changeTabIndex(1),
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                _buildActivityFeed(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17) {
      greeting = "Good Evening";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$greeting,",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
            Obx(() => Text(
              authController.currentUser.value?.shopName ?? "My Mobile Shop",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            )),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
        )
      ],
    );
  }

  Widget _buildFinanceSummary(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Current Stock Value", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.formatCurrency(inventoryController.currentStockValue),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
            ),
            const Text("Total buying cost of available phones", style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildFinanceMetric("Profit Potential", AppFormatters.formatCurrency(inventoryController.expectedProfit), Icons.trending_up, subtitle: "Expected gain"),
                const Spacer(),
                _buildFinanceMetric("In Shop", "${inventoryController.totalDevicesAvailable} Units", Icons.inventory_2_outlined, subtitle: "Total available"),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFinanceMetric(String label, String value, IconData icon, {required String subtitle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 8)),
          ],
        )
      ],
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5));
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: "Buy Product",
            subtitle: "Add from seller",
            icon: Icons.add_shopping_cart_rounded,
            color: AppColors.primary,
            onTap: () => Get.to(() => const BuyProductScreen()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            label: "Sell Product",
            subtitle: "Direct Customer Sale",
            icon: Icons.sell_rounded,
            color: const Color(0xFF10B981),
            onTap: () => Get.to(() => const SellProductScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Obx(() => Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          final isSelected = transactionController.selectedPeriod.value == period;
          return GestureDetector(
            onTap: () => transactionController.selectedPeriod.value = period,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildTransactionMatrix() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _MatrixTile(
              label: "Cash Collected",
              sublabel: "Total Sales",
              value: AppFormatters.formatCurrency(transactionController.totalInflow),
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MatrixTile(
              label: "Cash Spent",
              sublabel: "New Stock Cost",
              value: AppFormatters.formatCurrency(transactionController.totalOutflow),
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MatrixTile(
              label: "Net Margin",
              sublabel: "Actual Earnings",
              value: AppFormatters.formatCurrency(transactionController.totalMargin),
              icon: Icons.account_balance_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBarChart(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Obx(() {
        final chartData = transactionController.barChartData;
        if (chartData.isEmpty) return const Center(child: Text("No transaction data."));

        final labels = chartData.keys.toList();
        final List<BarChartGroupData> barGroups = [];
        
        for (int i = 0; i < labels.length; i++) {
          final data = chartData[labels[i]]!;
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: data['in']!, color: const Color(0xFF10B981), width: 12, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: data['out']!, color: const Color(0xFFEF4444), width: 12, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          );
        }

        return Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ChartLegend(label: "Sales", color: Color(0xFF10B981)),
                SizedBox(width: 20),
                _ChartLegend(label: "Purchases", color: Color(0xFFEF4444)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= labels.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInventoryChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Obx(() {
        final data = inventoryController.brandDistribution;
        if (data.isEmpty) return const Center(child: Text("No stock data available."));

        final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
        int index = 0;

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 55,
                      sections: data.entries.map((e) {
                        final color = colors[index++ % colors.length];
                        return PieChartSectionData(
                          color: color,
                          value: e.value,
                          title: "",
                          radius: 18,
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${inventoryController.totalDevicesAvailable}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const Text("In Stock", style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: data.entries.toList().asMap().entries.map((entry) {
                final color = colors[entry.key % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(entry.value.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Text("${entry.value.value.toInt()}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                );
              }).toList(),
            )
          ],
        );
      }),
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    return Obx(() {
      final recentItems = inventoryController.inventoryList.reversed.take(5).toList();
      if (recentItems.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No recent activity.")));
      return Column(
        children: recentItems.map((item) => _ActivityTileRedesign(item: item)).toList(),
      );
    });
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.label, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MatrixTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final IconData icon;
  final Color color;

  const _MatrixTile({required this.label, required this.sublabel, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          Text(sublabel, style: const TextStyle(fontSize: 7, color: AppColors.textSecondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _ChartLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ActivityTileRedesign extends StatelessWidget {
  final dynamic item;
  const _ActivityTileRedesign({required this.item});

  @override
  Widget build(BuildContext context) {
    final isSold = item.status == 'Sold';
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailsScreen(device: item)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isSold ? Colors.grey : AppColors.primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.phone_android_rounded, color: isSold ? Colors.grey : AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${item.brand} ${item.model}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSpecBadge(context, item.ram),
                      const SizedBox(width: 6),
                      _buildSpecBadge(context, item.storage),
                      const SizedBox(width: 8),
                      Text(item.networkStatus, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.formatCurrency(item.sellingPrice),
                  style: TextStyle(fontWeight: FontWeight.bold, color: isSold ? Colors.grey : const Color(0xFF10B981), fontSize: 15),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isSold ? Colors.grey : const Color(0xFF10B981)).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSold ? Colors.grey : const Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }
}
