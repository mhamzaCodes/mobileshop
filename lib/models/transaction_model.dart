import 'person_details.dart';

class TransactionModel {
  final String id;
  final String type; // 'Buy' or 'Sell'
  final double amount;
  final double margin; // (SellingPrice - PurchasePrice) for 'Sell' type
  final DateTime date;
  final String productId;
  final String productName;
  final PersonDetails personDetails;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.margin,
    required this.date,
    required this.productId,
    required this.productName,
    required this.personDetails,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'margin': margin,
      'date': date.toIso8601String(),
      'productId': productId,
      'productName': productName,
      'personDetails': personDetails.toMap(),
    };
  }

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      type: data['type'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      margin: (data['margin'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(data['date']),
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      personDetails: PersonDetails.fromMap(data['personDetails'] ?? {}),
    );
  }
}
