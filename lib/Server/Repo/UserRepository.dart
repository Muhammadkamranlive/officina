import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class UserRepository extends FirestoreRepository<AppUser> {
  UserRepository() : super('users');

  @override
  AppUser fromMap(Map<String, dynamic> map, String id) {
    return AppUser.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(AppUser user) {
    return user.toMap();
  }

  Future<AppUser?> getByUid(String uid) async {
    final snapshot = await collection
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<AppUser?> getByEmail(String email) async {
    final snapshot = await collection
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
