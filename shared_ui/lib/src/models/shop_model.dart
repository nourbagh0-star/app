import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationInMinutes;
  final String description;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInMinutes,
    this.description = '',
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      durationInMinutes: (data['durationInMinutes'] as int?) ?? 30,
      description: data['description'] as String? ?? '',
    );
  }

  factory ServiceModel.fromMap(String id, Map<String, dynamic> data) {
    return ServiceModel(
      id: id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      durationInMinutes: (data['durationInMinutes'] as int?) ?? 30,
      description: data['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'durationInMinutes': durationInMinutes,
        'description': description,
      };
}

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final GeoPoint? geoPoint;
  final double rating;
  final int reviewCount;
  final List<String> imagesList;
  final bool isApproved;
  final List<String> categories; // e.g. ['Haircut', 'Beard']
  final Map<String, dynamic> businessHours;
  // Populated lazily via subcollection fetches
  final List<ServiceModel> services;
  final List<BarberModel> barbers;

  const ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    this.geoPoint,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imagesList = const [],
    this.isApproved = false,
    this.categories = const [],
    this.businessHours = const {},
    this.services = const [],
    this.barbers = const [],
  });

  /// Primary cover image (first in list, or placeholder).
  String get coverImageUrl =>
      imagesList.isNotEmpty ? imagesList.first : '';

  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShopModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? (data['location'] as String? ?? ''),
      geoPoint: data['geoPoint'] as GeoPoint?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as int?) ?? 0,
      imagesList: List<String>.from(data['imagesList'] as List? ?? []),
      isApproved: data['isApproved'] as bool? ?? false,
      categories: List<String>.from(data['categories'] as List? ?? []),
      businessHours: Map<String, dynamic>.from(data['businessHours'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'address': address,
        if (geoPoint != null) 'geoPoint': geoPoint,
        'rating': rating,
        'reviewCount': reviewCount,
        'imagesList': imagesList,
        'isApproved': isApproved,
        'categories': categories,
        'businessHours': businessHours,
      };

  ShopModel copyWith({
    List<ServiceModel>? services,
    List<BarberModel>? barbers,
    List<String>? imagesList,
    List<String>? categories,
    Map<String, dynamic>? businessHours,
    double? rating,
    int? reviewCount,
  }) {
    return ShopModel(
      id: id,
      ownerId: ownerId,
      name: name,
      address: address,
      geoPoint: geoPoint,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imagesList: imagesList ?? this.imagesList,
      isApproved: isApproved,
      categories: categories ?? this.categories,
      businessHours: businessHours ?? this.businessHours,
      services: services ?? this.services,
      barbers: barbers ?? this.barbers,
    );
  }
}

class BarberModel {
  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String bio;
  final String phone;
  final Map<String, dynamic> workingHours;
  final List<String> portfolioImages;

  const BarberModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.specialty = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bio = '',
    this.phone = '',
    this.workingHours = const {},
    this.portfolioImages = const [],
  });

  factory BarberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BarberModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      specialty: data['specialty'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as int?) ?? 0,
      bio: data['bio'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      workingHours: Map<String, dynamic>.from(data['workingHours'] as Map? ?? {}),
      portfolioImages: List<String>.from(data['portfolioImages'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'specialty': specialty,
        'rating': rating,
        'reviewCount': reviewCount,
        'bio': bio,
        'phone': phone,
        'workingHours': workingHours,
        'portfolioImages': portfolioImages,
      };
}

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime dt = DateTime.now();
    final raw = data['createdAt'];
    if (raw is Timestamp) dt = raw.toDate();
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      createdAt: dt,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
