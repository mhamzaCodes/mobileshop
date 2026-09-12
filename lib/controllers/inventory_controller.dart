import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';
import '../models/mobile_device_model.dart';

class InventoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  var inventoryList = <MobileDeviceModel>[].obs;
  var isLoading = false.obs;

  // Filter States
  var searchQuery = "".obs;
  var selectedStatus = "All".obs;
  var selectedBrand = "All".obs;
  var selectedNetworkStatus = "All".obs;

  @override
  void onInit() {
    super.onInit();
    // Bind the inventory list to Firestore stream
    _bindInventory();
  }

  void _bindInventory() {
    // Check if user is already logged in
    if (_authController.currentUser.value != null) {
      final user = _authController.currentUser.value!;
      _listenToProducts(user.uid, user.shopName);
    }

    // Listen to future changes
    ever(_authController.currentUser, (user) {
      if (user != null && user.shopName.isNotEmpty) {
        _listenToProducts(user.uid, user.shopName);
      } else {
        inventoryList.clear();
      }
    });
  }

  void _listenToProducts(String uid, String shopName) {
    _firestore
        .collection('products')
        .doc(uid)
        .collection(shopName)
        .snapshots()
        .listen((snapshot) {
      inventoryList.value = snapshot.docs
          .map((doc) => MobileDeviceModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Computed Property for Filtered List
  List<MobileDeviceModel> get filteredInventory {
    return inventoryList.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.brand.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          item.model.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.value == "All" || item.status == selectedStatus.value;
      final matchesBrand = selectedBrand.value == "All" || item.brand == selectedBrand.value;
      final matchesNetwork = selectedNetworkStatus.value == "All" || item.networkStatus == selectedNetworkStatus.value;
      return matchesSearch && matchesStatus && matchesBrand && matchesNetwork;
    }).toList();
  }

  List<String> get availableBrands {
    final brands = inventoryList.map((e) => e.brand).toSet().toList();
    brands.sort();
    return ["All", ...brands];
  }

  void setSearchQuery(String query) => searchQuery.value = query;
  void setStatus(String status) => selectedStatus.value = status;
  void setBrand(String brand) => selectedBrand.value = brand;
  void setNetworkStatus(String status) => selectedNetworkStatus.value = status;

  void clearFilters() {
    searchQuery.value = "";
    selectedStatus.value = "All";
    selectedBrand.value = "All";
    selectedNetworkStatus.value = "All";
    update();
  }

  // Computed Properties for Stats
  // Sum of purchase prices for currently available items only
  double get currentStockValue => inventoryList
      .where((item) => item.status == 'Available')
      .fold(0.0, (total, item) => total + item.purchasePrice);

  double get totalHistoricalInvestment => inventoryList.fold(0.0, (total, item) => total + item.purchasePrice);

  double get expectedProfit => inventoryList.fold(0.0, (total, item) {
    return item.status == 'Available' ? total + (item.sellingPrice - item.purchasePrice) : total;
  });
  int get totalDevicesAvailable => inventoryList.where((item) => item.status == 'Available').length;

  Map<String, double> get brandDistribution {
    Map<String, double> data = {};
    for (var item in inventoryList) {
      if (item.status == 'Available') {
        data[item.brand] = (data[item.brand] ?? 0) + 1;
      }
    }
    return data;
  }

  List<MobileDeviceModel> get availableProducts => inventoryList.where((item) => item.status == 'Available').toList();

  // Firestore Operations
  Future<void> addDevice(MobileDeviceModel device) async {
    final user = _authController.currentUser.value;
    if (user != null) {
      isLoading.value = true;
      try {
        await _firestore
            .collection('products')
            .doc(user.uid)
            .collection(user.shopName)
            .add(device.toFirestore());
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> updateDevice(MobileDeviceModel device) async {
    final user = _authController.currentUser.value;
    if (user != null) {
      isLoading.value = true;
      try {
        await _firestore
            .collection('products')
            .doc(user.uid)
            .collection(user.shopName)
            .doc(device.id)
            .update(device.toFirestore());
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteDevice(String id) async {
    final user = _authController.currentUser.value;
    if (user != null) {
      isLoading.value = true;
      try {
        await _firestore
            .collection('products')
            .doc(user.uid)
            .collection(user.shopName)
            .doc(id)
            .delete();
      } finally {
        isLoading.value = false;
      }
    }
  }
  
  Future<void> markAsSold(String id) async {
    final user = _authController.currentUser.value;
    if (user != null) {
      isLoading.value = true;
      try {
        await _firestore
            .collection('products')
            .doc(user.uid)
            .collection(user.shopName)
            .doc(id)
            .update({'status': 'Sold'});
      } finally {
        isLoading.value = false;
      }
    }
  }
}
