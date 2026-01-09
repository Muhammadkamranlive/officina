import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/Recruiter.dart';

class JobOfferWithRecruiter {
  /// Job offer document
  final JobOffer jobOffer;

  /// Recruiter (pharmacy) document
  final Recruiter recruiter;

  JobOfferWithRecruiter({
    required this.jobOffer,
    required this.recruiter,
  });

  /* ----------------------------------------------------
   * Convenience getters (very useful in UI)
   * --------------------------------------------------*/

  // Job
  String get jobId => jobOffer.docId ?? '';
  String get jobTitle => jobOffer.jobTitle;
  String get jobType => jobOffer.jobType;
  String get salary => jobOffer.salary;
  List<String> get skills => jobOffer.skills;
  DateTime get createdAt => jobOffer.createdAt;

  // Recruiter / Pharmacy
  String get recruiterUserId => recruiter.userId;
  String get pharmacyName => recruiter.pharmacyName;
  String get recruiterName =>
      '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}';

  String get city => recruiter.city;
  String get province => recruiter.province;
  String get streetAddress => recruiter.streetAddress;

  double get latitude => recruiter.latitude;
  double get longitude => recruiter.longitude;
}
