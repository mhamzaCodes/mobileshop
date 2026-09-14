import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_controller.dart';
import '../models/transaction_model.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  var transactionsList = <TransactionModel>[].obs;
  var selectedPeriod = 'Daily'.obs; // 'Daily', 'Weekly', 'Monthly'

  @override
  void onInit() {
    super.onInit();
    _bindTransactions();
  }

  void _bindTransactions() {
    if (_authController.currentUser.value != null) {
      final user = _authController.selectedUserForAdmin.value ?? _authController.currentUser.value!;
      _listenToTransactions(user.uid);
    }

    ever(_authController.currentUser, (user) {
      if (user != null) {
        final targetUser = _authController.selectedUserForAdmin.value ?? user;
        _listenToTransactions(targetUser.uid);
      } else {
        transactionsList.clear();
      }
    });

    ever(_authController.selectedUserForAdmin, (user) {
      if (_authController.isAdmin.value) {
        final targetUser = user ?? _authController.currentUser.value;
        if (targetUser != null) {
          _listenToTransactions(targetUser.uid);
        }
      }
    });
  }

  void _listenToTransactions(String uid) {
    _firestore
        .collection('products')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      transactionsList.value = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final user = _authController.currentUser.value;
    if (user != null) {
      await _firestore
          .collection('products')
          .doc(user.uid)
          .collection('transactions')
          .add(transaction.toFirestore());
    }
  }

  // Filtered stats based on selectedPeriod
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return transactionsList.where((t) {
      if (selectedPeriod.value == 'Daily') {
        return t.date.year == now.year && t.date.month == now.month && t.date.day == now.day;
      } else if (selectedPeriod.value == 'Weekly') {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (selectedPeriod.value == 'Monthly') {
        return t.date.year == now.year && t.date.month == now.month;
      }
      return true;
    }).toList();
  }

  double get totalInflow => filteredTransactions
      .where((t) => t.type == 'Sell')
      .fold(0.0, (total, t) => total + t.amount);

  double get totalOutflow => filteredTransactions
      .where((t) => t.type == 'Buy')
      .fold(0.0, (total, t) => total + t.amount);

  double get totalMargin => filteredTransactions
      .where((t) => t.type == 'Sell')
      .fold(0.0, (total, t) => total + t.margin);

  // Data for Bar Chart
  Map<String, Map<String, double>> get barChartData {
    final Map<String, Map<String, double>> data = {};
    final now = DateTime.now();

    if (selectedPeriod.value == 'Weekly') {
      // Last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final label = "${date.day}/${date.month}";
        data[label] = {"in": 0.0, "out": 0.0};
        
        for (var t in transactionsList) {
          if (t.date.day == date.day && t.date.month == date.month && t.date.year == date.year) {
            if (t.type == 'Sell') data[label]!["in"] = data[label]!["in"]! + t.amount;
            if (t.type == 'Buy') data[label]!["out"] = data[label]!["out"]! + t.amount;
          }
        }
      }
    } else if (selectedPeriod.value == 'Daily') {
      // Last 24 hours in 4-hour chunks
      for (int i = 5; i >= 0; i--) {
        final hourStart = now.hour - (i * 4);
        final label = "${hourStart < 0 ? 24 + hourStart : hourStart}:00";
        data[label] = {"in": 0.0, "out": 0.0};
        
        for (var t in transactionsList) {
          if (t.date.year == now.year && t.date.month == now.month && t.date.day == now.day) {
             if (t.date.hour >= hourStart && t.date.hour < hourStart + 4) {
               if (t.type == 'Sell') data[label]!["in"] = data[label]!["in"]! + t.amount;
               if (t.type == 'Buy') data[label]!["out"] = data[label]!["out"]! + t.amount;
             }
          }
        }
      }
    } else {
      // Monthly: split into 4 weeks
       for (int i = 3; i >= 0; i--) {
        final label = "Week ${4-i}";
        data[label] = {"in": 0.0, "out": 0.0};
        final start = now.subtract(Duration(days: (i + 1) * 7));
        final end = now.subtract(Duration(days: i * 7));

        for (var t in transactionsList) {
          if (t.date.isAfter(start) && t.date.isBefore(end)) {
            if (t.type == 'Sell') data[label]!["in"] = data[label]!["in"]! + t.amount;
            if (t.type == 'Buy') data[label]!["out"] = data[label]!["out"]! + t.amount;
          }
        }
      }
    }
    return data;
  }
}
