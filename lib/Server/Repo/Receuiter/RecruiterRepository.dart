import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class RecruiterRepository extends FirestoreRepository<Recruiter> {
  RecruiterRepository() : super('Recruiters');

  @override
  Recruiter fromMap(Map<String, dynamic> map, String id) =>
      Recruiter.fromMap(map,id);

  @override
  Map<String, dynamic> toMap(Recruiter entity) => entity.toMap();

   Future<Recruiter?> getByUid(String userId) async {
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
