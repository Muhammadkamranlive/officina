import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobOfferRepository extends FirestoreRepository<JobOffer> {
  JobOfferRepository() : super('JobOffers');

  @override
  JobOffer fromMap(Map<String, dynamic> map, String id) =>
      JobOffer.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobOffer entity) => entity.toMap(isCreate: true);

  /// Get all job offers created by a recruiter (via userId)
Future<List<JobOffer>> getByUserId(String userId) async {
  final query = await collection
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs
      .map((doc) =>
          JobOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .toList();
}


  /// Get single job offer by document ID (optional helper)
  Future<JobOffer?> getByDocId(String docId) async {
    final doc = await collection.doc(docId).get();
    if (doc.exists) {
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<JobOffer>> getAll() async {
  final query = await collection
     
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs
      .map((doc) =>
          JobOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .toList();
}


Future<List<JobOffer>> getMatchingJobs(JobSeekerModel seeker) async {
  final allJobs = await JobOfferRepository().getAll(); // get all active jobs

  // Filter jobs that match the desired position
  final positionMatchedJobs = allJobs.where((job) {
    return job.jobTitle.toLowerCase() == seeker.desiredPosition.toLowerCase() && job.isActive;
  }).toList();

  // Sort or rank based on skill matches
  final rankedJobs = positionMatchedJobs.map((job) {
    final matchedSkills = job.skills
        .where((skill) => seeker.skills.keys.contains(skill) &&
            seeker.skills[skill] == SkillStatus.verified)
        .length;
    return MapEntry(job, matchedSkills); // store match count
  }).toList();

  // Sort by highest skill match first
  rankedJobs.sort((a, b) => b.value.compareTo(a.value));

  return rankedJobs.map((e) => e.key).toList();
}

}
