import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/inventory_controller.dart';
import '../../models/mobile_device_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

class AddEditInventoryScreen extends StatefulWidget {
  final MobileDeviceModel? device;

  const AddEditInventoryScreen({super.key, this.device});

  @override
  State<AddEditInventoryScreen> createState() => _AddEditInventoryScreenState();
}

class _AddEditInventoryScreenState extends State<AddEditInventoryScreen> {
  final InventoryController inventoryController = Get.find<InventoryController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _ramController;
  late TextEditingController _storageController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _colorController;
  
  List<TextEditingController> _imeiControllers = [];

  String _status = 'Available';
  String _condition = 'New';
  String _networkStatus = 'PTA Approved';
  
  bool _hasBox = false;
  bool _hasCharger = false;
  bool _hasWarranty = false;

  final List<String> _conditions = ['New', 'Used - 10/10', 'Used - 9/10', 'Used - 8/10'];
  final List<String> _networkStatuses = ['PTA Approved', 'Non-PTA', 'JV'];
  final List<String> _statuses = ['Available', 'Sold'];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.device?.brand ?? '');
    _modelController = TextEditingController(text: widget.device?.model ?? '');
    _ramController = TextEditingController(text: widget.device?.ram ?? '');
    _storageController = TextEditingController(text: widget.device?.storage ?? '');
    _purchasePriceController = TextEditingController(text: widget.device?.purchasePrice.toString() ?? '');
    _sellingPriceController = TextEditingController(text: widget.device?.sellingPrice.toString() ?? '');
    _colorController = TextEditingController(text: widget.device?.color ?? '');

    _status = widget.device?.status ?? 'Available';
    _condition = widget.device?.condition ?? 'New';
    _networkStatus = widget.device?.networkStatus ?? 'PTA Approved';
    
    _hasBox = widget.device?.hasBox ?? false;
    _hasCharger = widget.device?.hasCharger ?? false;
    _hasWarranty = widget.device?.hasWarranty ?? false;

    if (widget.device != null && widget.device!.imeis.isNotEmpty) {
      for (var imei in widget.device!.imeis) {
        _imeiControllers.add(TextEditingController(text: imei));
      }
    } else {
      _imeiControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _colorController.dispose();
    for (var controller in _imeiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addImeiField() {
    if (_imeiControllers.length < 4) {
      setState(() {
        _imeiControllers.add(TextEditingController());
      });
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

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      List<String> imeis = _imeiControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      
      if (imeis.isEmpty) {
        Get.snackbar('Error', 'At least one IMEI is required', backgroundColor: AppColors.error, colorText: Colors.white);
        return;
      }

      final device = MobileDeviceModel(
        id: widget.device?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        ram: _ramController.text.trim(),
        storage: _storageController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text.trim()) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
        status: _status,
        imeis: imeis,
        color: _colorController.text.trim(),
        condition: _condition,
        hasBox: _hasBox,
        hasCharger: _hasCharger,
        hasWarranty: _hasWarranty,
        networkStatus: _networkStatus,
      );

      if (widget.device == null) {
        inventoryController.addDevice(device);
      } else {
        inventoryController.updateDevice(device);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.device != null;

    return Scaffold(
      
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editDeviceTitle : AppStrings.addDeviceTitle, 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Basic Info'),
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
                _buildSectionTitle('Pricing & Status'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_purchasePriceController, AppStrings.purchasePriceLabel, Icons.attach_money, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_sellingPriceController, AppStrings.sellingPriceLabel, Icons.money, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdown(AppStrings.statusLabel, _status, _statuses, (val) => setState(() => _status = val!)),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Condition & Accessories'),
                _buildDropdown(AppStrings.conditionLabel, _condition, _conditions, (val) => setState(() => _condition = val!)),
                const SizedBox(height: 12),
                _buildDropdown(AppStrings.networkStatusLabel, _networkStatus, _networkStatuses, (val) => setState(() => _networkStatus = val!)),
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
                  onPressed: _saveDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(AppStrings.saveButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
