import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';

class SkillVerificationRequestWithJobSeeker {
  final SkillVerificationRequest request;
  final JobSeekerModel jobSeeker;

  SkillVerificationRequestWithJobSeeker({
    required this.request,
    required this.jobSeeker,
  });
}
