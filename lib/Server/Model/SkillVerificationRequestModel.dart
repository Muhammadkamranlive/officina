class SkillVerificationRequest {
  final String jobSeekerId;
  final String recruiterId;
  final String jobId;
  final DateTime createdAt;
  final String status;
  String? docId;

  SkillVerificationRequest({
    required this.jobSeekerId,
    required this.recruiterId,
    required this.jobId,
    required this.createdAt,
    this.status = 'Pending',
    this.docId,
  });

  factory SkillVerificationRequest.fromMap(Map<String, dynamic> map, String id) {
    return SkillVerificationRequest(
      jobSeekerId: map['jobSeekerId'],
      recruiterId: map['recruiterId'],
      jobId: map['jobId'],
      
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'Pending',
      docId: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobSeekerId': jobSeekerId,
      'recruiterId': recruiterId,
      'jobId': jobId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
