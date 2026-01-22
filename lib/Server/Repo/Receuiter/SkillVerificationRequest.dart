import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestWithJobSeeker.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';

class SkillVerificationRequestRepository
    extends FirestoreRepository<SkillVerificationRequest> {

  SkillVerificationRequestRepository()
      : super('SkillVerificationRequests');

  @override
  SkillVerificationRequest fromMap(Map<String, dynamic> map, String id) =>
      SkillVerificationRequest.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(SkillVerificationRequest entity) =>
      entity.toMap();

  /// 🔹 Jobseeker submits request
  Future<void> submitRequest(SkillVerificationRequest request) async {
    await collection.add(request.toMap());
  }

  /// 🔹 Recruiter sees all requests assigned to him
  Future<List<SkillVerificationRequest>> getRequestsForRecruiter(
      String recruiterId) async {
    final query = await collection
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// 🔹 Single request
  Future<SkillVerificationRequest?> getById(String docId) async {
    final doc = await collection.doc(docId).get();
    if (!doc.exists) return null;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
  /// 🔹 Recruiter sees ONLY his assigned requests WITH jobseeker data
  Future<List<SkillVerificationRequestWithJobSeeker>>
      getRequestsWithJobSeekersForRecruiter(
    String recruiterId,
  ) async {
    final jobSeekerRepo = JobSeekerRepository();

    // 1️⃣ Get requests for recruiter
    final requests = await getRequestsForRecruiter(recruiterId);

    if (requests.isEmpty) return [];

    // 2️⃣ Collect unique jobSeekerIds
    final jobSeekerIds = requests.map((r) => r.jobSeekerId).toSet();

    // 3️⃣ Fetch jobseekers in parallel (FAST)
    final jobSeekers = await Future.wait(
      jobSeekerIds.map((id) => jobSeekerRepo.getByUid(id)),
    );

    // 4️⃣ Create lookup map
    final Map<String, JobSeekerModel> seekerMap = {
      for (var js in jobSeekers)
        if (js != null) js.userId: js,
    };

    // 5️⃣ Join data
    return requests
        .where((r) => seekerMap.containsKey(r.jobSeekerId))
        .map(
          (r) => SkillVerificationRequestWithJobSeeker(
            request: r,
            jobSeeker: seekerMap[r.jobSeekerId]!,
          ),
        )
        .toList();
  }
}


extension SkillVerificationHelpers on SkillVerificationRequestRepository {
  Future<bool> requestExists({
    required String jobSeekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .where('recruiterId', isEqualTo: recruiterId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }
}
