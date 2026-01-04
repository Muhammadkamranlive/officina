import 'package:client/Server/Enums/UserRole.dart';

class AppUser {
  final String userId;
  final String email;
  final UserRole role;
  final String? phone ;

  AppUser({
    required this.userId,
    required this.email,
    required this.role,
    this.phone,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'], // 🔥 from FIELD
      email: map['email'] ?? '',
      role: _roleFromString(map['role'] ?? 'jobSeeker'),
      phone: map['phone']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // 🔥 REQUIRED
      'email': email,
      'role': role.name,
      'phone':phone
    };
  }

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'recruiter':
        return UserRole.recruiter;
      case 'jobSeeker':
      default:
        return UserRole.jobSeeker;
    }
  }
}