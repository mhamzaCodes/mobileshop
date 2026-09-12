import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/inventory_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import 'add_edit_inventory_screen.dart';
import 'product_details_screen.dart';

class InventoryListScreen extends StatelessWidget {
  InventoryListScreen({super.key});

  final InventoryController inventoryController = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventoryTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            onPressed: () => Get.to(() => const AddEditInventoryScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context),
          Expanded(
            child: Obx(() {
              final filteredItems = inventoryController.filteredInventory;
              if (filteredItems.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return _buildInventoryCard(context, item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: inventoryController.setSearchQuery,
            decoration: InputDecoration(
              hintText: "Search Brand or Model...",
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: Obx(() => inventoryController.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => inventoryController.setSearchQuery(""),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          // Quick Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: "All", value: "All"),
                const SizedBox(width: 8),
                _FilterChip(label: "Available", value: "Available"),
                const SizedBox(width: 8),
                _FilterChip(label: "Sold", value: "Sold"),
                const SizedBox(width: 12),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 12),
                _buildAdvancedFilterDropdowns(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilterDropdowns(BuildContext context) {
    return Row(
      children: [
        Obx(() => _buildSmallDropdown(
              context,
              value: inventoryController.selectedBrand.value,
              items: inventoryController.availableBrands,
              onChanged: (val) => inventoryController.setBrand(val!),
              hint: "Brand",
            )),
        const SizedBox(width: 8),
        Obx(() => _buildSmallDropdown(
              context,
              value: inventoryController.selectedNetworkStatus.value,
              items: ["All", "PTA Approved", "Non-PTA", "JV"],
              onChanged: (val) => inventoryController.setNetworkStatus(val!),
              hint: "Network",
            )),
      ],
    );
  }

  Widget _buildSmallDropdown(BuildContext context,
      {required String value, required List<String> items, required Function(String?) onChanged, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, dynamic item) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.phone_android, color: AppColors.primary),
        ),
        title: Text('${item.brand} ${item.model}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.ram} / ${item.storage} • ${item.networkStatus}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('PKR ${item.sellingPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.status == 'Available' ? AppColors.statusAvailable.withValues(alpha: 0.1) : AppColors.statusSold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.status == 'Available' ? AppColors.statusAvailable : AppColors.statusSold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Get.to(() => ProductDetailsScreen(device: item));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text("No devices match your filters", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: inventoryController.clearFilters,
            child: const Text("Clear All Filters", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final InventoryController controller = Get.find();

  _FilterChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == value;
      return GestureDetector(
        onTap: () => controller.setStatus(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }
}
