import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class AdminRepository extends FirestoreRepository<AdminsModel> {
  AdminRepository() : super('Admins');

  @override
  AdminsModel fromMap(Map<String, dynamic> map, String id) =>
      AdminsModel.fromMap(map,id);

  @override
  Map<String, dynamic> toMap(AdminsModel entity) => entity.toMap();

   Future<AdminsModel?> getByUid(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
