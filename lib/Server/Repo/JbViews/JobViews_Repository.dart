import 'package:client/Server/Model/JobSeekerModel/JobViews.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobViewsRepository extends FirestoreRepository<JobViewsModel> {
  JobViewsRepository() : super('JobViews');

  @override
  JobViewsModel fromMap(Map<String, dynamic> map, String id) =>
      JobViewsModel.fromMap(map,id);

  @override
  Map<String, dynamic> toMap(JobViewsModel entity) => entity.toMap();

  Future<JobViewsModel?> getByUid(String userId,String jobId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
