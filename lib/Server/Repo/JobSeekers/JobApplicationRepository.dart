import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobApplicationRepository
    extends FirestoreRepository<JobApplicationModel> {
  JobApplicationRepository() : super('JobSeekers');

  @override
  JobApplicationModel fromMap(Map<String, dynamic> map, String id) =>
      JobApplicationModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobApplicationModel entity) => entity.toMap();

  Future<JobApplicationModel?> getJobApplicationForJobSeeker(
    String userId,String jobId
  ) async {
    final query = await collection
        .where('candidateId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) 
    {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<JobApplicationModel>> getJobApplicationForRecruiter(
    String userId,String jobId
  ) async {
    final query = await collection
        .where('recruiterId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .get();

    return query.docs
        .map(
          (doc) => JobApplicationModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<List<JobApplicationModel>> getAll(String jobId) async {
    final query = await collection.where('jobId', isEqualTo: jobId).get();

    return query.docs
        .map(
          (doc) => JobApplicationModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }
}
