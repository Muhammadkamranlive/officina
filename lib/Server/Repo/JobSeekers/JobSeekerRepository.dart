import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobSeekerRepository extends FirestoreRepository<JobSeekerModel> {
  JobSeekerRepository() : super('JobSeekers');

  @override
  JobSeekerModel fromMap(Map<String, dynamic> map, String id) =>
      JobSeekerModel.fromMap(map,id);

  @override
  Map<String, dynamic> toMap(JobSeekerModel entity) => entity.toMap();

   Future<JobSeekerModel?> getByUid(String userId) async {
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