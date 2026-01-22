import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';

class ChatUserResolver {
  final RecruiterRepository recruiterRepo = RecruiterRepository();
  final JobSeekerRepository jobSeekerRepo = JobSeekerRepository();

  /// Returns unified user data for chat UI
  Future<Map<String, dynamic>?> resolveUser(String userId) async {
    // 1️⃣ Try recruiter first
    final recruiter = await recruiterRepo.getByUid(userId);
    if (recruiter != null) {
      return {
        'name': "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
        'avatar': recruiter.logoUrl,
      };
    }

    // 2️⃣ Try job seeker
    final seeker = await jobSeekerRepo.getByUid(userId);
    if (seeker != null) {
      return {
        'name': "${seeker.firstName} ${seeker.lastName}",
        'avatar': seeker.logoUrl,
      };
    }

    return null;
  }
}
