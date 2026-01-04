class Recruiter {
  /// Same as Firebase Auth UID (Primary Key like SQL)
  final String userId;

  // Pharmacy information
  final String pharmacyName;
  final String pharmacistFirstName;
  final String pharmacistLastName;

  // Location (Algeria)
  final String province;        // was: wilaya
  final String city;            // was: commune
  final String streetAddress;   // was: address
  final double latitude;
  final double longitude;

  // Meta
  final DateTime createdAt;
  final bool isActive;

  // Firestore doc ID (not stored in Firestore)
  String? docId;

  Recruiter({
    required this.userId,
    required this.pharmacyName,
    required this.pharmacistFirstName,
    required this.pharmacistLastName,
    required this.province,
    required this.city,
    required this.streetAddress,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.isActive = true,
    this.docId,
  });

  factory Recruiter.fromMap(Map<String, dynamic> map, String id) {
    return Recruiter(
      userId: map['userId'], // 🔥 from FIELD
      pharmacyName: map['pharmacyName'] ?? '',
      pharmacistFirstName: map['pharmacistFirstName'] ?? '',
      pharmacistLastName: map['pharmacistLastName'] ?? '',
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
      docId: id, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // 🔥 REQUIRED // 🔥 from FIELD
      'pharmacyName': pharmacyName,
      'pharmacistFirstName': pharmacistFirstName,
      'pharmacistLastName': pharmacistLastName,
      'province': province,
      'city': city,
      'streetAddress': streetAddress,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
