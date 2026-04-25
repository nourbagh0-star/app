import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, canceled, completed }

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.canceled:
        return 'canceled';
      case BookingStatus.completed:
        return 'completed';
    }
  }

  static BookingStatus fromString(String? s) {
    switch (s) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'canceled':
        return BookingStatus.canceled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  /// Display label for UI tabs
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Upcoming';
      case BookingStatus.confirmed:
        return 'Upcoming';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }
}

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String shopId;
  final String shopName;
  final String barberId;
  final String barberName;
  final String serviceName;
  final List<String> serviceIds;
  final DateTime dateTime;
  final BookingStatus status;
  final bool isWalkIn;

  const BookingModel({
    required this.id,
    required this.customerId,
    this.customerName = '',
    required this.shopId,
    required this.shopName,
    required this.barberId,
    required this.barberName,
    required this.serviceName,
    this.serviceIds = const [],
    required this.dateTime,
    this.status = BookingStatus.pending,
    this.isWalkIn = false,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime dt;
    final raw = data['dateTime'];
    if (raw is Timestamp) {
      dt = raw.toDate();
    } else if (raw is String) {
      dt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] as String? ?? data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      barberId: data['barberId'] as String? ?? '',
      barberName: data['barberName'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      serviceIds: List<String>.from(data['serviceIds'] as List? ?? []),
      dateTime: dt,
      status: BookingStatusX.fromString(data['status'] as String?),
      isWalkIn: data['isWalkIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'shopId': shopId,
        'shopName': shopName,
        'barberId': barberId,
        'barberName': barberName,
        'serviceName': serviceName,
        'serviceIds': serviceIds,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': status.value,
        'isWalkIn': isWalkIn,
      };

  BookingModel copyWith({BookingStatus? status, bool? isWalkIn}) {
    return BookingModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      shopId: shopId,
      shopName: shopName,
      barberId: barberId,
      barberName: barberName,
      serviceName: serviceName,
      serviceIds: serviceIds,
      dateTime: dateTime,
      status: status ?? this.status,
      isWalkIn: isWalkIn ?? this.isWalkIn,
    );
  }
}
