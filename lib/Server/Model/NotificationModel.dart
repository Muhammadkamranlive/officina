import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  /// Firebase UID of the user this notification belongs to
  final String userId;

  /// Notification type: login, logout, payment, job_post, job_apply, etc.
  final String type;

  /// Notification title and description
  final String title;
  final String description;

  /// Status
  final bool isRead;

  /// Meta
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Firestore document ID (NOT stored)
  String? docId;

  NotificationModel({
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.updatedAt,
    this.isRead = false,
    this.docId,
  });

   /// 🔥 ADD THIS
  NotificationModel copyWith({
    String? docId,
    String? userId,
    String? type,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Convert Firestore document to NotificationModel
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      userId: map['userId'],
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)!.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      docId: id,
    );
  }

  /// Convert NotificationModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'isRead': isRead,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
