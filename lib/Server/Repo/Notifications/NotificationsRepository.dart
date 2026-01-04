import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class NotificationRepository extends FirestoreRepository<NotificationModel> {
  NotificationRepository() : super('Notifications');

  @override
  NotificationModel fromMap(Map<String, dynamic> map, String id) =>
      NotificationModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(NotificationModel entity) => entity.toMap();

  /// Get all job offers created by a recruiter (via userId)
  Future<List<NotificationModel>> getByUserId(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) =>
            fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Get single job offer by document ID (optional helper)
  Future<NotificationModel?> getByDocId(String docId) async {
    final doc = await collection.doc(docId).get();
    if (doc.exists) {
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
