class UserModel {
  final String uid;
  final String name;
  final String email;
  final String shopName;
  final String address;
  final String? plaintextPassword;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.shopName,
    required this.address,
    this.plaintextPassword,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'shopName': shopName,
      'address': address,
      'plaintextPassword': plaintextPassword,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      shopName: map['shopName'] ?? '',
      address: map['address'] ?? '',
      plaintextPassword: map['plaintextPassword'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
