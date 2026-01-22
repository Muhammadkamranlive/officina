import 'package:client/Server/Model/JobSeekerModel/JobApplicantViewModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';

class JobApplicationRepository
    extends FirestoreRepository<JobApplicationModel> {
  JobApplicationRepository() : super('JobApplications');

  @override
  JobApplicationModel fromMap(Map<String, dynamic> map, String id) =>
      JobApplicationModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobApplicationModel entity) => entity.toMap();

  Future<JobApplicationModel?> getJobApplicationForJobSeeker(
    String userId,
    String jobId,
  ) async {
    final query = await collection
        .where('candidateId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<JobApplicationModel>> getJobApplicationForRecruiter(
    String userId,
    String jobId,
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

 Future<List<JobApplicationModel>> getJobApplicationForRecruiters(
    String userId,
  ) async {
    final query = await collection
        .where('recruiterId', isEqualTo: userId)
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

  Future<List<JobApplicantViewModel>> getApplicantsForJob(String jobId) async {
    // 1️⃣ Get all applications for this job
    final applicationsQuery = await collection
        .where('jobId', isEqualTo: jobId)
        .get();

    if (applicationsQuery.docs.isEmpty) return [];

    final jobSeekerRepo = JobSeekerRepository();

    // 2️⃣ Fetch job seekers in parallel
    final futures = applicationsQuery.docs.map((doc) async {
      final application = JobApplicationModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      final seeker = await jobSeekerRepo.getByUid(application.candidateId);

      if (seeker == null) return null;

      return JobApplicantViewModel(application: application, jobSeeker: seeker);
    });

    final results = await Future.wait(futures);

    // 3️⃣ Remove nulls (safety)
    return results.whereType<JobApplicantViewModel>().toList();
  }

  Future<List<JobApplicationModel>> getApplicationsForCandidate(
    String candidateId,
  ) async {
    final query = await collection
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('createdAt', descending: true)
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

  Future<List<JobApplicationWithJob>> getApplicationsWithJobsForCandidate(
    String candidateId,
  ) async {
    final query = await collection
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('createdAt', descending: true)
        .get();

    if (query.docs.isEmpty) return [];

    final jobRepo = JobOfferRepository();

    final futures = query.docs.map((doc) async {
      final application = JobApplicationModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      final job = await jobRepo.getByDocId(application.jobId);
      if (job == null) return null;

      return JobApplicationWithJob(application: application, job: job);
    });

    final results = await Future.wait(futures);
    return results.whereType<JobApplicationWithJob>().toList();
  }

  Stream<List<JobApplicationWithJob>> streamApplicationsWithJobsForCandidate(
    String candidateId,
  ) {
    final jobRepo = JobOfferRepository();

    return collection
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final futures = snapshot.docs.map((doc) async {
            final app = JobApplicationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );

            final job = await jobRepo.getByDocId(app.jobId);
            if (job == null) return null;

            return JobApplicationWithJob(application: app, job: job);
          });

          final results = await Future.wait(futures);
          return results.whereType<JobApplicationWithJob>().toList();
        });
  }
}
