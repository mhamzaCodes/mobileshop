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

  void _addImei() {
    if (_imeiControllers.length < 4) {
      setState(() => _imeiControllers.add(TextEditingController()));
    }
  }

  void _processPurchase() async {
    if (_formKey.currentState!.validate()) {
      final String deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      final List<String> imeis = _imeiControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

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
        hasWarranty: false,
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Seller Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 16),
                _buildTextField(_sellerNameController, "Seller Name", Icons.person_outline),
                const SizedBox(height: 12),
                _buildTextField(_sellerContactController, "Seller Contact", Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(_sellerCnicController, "Seller CNIC", Icons.badge_outlined),
                
                const SizedBox(height: 32),
                const Text("Device Specifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 16),
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
                Row(
                  children: [
                    Expanded(child: _buildTextField(_purchasePriceController, "Buy Price (PKR)", Icons.download, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_sellingPriceController, "Target Sell Price (PKR)", Icons.upload, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown("Network Status", _networkStatus, ["PTA Approved", "Non-PTA", "JV"], (v) => setState(() => _networkStatus = v!)),
                
                const SizedBox(height: 24),
                const Text("IMEI Numbers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ..._imeiControllers.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildTextField(e.value, "IMEI ${e.key + 1}", Icons.qr_code, keyboardType: TextInputType.number),
                )),
                if (_imeiControllers.length < 4)
                  TextButton.icon(onPressed: _addImei, icon: const Icon(Icons.add), label: const Text("Add Another IMEI")),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _processPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
