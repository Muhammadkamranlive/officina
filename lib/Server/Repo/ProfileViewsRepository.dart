import 'package:client/Server/Model/JobSeekerModel/ProfileViewsStats.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:client/Server/Model/ProfileViewModel.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class ProfileViewsRepository
    extends FirestoreRepository<ProfileViewsModel> {
  ProfileViewsRepository() : super('ProfileViews');

  @override
  ProfileViewsModel fromMap(Map<String, dynamic> map, String id) =>
      ProfileViewsModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(ProfileViewsModel entity) => entity.toMap();

  /// ✅ Save unique profile view per day per viewer
  Future<void> saveUniqueDailyView({
    required String userId,   // profile owner
    required String viewerId, // logged-in user
  }) async {
    final now = DateTime.now();

    // 🔥 Get all views by this viewer for this profile
    final snap = await collection
        .where('userId', isEqualTo: userId)
        .where('viewerId', isEqualTo: viewerId)
        .get();

    // 🔎 Check if already viewed TODAY
    for (final doc in snap.docs) {
      final createdAt =
          (doc['createdAt'] as Timestamp?)?.toDate();

      if (createdAt != null && isSameDate(createdAt, now)) {
        // ❌ Already viewed today
        return;
      }
    }

    // ✅ New unique daily view → add record
    await collection.add({
      'userId': userId,
      'viewerId': viewerId,
      'counter': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Get TOTAL profile views (sum of counter)
  Future<int> getTotalViews(String userId) async {
    final snap =
        await collection.where('userId', isEqualTo: userId).get();

    int total = 0;
    for (final doc in snap.docs) {
      total += (doc['counter'] as int?) ?? 0;
    }
    return total;
  }

  /// ✅ Get views for a specific DATE
  Future<int> getViewsByDate(String userId, DateTime date) async {
    final snap =
        await collection.where('userId', isEqualTo: userId).get();

    int total = 0;
    for (final doc in snap.docs) {
      final createdAt =
          (doc['createdAt'] as Timestamp?)?.toDate();

      if (createdAt != null && isSameDate(createdAt, date)) {
        total += (doc['counter'] as int?) ?? 0;
      }
    }
    return total;
  }

  /// ✅ Unique viewers count (all time)
  Future<int> getUniqueViewers(String userId) async {
    final snap =
        await collection.where('userId', isEqualTo: userId).get();

    final viewers = snap.docs
        .map((d) => d['viewerId'] as String)
        .toSet();

    return viewers.length;
  }


  Future<List<ProfileViewWithRecruiter>> getViewsWithRecruiters(
  String jobSeekerId,
) async {
  final snap = await collection
      .where('userId', isEqualTo: jobSeekerId)
      .orderBy('createdAt', descending: true)
      .get();
  if (snap.docs.isEmpty) return [];
  
  final recruiterRepo = RecruiterRepository();

  final futures = snap.docs.map((doc) async {
    final view = ProfileViewsModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );

    final recruiter = await recruiterRepo.getByUid(view.viewerId);
    if (recruiter == null) return null;

    return ProfileViewWithRecruiter(
      view: view,
      recruiter: recruiter,
    );
  });

  final results = await Future.wait(futures);
  return results.whereType<ProfileViewWithRecruiter>().toList();
}

}

/// 🔹 Date-only comparison
bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
