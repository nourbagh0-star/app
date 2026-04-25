import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer' | 'barber'
  final String profilePicUrl;
  final String shopId; // only relevant for barbers
  final List<String> favoriteShopIds;
  final String specialty; // barber job title, e.g. 'Master Barber'

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.profilePicUrl = '',
    this.shopId = '',
    this.favoriteShopIds = const [],
    this.specialty = '',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      profilePicUrl: data['profilePicUrl'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      favoriteShopIds:
          List<String>.from(data['favoriteShopIds'] as List? ?? []),
      specialty: data['specialty'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profilePicUrl': profilePicUrl,
        'shopId': shopId,
        'favoriteShopIds': favoriteShopIds,
        'specialty': specialty,
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePicUrl,
    String? shopId,
    List<String>? favoriteShopIds,
    String? specialty,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      shopId: shopId ?? this.shopId,
      favoriteShopIds: favoriteShopIds ?? this.favoriteShopIds,
      specialty: specialty ?? this.specialty,
    );
  }
}
