class PersonDetails {
  final String name;
  final String contact;
  final String cnic;

  PersonDetails({
    required this.name,
    required this.contact,
    required this.cnic,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'cnic': cnic,
    };
  }

  factory PersonDetails.fromMap(Map<String, dynamic> map) {
    return PersonDetails(
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      cnic: map['cnic'] ?? '',
    );
  }
}
