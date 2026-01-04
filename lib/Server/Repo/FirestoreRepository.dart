// lib/core/repositories/firestore_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreRepository<T> {
  final CollectionReference collection;

  FirestoreRepository(String collectionPath)
      : collection = FirebaseFirestore.instance.collection(collectionPath);

  T fromMap(Map<String, dynamic> map, String id);
  Map<String, dynamic> toMap(T entity);

  Future<String> add(T entity) async {
    final docRef = await collection.add(toMap(entity));
    return docRef.id;
  }

  Future<void> update(String id, T entity) async {
    await collection.doc(id).update(toMap(entity));
  }

  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  Future<T?> getById(String id) async {
    final doc = await collection.doc(id).get();
    if (doc.exists) {
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<List<T>> streamAll() {
    return collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  

}
