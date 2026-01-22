import 'package:client/Server/Model/ProfileViewModel.dart';
import 'package:client/Server/Model/Recruiter.dart';

class ProfileViewWithRecruiter {
  final ProfileViewsModel view;
  final Recruiter recruiter;

  ProfileViewWithRecruiter({
    required this.view,
    required this.recruiter,
  });
}
