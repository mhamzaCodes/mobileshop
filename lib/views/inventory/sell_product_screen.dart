import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/mobile_device_model.dart';
import '../../models/person_details.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final InventoryController inventoryController = Get.find<InventoryController>();
  final TransactionController transactionController = Get.find<TransactionController>();
  final _formKey = GlobalKey<FormState>();

  MobileDeviceModel? _selectedDevice;
  final TextEditingController _buyerNameController = TextEditingController();
  final TextEditingController _buyerContactController = TextEditingController();
  final TextEditingController _buyerCnicController = TextEditingController();
  final TextEditingController _sellingAmountController = TextEditingController();

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _buyerCnicController.dispose();
    _sellingAmountController.dispose();
    super.dispose();
  }

  void _onDeviceSelected(MobileDeviceModel? device) {
    setState(() {
      _selectedDevice = device;
      if (device != null) {
        _sellingAmountController.text = device.sellingPrice.toStringAsFixed(0);
      }
    });
  }

  void _processSale() async {
    if (_formKey.currentState!.validate() && _selectedDevice != null) {
      final double soldAmount = double.tryParse(_sellingAmountController.text) ?? _selectedDevice!.sellingPrice;
      final double margin = soldAmount - _selectedDevice!.purchasePrice;

      final buyer = PersonDetails(
        name: _buyerNameController.text.trim(),
        contact: _buyerContactController.text.trim(),
        cnic: _buyerCnicController.text.trim(),
      );

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'Sell',
        amount: soldAmount,
        margin: margin,
        date: DateTime.now(),
        productId: _selectedDevice!.id,
        productName: "${_selectedDevice!.brand} ${_selectedDevice!.model}",
        personDetails: buyer,
      );

      await transactionController.addTransaction(transaction);
      await inventoryController.markAsSold(_selectedDevice!.id, buyer: buyer, actualSoldPrice: soldAmount);

      Get.back();
      Get.snackbar("Success", "Product sold successfully!", 
        backgroundColor: AppColors.success, colorText: Colors.white);
    } else if (_selectedDevice == null) {
      Get.snackbar("Error", "Please select a device to sell", 
        backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell Device", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Select Device", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 12),
                Obx(() {
                  final available = inventoryController.availableProducts;
                  if (available.isEmpty) {
                    return const Center(child: Text("No devices available to sell."));
                  }
                  return DropdownButtonFormField<MobileDeviceModel>(
                    value: _selectedDevice,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_android),
                      labelText: "Choose Mobile",
                    ),
                    items: available.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text("${device.brand} ${device.model} (${AppFormatters.formatCurrency(device.sellingPrice)})"),
                      );
                    }).toList(),
                    onChanged: _onDeviceSelected,
                  );
                }),
                const SizedBox(height: 24),
                
                if (_selectedDevice != null) ...[
                  const Text("Sale Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _sellingAmountController,
                    label: "Selling Amount (PKR)",
                    icon: Icons.money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  
                  const Text("Buyer Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _buyerNameController,
                    label: "Buyer Name",
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Enter buyer name" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _buyerContactController,
                    label: "Contact Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Enter contact number" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _buyerCnicController,
                    label: "Buyer CNIC (Optional)",
                    icon: Icons.badge_outlined,
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _processSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Complete Sale", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
