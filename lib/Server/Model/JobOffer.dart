import 'package:cloud_firestore/cloud_firestore.dart';

class JobOffer {
  /// Recruiter Firebase UID (same field name as Recruiter.userId)
  final String userId;

  // Job details
  final String jobTitle;        // gerant, pharmacist, physician, etc.
  final String jobType;         // part-time / full-time / replacement
  final List<String> skills;    // selected skills
  final String salary;
  // Status
  final bool isDraft;           // true = draft, false = posted
  final bool isActive;
  
  // Meta
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Firestore document ID (NOT stored)
  String? docId;

  JobOffer({
    required this.userId,
    required this.jobTitle,
    required this.jobType,
    required this.skills,
    required this.salary,
    required this.createdAt,
    this.updatedAt,
    this.isDraft = true,
    this.isActive = true,
    this.docId,
  });

  factory JobOffer.fromMap(Map<String, dynamic> map, String id) {
    return JobOffer(
      userId: map['userId'], // 🔥 SAME COLUMN NAME
      jobTitle: map['jobTitle'] ?? '',
      jobType: map['jobType'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      salary: map['salary'],
      isDraft: map['isDraft'] ?? true,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)!.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      docId: id,
    );
  }

 Map<String, dynamic> toMap({required bool isCreate}) {
  return {
    'userId': userId,
    'jobTitle': jobTitle,
    'jobType': jobType,
    'skills': skills,
    'salary':salary,
    'isDraft': isDraft,
    'isActive': isActive,
     
    // 🔥 Only set once
    if (isCreate) 'createdAt': FieldValue.serverTimestamp(),

    // 🔥 Always update
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

}
