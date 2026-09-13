import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransactionController controller = Get.find<TransactionController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _typeFilter = "All"; // "All", "Buy", "Sell"

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> get _filteredList {
    return controller.transactionsList.where((t) {
      final matchesSearch = t.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.personDetails.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == "All" || t.type == _typeFilter;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History & Stats", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() {
              final list = _filteredList;
              if (list.isEmpty) {
                return const Center(child: Text("No transactions found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final t = list[index];
                  return _buildTransactionCard(t);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search mobile or person...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Buy", "Sell"].map((type) {
                final isSelected = _typeFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _typeFilter = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel t) {
    final isSell = t.type == 'Sell';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      elevation: 0,
      borderOnForeground: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSell ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSell ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isSell ? AppColors.success : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${isSell ? 'Buyer' : 'Seller'}: ${t.personDetails.name}", 
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(DateFormat('MMM dd, yyyy • hh:mm a').format(t.date), 
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isSell ? '+' : '-'} ${AppFormatters.formatCurrency(t.amount)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSell ? AppColors.success : AppColors.error,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSell ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
