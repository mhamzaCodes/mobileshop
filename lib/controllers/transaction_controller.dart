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
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalOutflow => filteredTransactions
      .where((t) => t.type == 'Buy')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netIncome => totalInflow - totalOutflow;
}
