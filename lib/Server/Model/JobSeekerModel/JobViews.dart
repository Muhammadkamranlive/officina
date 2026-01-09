import 'package:cloud_firestore/cloud_firestore.dart';

class JobViewsModel {
  /// Firebase UID of the user this notification belongs to
  final String userId;
  final String jobId;
  final int counter;
  final DateTime createdAt;
  /// Firestore document ID (NOT stored)
  String? docId;

  JobViewsModel({
    required this.userId,
    required this.jobId,
    required this.counter,
    required this.createdAt,
    this.docId,
  });

 
  /// Convert Firestore document to NotificationModel
  factory JobViewsModel.fromMap(Map<String, dynamic> map, String id) {
    return JobViewsModel(
      userId: map['userId'],
      jobId: map['jobId'],
      counter: map['counter'],
      createdAt: (map['createdAt'] as Timestamp?)!.toDate(),
      docId: id,
    );
  }

  /// Convert NotificationModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
       'jobId':jobId,
       'counter':counter,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
