import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';

class JobOfferRepository extends FirestoreRepository<JobOffer> {
  JobOfferRepository() : super('JobOffers');

  @override
  JobOffer fromMap(Map<String, dynamic> map, String id) =>
      JobOffer.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobOffer entity) => entity.toMap(isCreate: true);

  /// Get all job offers created by a recruiter (via userId)
Future<List<JobOffer>> getByUserId(String userId) async {
  final query = await collection
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs
      .map((doc) =>
          JobOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .toList();
}


  /// Get single job offer by document ID (optional helper)
  Future<JobOffer?> getByDocId(String docId) async {
    final doc = await collection.doc(docId).get();
    if (doc.exists) {
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<JobOffer>> getAll() async {
  final query = await collection
     
      .orderBy('createdAt', descending: true)
      .get();

  return query.docs
      .map((doc) =>
          JobOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .toList();
}
}
