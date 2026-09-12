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
  String networkStatus; // 'PTA Approved', 'Non-PTA', 'JV'

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
  });

  factory MobileDeviceModel.fromJson(Map<String, dynamic> json) {
    return MobileDeviceModel(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      ram: json['ram'],
      storage: json['storage'],
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      status: json['status'],
      imeis: List<String>.from(json['imeis'] ?? []),
      color: json['color'],
      condition: json['condition'],
      hasBox: json['hasBox'] ?? false,
      hasCharger: json['hasCharger'] ?? false,
      hasWarranty: json['hasWarranty'] ?? false,
      networkStatus: json['networkStatus'],
    );
  }

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
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }

  MobileDeviceModel copyWith({
    String? id,
    String? brand,
    String? model,
    String? ram,
    String? storage,
    double? purchasePrice,
    double? sellingPrice,
    String? status,
    List<String>? imeis,
    String? color,
    String? condition,
    bool? hasBox,
    bool? hasCharger,
    bool? hasWarranty,
    String? networkStatus,
  }) {
    return MobileDeviceModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      status: status ?? this.status,
      imeis: imeis ?? this.imeis,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      hasBox: hasBox ?? this.hasBox,
      hasCharger: hasCharger ?? this.hasCharger,
      hasWarranty: hasWarranty ?? this.hasWarranty,
      networkStatus: networkStatus ?? this.networkStatus,
    );
  }
}
