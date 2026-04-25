import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Stream all approved shops ─────────────────────────────────────
  Stream<List<ShopModel>> streamApprovedShops() {
    return _firestore
        .collection('shops')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(ShopModel.fromFirestore).toList());
  }

  // ── Fetch a single shop ───────────────────────────────────────────
  Future<ShopModel?> fetchShop(String shopId) async {
    final doc = await _firestore.collection('shops').doc(shopId).get();
    if (!doc.exists) return null;
    return ShopModel.fromFirestore(doc);
  }

  // ── Stream a single shop ──────────────────────────────────────────
  Stream<ShopModel?> streamShop(String shopId) {
    return _firestore.collection('shops').doc(shopId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ShopModel.fromFirestore(doc);
    });
  }

  // ── Fetch shop with sub-collections ─────────────────────────────
  Future<ShopModel> fetchShopWithDetails(String shopId) async {
    final doc = await _firestore.collection('shops').doc(shopId).get();
    final shop = ShopModel.fromFirestore(doc);

    final servicesDocs =
        await _firestore.collection('shops').doc(shopId).collection('services').get();
    final barbersDocs =
        await _firestore.collection('shops').doc(shopId).collection('barbers').get();

    return shop.copyWith(
      services: servicesDocs.docs.map(ServiceModel.fromFirestore).toList(),
      barbers: barbersDocs.docs.map(BarberModel.fromFirestore).toList(),
    );
  }

  // ── Fetch sub-collections separately ────────────────────────────
  Future<List<ServiceModel>> fetchShopServices(String shopId) async {
    final snap = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .get();
    return snap.docs.map(ServiceModel.fromFirestore).toList();
  }

  Future<List<BarberModel>> fetchShopBarbers(String shopId) async {
    final snap = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('barbers')
        .get();
    return snap.docs.map(BarberModel.fromFirestore).toList();
  }

  // ── Create a new shop ────────────────────────────────────────────
  Future<String> createShop({
    required String ownerId,
    required String name,
    required String address,
  }) async {
    final ref = await _firestore.collection('shops').add({
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'rating': 0.0,
      'imagesList': [],
      'isApproved': true, // Auto-approve for now; set false for admin review
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ── Update shop ──────────────────────────────────────────────────
  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    await _firestore.collection('shops').doc(shopId).update(data);
  }

  // ── Add image URL to shop's imagesList ───────────────────────────
  Future<void> addShopImage(String shopId, String imageUrl) async {
    await _firestore.collection('shops').doc(shopId).update({
      'imagesList': FieldValue.arrayUnion([imageUrl]),
    });
  }

  // ── Remove image URL from shop's imagesList ──────────────────────
  Future<void> removeShopImage(String shopId, String imageUrl) async {
    await _firestore.collection('shops').doc(shopId).update({
      'imagesList': FieldValue.arrayRemove([imageUrl]),
    });
  }

  // ── Service CRUD ─────────────────────────────────────────────────
  Future<String> addService(String shopId, ServiceModel service) async {
    final ref = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .add(service.toMap());
    return ref.id;
  }

  Future<void> updateService(
      String shopId, String serviceId, ServiceModel service) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .doc(serviceId)
        .update(service.toMap());
  }

  Future<void> deleteService(String shopId, String serviceId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('services')
        .doc(serviceId)
        .delete();
  }

  // ── Fetch multiple shops by their IDs ───────────────────────────
  Future<List<ShopModel>> fetchShopsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snap = await _firestore
        .collection('shops')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snap.docs.map(ShopModel.fromFirestore).toList();
  }

  // ── Reviews ──────────────────────────────────────────────────────
  Stream<List<ReviewModel>> streamReviews(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  Future<void> addReview(String shopId, ReviewModel review) async {
    await _firestore.runTransaction((tx) async {
      final shopRef = _firestore.collection('shops').doc(shopId);
      final shopDoc = await tx.get(shopRef);
      final currentRating =
          (shopDoc.data()?['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (shopDoc.data()?['reviewCount'] as int?) ?? 0;
      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;
      final reviewRef = shopRef.collection('reviews').doc();
      tx.set(reviewRef, review.toMap());
      tx.update(shopRef, {
        'rating': double.parse(newRating.toStringAsFixed(1)),
        'reviewCount': newCount,
      });
    });
  }
  // ── Barber Reviews ────────────────────────────────────────────────
  Stream<List<ReviewModel>> streamBarberReviews(String shopId, String barberId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('barbers')
        .doc(barberId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  Future<void> addBarberReview(String shopId, String barberId, ReviewModel review) async {
    await _firestore.runTransaction((tx) async {
      final barberRef = _firestore.collection('shops').doc(shopId).collection('barbers').doc(barberId);
      final barberDoc = await tx.get(barberRef);
      final currentRating = (barberDoc.data()?['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (barberDoc.data()?['reviewCount'] as int?) ?? 0;
      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + review.rating) / newCount;
      final reviewRef = barberRef.collection('reviews').doc();
      tx.set(reviewRef, review.toMap());
      tx.update(barberRef, {
        'rating': double.parse(newRating.toStringAsFixed(1)),
        'reviewCount': newCount,
      });
    });
  }

  // ── Barber CRUD ──────────────────────────────────────────────────
  Future<String> addBarber(String shopId, BarberModel barber) async {
    final ref = await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('barbers')
        .add(barber.toMap());
    return ref.id;
  }

  Future<void> updateBarber(
      String shopId, String barberId, BarberModel barber) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('barbers')
        .doc(barberId)
        .update(barber.toMap());
  }

  Future<void> deleteBarber(String shopId, String barberId) async {
    await _firestore
        .collection('shops')
        .doc(shopId)
        .collection('barbers')
        .doc(barberId)
        .delete();
  }
}
