import 'package:cloud_firestore/cloud_firestore.dart';
import '../dummy_data/dummy_data.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic method to fetch a collection
  Future<List<Map<String, dynamic>>> getCollection(String collectionPath) async {
    final snapshot = await _firestore.collection(collectionPath).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Generic method to stream a collection
  Stream<List<Map<String, dynamic>>> getCollectionStream(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList()
    );
  }

  // Generic method to add a document
  Future<String> addDocument(String collectionPath, Map<String, dynamic> data) async {
    final docRef = await _firestore.collection(collectionPath).add(data);
    return docRef.id;
  }

  // Generic method to update a document
  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  // Generic method to delete a document
  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  // Stream appointments for a specific user
  Stream<List<Map<String, dynamic>>> getUserAppointmentsStream(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Seed Dummy Data to Firestore
  Future<void> seedDummyData() async {
    final batch = _firestore.batch();
    
    // Seed Shops
    for (var shop in DummyData.dummyShops) {
      final shopRef = _firestore.collection('shops').doc(shop.id);
      batch.set(shopRef, {
        'name': shop.name,
        'imageUrl': shop.imageUrl,
        'rating': shop.rating,
        'distance': shop.distance,
        'description': shop.description,
        'location': shop.location,
      });

      // Seed Shop Services
      for (var service in shop.services) {
        final serviceRef = shopRef.collection('services').doc(service.id);
        batch.set(serviceRef, {
          'name': service.name,
          'price': service.price,
          'durationMinutes': service.durationMinutes,
        });
      }

      // Seed Shop Barbers
      for (var barber in shop.barbers) {
        final barberRef = shopRef.collection('barbers').doc(barber.id);
        batch.set(barberRef, {
          'name': barber.name,
          'imageUrl': barber.imageUrl,
          'specialty': barber.specialty,
          'rating': barber.rating,
          'bio': barber.bio,
        });
      }
    }

    await batch.commit();
  }
}
