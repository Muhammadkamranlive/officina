class JobSeeker {
  final String  userId;
  final String? fullName;
  final bool isAnonymous;
  final String desiredPosition;
  final String city;
  final List<String> skills;
  final List<String> authenticatedSkills;
  final String? experience;
  final String? education;

  JobSeeker({
    required this.userId,
    this.fullName,
    required this.isAnonymous,
    required this.desiredPosition,
    required this.city,
    required this.skills,
    required this.authenticatedSkills,
    this.experience,
    this.education,
  });
}
