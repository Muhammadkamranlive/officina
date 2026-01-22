import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';

class JobApplicantViewModel {
  final JobApplicationModel application;
  final JobSeekerModel jobSeeker;

  JobApplicantViewModel({
    required this.application,
    required this.jobSeeker,
  });

  bool get canChat => application.canChat;
  bool get isAccepted => application.isAccepted;
}
