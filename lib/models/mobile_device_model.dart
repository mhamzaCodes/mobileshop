import 'person_details.dart';

class MobileDeviceModel {
  String id;
  String brand;
  String model;
  String ram;
  String storage;
  double purchasePrice;
  double sellingPrice;
  String status; // 'Available', 'Sold'
  List<String> imeis;
  String color;
  String condition; // 'New', 'Used - 10/10', etc.
  bool hasBox;
  bool hasCharger;
  bool hasWarranty;
  String networkStatus; // 'PTA Approved', 'Non-PTA', 'JV', 'Patch', 'CPID'
  String networkCoverage; // '2G', '3G', '4G', '5G', '6G'
  double? batteryHealth; // For Apple devices
  bool isWaterPack;
  bool isOpened;
  bool isRepaired;
  String? serialNumber;
  String simType;
  
  // History Fields
  PersonDetails? sellerDetails;
  PersonDetails? buyerDetails;
  DateTime? purchaseDate;
  DateTime? saleDate;
  double? actualSoldPrice;

  MobileDeviceModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.ram,
    required this.storage,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.status,
    required this.imeis,
    required this.color,
    required this.condition,
    required this.hasBox,
    required this.hasCharger,
    required this.hasWarranty,
    required this.networkStatus,
    required this.networkCoverage,
    this.batteryHealth,
    this.isWaterPack = false,
    this.isOpened = false,
    this.isRepaired = false,
    this.serialNumber,
    required this.simType,
    this.sellerDetails,
    this.buyerDetails,
    this.purchaseDate,
    this.saleDate,
    this.actualSoldPrice,
  });

  factory MobileDeviceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MobileDeviceModel(
      id: id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      ram: data['ram'] ?? '',
      storage: data['storage'] ?? '',
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Available',
      imeis: List<String>.from(data['imeis'] ?? []),
      color: data['color'] ?? '',
      condition: data['condition'] ?? 'New',
      hasBox: data['hasBox'] ?? false,
      hasCharger: data['hasCharger'] ?? false,
      hasWarranty: data['hasWarranty'] ?? false,
      networkStatus: data['networkStatus'] ?? 'PTA Approved',
      networkCoverage: data['networkCoverage'] ?? '4G',
      batteryHealth: data['batteryHealth'] != null ? (data['batteryHealth'] as num).toDouble() : null,
      isWaterPack: data['isWaterPack'] ?? false,
      isOpened: data['isOpened'] ?? false,
      isRepaired: data['isRepaired'] ?? false,
      serialNumber: data['serialNumber'],
      simType: data['simType'] ?? 'Physical SIM',
      sellerDetails: data['sellerDetails'] != null ? PersonDetails.fromMap(data['sellerDetails']) : null,
      buyerDetails: data['buyerDetails'] != null ? PersonDetails.fromMap(data['buyerDetails']) : null,
      purchaseDate: data['purchaseDate'] != null ? DateTime.parse(data['purchaseDate']) : null,
      saleDate: data['saleDate'] != null ? DateTime.parse(data['saleDate']) : null,
      actualSoldPrice: (data['actualSoldPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'brand': brand,
      'model': model,
      'ram': ram,
      'storage': storage,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'status': status,
      'imeis': imeis,
      'color': color,
      'condition': condition,
      'hasBox': hasBox,
      'hasCharger': hasCharger,
      'hasWarranty': hasWarranty,
      'networkStatus': networkStatus,
      'networkCoverage': networkCoverage,
      'batteryHealth': batteryHealth,
      'isWaterPack': isWaterPack,
      'isOpened': isOpened,
      'isRepaired': isRepaired,
      'serialNumber': serialNumber,
      'simType': simType,
      'sellerDetails': sellerDetails?.toMap(),
      'buyerDetails': buyerDetails?.toMap(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'saleDate': saleDate?.toIso8601String(),
      'actualSoldPrice': actualSoldPrice,
    };
  }
}
