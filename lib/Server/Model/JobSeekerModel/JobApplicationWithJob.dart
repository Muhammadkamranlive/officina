import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobOffer.dart';

class JobApplicationWithJob {
  final JobApplicationModel application;
  final JobOffer job;

  JobApplicationWithJob({
    required this.application,
    required this.job,
  });

  bool get canChat => application.canChat;
  bool get isAccepted => application.isAccepted;
}
