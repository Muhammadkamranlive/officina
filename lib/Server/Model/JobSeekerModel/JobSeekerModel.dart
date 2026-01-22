class JobSeekerModel {
  /// Same as Firebase Auth UID (Primary Key like SQL)
  final String userId;

  // Identity
  final String firstName;
  final String lastName;
  final bool isNameVisible;

  // Contact (unique)
  final String email;
  final String phoneNumber;

  // Job profile
  final String desiredPosition;

  /// Skills with verification status
  /// key   = skill name
  /// value = status (Pending / Verified / Rejected)
  final Map<String, String> skills;

  // Optional details
  final String? educationBackground;
  final String? experienceDetails;

  // Meta
  final DateTime createdAt;
  final String isActive; // Pending / Approved / Suspended
  String? logoUrl;
  // Firestore doc ID
  final String province;        // was: wilaya
  final String city;            // was: commune
  final String streetAddress;   // was: address
  final double latitude;
  final double longitude;

  String? docId;

  JobSeekerModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.isNameVisible,
    required this.email,
    required this.phoneNumber,
    required this.desiredPosition,
    required this.skills,
    this.educationBackground,
    this.experienceDetails,
    required this.createdAt,
    this.isActive = 'Pending',
    this.docId,
    this.logoUrl,
    required this.province,
    required this.city,
    required this.streetAddress,
    required this.latitude,
    required this.longitude,
  });

  /// 🔥 Firestore → Model
  factory JobSeekerModel.fromMap(Map<String, dynamic> map, String id) {
    return JobSeekerModel(
      userId: map['userId'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      isNameVisible: map['isNameVisible'] ?? true,
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      desiredPosition: map['desiredPosition'] ?? '',
      skills: Map<String, String>.from(map['skills'] ?? {}),
      educationBackground: map['educationBackground'],
      experienceDetails: map['experienceDetails'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? 'Pending',
      docId: id,
      logoUrl: map['logoUrl'],
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }

  /// 🔥 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'isNameVisible': isNameVisible,
      'email': email,
      'phoneNumber': phoneNumber,
      'desiredPosition': desiredPosition,
      'skills': skills,
      'educationBackground': educationBackground,
      'experienceDetails': experienceDetails,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'logoUrl':logoUrl,
      'province': province,
      'city': city,
      'streetAddress': streetAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// 🔥 Helpers (VERY IMPORTANT)

  /// Number of verified skills (ranking)
  int get verifiedSkillCount =>
      skills.values.where((s) => s == SkillStatus.verified).length;

  /// Pending skills (admin dashboard)
  List<String> get pendingSkills =>
      skills.entries
          .where((e) => e.value == SkillStatus.pending)
          .map((e) => e.key)
          .toList();

  /// Matching logic helper
  bool hasMinimumVerifiedSkills(int min) =>
      verifiedSkillCount >= min;
}

/// Skill status enum (stored as String in Firestore)
class SkillStatus {
  static const String pending = 'Pending';
  static const String verified = 'Verified';
  static const String rejected = 'Rejected';
}
