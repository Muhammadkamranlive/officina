import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewsModel 
{
  final String userId;
  final String viewerId;
  final int counter;
  
  final DateTime createdAt;
  String? docId;

  ProfileViewsModel({
    required this.userId,
    required this.viewerId,
    required this.counter,
    required this.createdAt,
    this.docId,
  });

 
  /// Convert Firestore document to NotificationModel
  factory ProfileViewsModel.fromMap(Map<String, dynamic> map, String id) {
    return ProfileViewsModel(
      userId: map['userId'],
      viewerId: map['viewerId'],
      counter: map['counter'],
      createdAt: (map['createdAt'] as Timestamp?)!.toDate(),
      docId: id,
    );
  }

  /// Convert NotificationModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
       'viewerId':viewerId,
       'counter':counter,
        'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
