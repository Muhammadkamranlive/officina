import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';

class JobSearchRepository {
  final JobOfferRepository _jobRepo = JobOfferRepository();
  final RecruiterRepository _recruiterRepo = RecruiterRepository();

  Future<List<JobOfferWithRecruiter>> getAllJobsWithRecruiter() async {
    // 1. Get all job offers
    final jobs = await _jobRepo.getAll();

    // 2. Cache recruiters (important for performance)
    final Map<String, Recruiter> recruiterCache = {};

    final List<JobOfferWithRecruiter> result = [];

    for (final job in jobs) {
      // Check cache first
      Recruiter? recruiter = recruiterCache[job.userId];

      if (recruiter == null) {
        recruiter = await _recruiterRepo.getByUid(job.userId);
        if (recruiter != null) {
          recruiterCache[job.userId] = recruiter;
        }
      }

      if (recruiter != null) {
        result.add(
          JobOfferWithRecruiter(
            recruiter: recruiter, jobOffer: job,
          ),
        );
      }
    }

    return result;
  }
}
