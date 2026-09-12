import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../inventory/buy_product_screen.dart';
import '../inventory/sell_product_screen.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trade Center", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Buy or Sell Devices",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage your shop's transactions quickly and professionally.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              _buildTradeCard(
                title: "Buy Device",
                subtitle: "Purchase a mobile from a local seller and add it to your inventory.",
                icon: Icons.add_shopping_cart_rounded,
                color: AppColors.primary,
                onTap: () => Get.to(() => const BuyProductScreen()),
              ),
              
              const SizedBox(height: 20),
              
              _buildTradeCard(
                title: "Sell Device",
                subtitle: "Sell an existing mobile from your stock and record buyer details.",
                icon: Icons.sell_rounded,
                color: AppColors.success,
                onTap: () => Get.to(() => const SellProductScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
