import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart' show JobApplicationRepository;
import 'package:client/Server/Repo/ProfileViewsRepository.dart';

class RecruiterDashboardService {
  final JobApplicationRepository _jobRepo = JobApplicationRepository();
  final ProfileViewsRepository _viewsRepo = ProfileViewsRepository();

  Future<ProfileReviewStats> getProfileReviewStats(String recruiterId) async {
    // 1️⃣ Get all job applications for recruiter
    final applicationsSnap = await _jobRepo.collection
        .where('recruiterId', isEqualTo: recruiterId)
        .get();

    final applications = applicationsSnap.docs
        .map((doc) => JobApplicationModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();

    final totalApplicants = applications.length;

    if (totalApplicants == 0) {
      return ProfileReviewStats(
        totalApplicants: 0,
        reviewedApplicants: 0,
      );
    }

    // 2️⃣ Reviewed via application
    final reviewedByApplication = applications
        .where((a) =>
            a.isViewed ||
            a.recruiterViewedProfile ||
            a.isAccepted ||
            a.isRejected)
        .map((a) => a.candidateId)
        .toSet();

    // 3️⃣ Reviewed via profile views
    final viewsSnap = await _viewsRepo.collection
        .where('viewerId', isEqualTo: recruiterId)
        .get();

    final reviewedByProfileView = viewsSnap.docs
        .map((d) => d['userId'] as String)
        .toSet();

    // 4️⃣ Union (avoid double count)
    final reviewedApplicants = {
      ...reviewedByApplication,
      ...reviewedByProfileView,
    }.length;

    return ProfileReviewStats(
      totalApplicants: totalApplicants,
      reviewedApplicants:
          reviewedApplicants.clamp(0, totalApplicants),
    );
  }
}


class ProfileReviewStats {
  final int totalApplicants;
  final int reviewedApplicants;

  ProfileReviewStats({
    required this.totalApplicants,
    required this.reviewedApplicants,
  });
}
