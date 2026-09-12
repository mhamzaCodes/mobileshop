import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/mobile_device_model.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class BuyProductScreen extends StatefulWidget {
  const BuyProductScreen({super.key});

  @override
  State<BuyProductScreen> createState() => _BuyProductScreenState();
}

class _BuyProductScreenState extends State<BuyProductScreen> {
  final InventoryController inventoryController = Get.find<InventoryController>();
  final TransactionController transactionController = Get.find<TransactionController>();
  final _formKey = GlobalKey<FormState>();

  // Device Details
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _colorController = TextEditingController();
  final List<TextEditingController> _imeiControllers = [TextEditingController()];

  // Seller Details
  final _sellerNameController = TextEditingController();
  final _sellerContactController = TextEditingController();
  final _sellerCnicController = TextEditingController();

  String _condition = 'New';
  String _networkStatus = 'PTA Approved';
  bool _hasBox = false;
  bool _hasCharger = false;
  bool _hasWarranty = false;

  final List<String> _conditions = ['New', 'Used - 10/10', 'Used - 9/10', 'Used - 8/10'];
  final List<String> _networkStatuses = ['PTA Approved', 'Non-PTA', 'JV'];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _colorController.dispose();
    for (var c in _imeiControllers) {
      c.dispose();
    }
    _sellerNameController.dispose();
    _sellerContactController.dispose();
    _sellerCnicController.dispose();
    super.dispose();
  }

  void _addImeiField() {
    if (_imeiControllers.length < 4) {
      setState(() => _imeiControllers.add(TextEditingController()));
    }
  }

  void _removeImeiField(int index) {
    if (_imeiControllers.length > 1) {
      setState(() {
        _imeiControllers[index].dispose();
        _imeiControllers.removeAt(index);
      });
    }
  }

  void _processPurchase() async {
    if (_formKey.currentState!.validate()) {
      final List<String> imeis = _imeiControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      
      if (imeis.isEmpty) {
        Get.snackbar("Error", "At least one IMEI is required", 
          backgroundColor: AppColors.error, colorText: Colors.white);
        return;
      }

      final String deviceId = DateTime.now().millisecondsSinceEpoch.toString();

      final device = MobileDeviceModel(
        id: deviceId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        ram: _ramController.text.trim(),
        storage: _storageController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text.trim()) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
        status: 'Available',
        imeis: imeis,
        color: _colorController.text.trim(),
        condition: _condition,
        hasBox: _hasBox,
        hasCharger: _hasCharger,
        hasWarranty: _hasWarranty,
        networkStatus: _networkStatus,
      );

      final transaction = TransactionModel(
        id: "TX_$deviceId",
        type: 'Buy',
        amount: device.purchasePrice,
        date: DateTime.now(),
        productId: deviceId,
        productName: "${device.brand} ${device.model}",
        personDetails: PersonDetails(
          name: _sellerNameController.text.trim(),
          contact: _sellerContactController.text.trim(),
          cnic: _sellerCnicController.text.trim(),
        ),
      );

      await inventoryController.addDevice(device);
      await transactionController.addTransaction(transaction);

      Get.back();
      Get.snackbar("Success", "Device purchased and added to inventory", 
        backgroundColor: AppColors.success, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Device", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle("Seller Details"),
                _buildTextField(_sellerNameController, "Seller Name", Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField(_sellerContactController, "Seller Contact", Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_sellerCnicController, "Seller CNIC", Icons.badge_outlined),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Basic Info"),
                _buildTextField(_brandController, AppStrings.brandLabel, Icons.branding_watermark),
                const SizedBox(height: 12),
                _buildTextField(_modelController, AppStrings.modelLabel, Icons.phone_android),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_ramController, AppStrings.ramLabel, Icons.memory)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_storageController, AppStrings.storageLabel, Icons.sd_storage)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_colorController, AppStrings.colorLabel, Icons.color_lens),

                const SizedBox(height: 24),
                _buildSectionTitle("Pricing"),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_purchasePriceController, "Buy Price (PKR)", Icons.download, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_sellingPriceController, "Target Sell Price (PKR)", Icons.upload, isNumber: true)),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Condition & Accessories"),
                _buildDropdown("Condition", _condition, _conditions, (val) => setState(() => _condition = val!)),
                const SizedBox(height: 12),
                _buildDropdown("Network Status", _networkStatus, _networkStatuses, (val) => setState(() => _networkStatus = val!)),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : AppColors.border)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text(AppStrings.hasBox),
                        value: _hasBox,
                        onChanged: (val) => setState(() => _hasBox = val),
                        activeColor: AppColors.primary,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text(AppStrings.hasCharger),
                        value: _hasCharger,
                        onChanged: (val) => setState(() => _hasCharger = val),
                        activeColor: AppColors.primary,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text(AppStrings.hasWarranty),
                        value: _hasWarranty,
                        onChanged: (val) => setState(() => _hasWarranty = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle(AppStrings.imeiSectionTitle),
                ...List.generate(_imeiControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imeiControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '${AppStrings.imeiLabelPrefix} ${index + 1}',
                              prefixIcon: const Icon(Icons.qr_code),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                            ),
                            validator: (value) {
                              if (index == 0 && (value == null || value.isEmpty)) {
                                return AppStrings.errorRequiredField;
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_imeiControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                            onPressed: () => _removeImeiField(index),
                          ),
                      ],
                    ),
                  );
                }),
                if (_imeiControllers.length < 4)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addImeiField,
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text(AppStrings.addImeiButton, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _processPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Confirm Purchase", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? (isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.errorRequiredField;
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
