import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicationModel {
  /// Core relations
   final String jobId;
  final String recruiterId;
  final String candidateId;

  final String status;
  final bool recruiterViewedProfile;
  final bool allowChat;
  
  

  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? docId;

  JobApplicationModel({
    required this.jobId,
    required this.recruiterId,
    required this.candidateId,
    this.status = 'applied',
    this.recruiterViewedProfile = false,
    this.allowChat = false,
    required this.createdAt,
    this.updatedAt,
    this.docId,
  });

  JobApplicationModel copyWith({
    String? status,
    bool? recruiterViewedProfile,
    bool? allowChat,
    DateTime? updatedAt,
  }) {
    return JobApplicationModel(
      jobId: jobId,
      recruiterId: recruiterId,
      candidateId: candidateId,
      status: status ?? this.status,
      recruiterViewedProfile: recruiterViewedProfile ?? this.recruiterViewedProfile,
      allowChat: allowChat ?? this.allowChat,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      docId: docId,
    );
  }


  // =========================
  // Firestore → Model
  // =========================
  factory JobApplicationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return JobApplicationModel(
      jobId: map['jobId'],
      recruiterId: map['recruiterId'],
      candidateId: map['candidateId'],
      status: map['status'] ?? 'applied',
      recruiterViewedProfile: map['recruiterViewedProfile'] ?? false,
      allowChat: map['allowChat'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      docId: id,
    );
  }

  // =========================
  // Model → Firestore
  // =========================
  // Map<String, dynamic> toMap() {
  //   return {
  //     'jobId': jobId,
  //     'recruiterId': recruiterId,
  //     'candidateId': candidateId,
  //     'status': status,
  //     'recruiterViewedProfile': recruiterViewedProfile,
  //     'allowChat': allowChat,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'updatedAt': FieldValue.serverTimestamp(),
  //   };
  // }

  Map<String, dynamic> toMap() {
  return {
    'jobId': jobId,
    'recruiterId': recruiterId,
    'candidateId': candidateId,
    'status': status,
    'recruiterViewedProfile': recruiterViewedProfile,
    'allowChat': allowChat,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}


  // =========================
  // Helpers (VERY USEFUL)
  // =========================

  bool get isApplied => status == 'applied';
  bool get isViewed => status == 'viewed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  bool get canChat => allowChat && isAccepted;
}
