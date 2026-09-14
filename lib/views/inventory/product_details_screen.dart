import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/inventory_controller.dart';
import '../../models/mobile_device_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import 'add_edit_inventory_screen.dart';
import 'sell_product_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final MobileDeviceModel device;
  ProductDetailsScreen({super.key, required this.device});

  final InventoryController inventoryController = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Details", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.to(() => AddEditInventoryScreen(device: device)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle("Technical Specifications"),
              _buildSpecGrid(context),
              const SizedBox(height: 24),
              _buildSectionTitle("IMEI Information"),
              _buildImeiList(context),
              const SizedBox(height: 24),
              _buildSectionTitle("Accessories & Integrity"),
              _buildAccessoriesCard(context),
              const SizedBox(height: 24),
              _buildSectionTitle("Trade History"),
              _buildHistorySection(context),
              const SizedBox(height: 32),
              if (device.status == 'Available')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const SellProductScreen()),
                    icon: const Icon(Icons.sell_outlined),
                    label: const Text("Sell This Device", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildHistoryTile(
            context,
            title: "Bought From",
            person: device.sellerDetails?.name ?? "Unknown Seller",
            contact: device.sellerDetails?.contact ?? "N/A",
            date: device.purchaseDate,
            amount: device.purchasePrice,
            icon: Icons.download_rounded,
            color: AppColors.primary,
          ),
          if (device.status == 'Sold') ...[
            const Divider(height: 24),
            _buildHistoryTile(
              context,
              title: "Sold To",
              person: device.buyerDetails?.name ?? "Unknown Buyer",
              contact: device.buyerDetails?.contact ?? "N/A",
              date: device.saleDate,
              amount: device.actualSoldPrice ?? device.sellingPrice,
              icon: Icons.upload_rounded,
              color: const Color(0xFF10B981),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, {
    required String title,
    required String person,
    required String contact,
    required DateTime? date,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              Text(person, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (date != null)
                Text(
                  "${DateFormat('MMM dd, yyyy').format(date)} • $contact",
                  style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                ),
            ],
          ),
        ),
        Text(
          AppFormatters.formatCurrency(amount),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone_android_rounded, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            "${device.brand} ${device.model}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              device.status,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderPrice("Purchase", device.purchasePrice),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildHeaderPrice("Selling", device.sellingPrice),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPrice(String label, double price) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          AppFormatters.formatCurrency(price),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSpecGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildSpecItem(context, "RAM", device.ram, Icons.memory),
        _buildSpecItem(context, "Storage", device.storage, Icons.sd_storage),
        _buildSpecItem(context, "Color", device.color, Icons.color_lens),
        _buildSpecItem(context, "Condition", device.condition, Icons.star_outline),
        _buildSpecItem(context, "Network", device.networkStatus, Icons.signal_cellular_alt),
        _buildSpecItem(context, "Coverage", device.networkCoverage, Icons.cell_tower),
        _buildSpecItem(context, "SIM", device.simType, Icons.sim_card_outlined),
        if (device.batteryHealth != null)
          _buildSpecItem(context, "Battery", "${device.batteryHealth}%", Icons.battery_charging_full),
      ],
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImeiList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ...device.imeis.asMap().entries.map((entry) {
            int idx = entry.key;
            String imei = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: idx == device.imeis.length - 1 && device.serialNumber == null ? 0 : 12.0),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text("IMEI ${idx + 1}:", style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Text(imei, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ],
              ),
            );
          }),
          if (device.serialNumber != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.pin, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Text("Serial Number:", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Text(device.serialNumber!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessoriesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildCheckItem("Original Box", device.hasBox),
          const Divider(),
          _buildCheckItem("Charger Included", device.hasCharger),
          const Divider(),
          _buildCheckItem("Active Warranty", device.hasWarranty),
          const Divider(),
          _buildCheckItem("Water Pack", device.isWaterPack),
          const Divider(),
          _buildCheckItem("Opened", device.isOpened, isNegative: true),
          const Divider(),
          _buildCheckItem("Repaired", device.isRepaired, isNegative: true),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool value, {bool isNegative = false}) {
    Color iconColor;
    if (isNegative) {
      iconColor = value ? AppColors.error : AppColors.success;
    } else {
      iconColor = value ? AppColors.success : AppColors.error;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Icon(
          value ? Icons.check_circle : (isNegative ? Icons.check_circle_outline : Icons.cancel),
          color: iconColor,
          size: 20,
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Device"),
        content: const Text("Are you sure you want to remove this device from inventory? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              inventoryController.deleteDevice(device.id);
              Get.back(); // close dialog
              Get.back(); // close details
              Get.snackbar("Deleted", "Device removed successfully", backgroundColor: Colors.orange);
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
