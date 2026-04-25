import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Stream all bookings for a customer ───────────────────────────
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final bookings =
          snap.docs.map(BookingModel.fromFirestore).toList();
      bookings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return bookings;
    });
  }

  // ── Stream bookings for a barber's shop on a specific date ───────
  Stream<List<BookingModel>> streamShopBookings(String shopId, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _firestore
        .collection('bookings')
        .where('shopId', isEqualTo: shopId)
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('dateTime', isLessThan: Timestamp.fromDate(dayEnd))
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  // ── Create booking with Firestore transaction ────────────────────
  /// Atomically checks that the selected barber has no booking at the
  /// exact [dateTime], then writes the new booking document.
  /// Throws a [BookingConflictException] if the slot is taken.
  Future<String> createBookingWithTransaction({
    required String customerId,
    required String customerName,
    required String shopId,
    required String shopName,
    required String barberId,
    required String barberName,
    required String serviceName,
    required List<String> serviceIds,
    required DateTime dateTime,
    bool isWalkIn = false,
  }) async {
    late String newDocId;

    await _firestore.runTransaction((tx) async {
      // Check for any existing booking for the same barber at the same datetime
      final conflictSnap = await _firestore
          .collection('bookings')
          .where('barberId', isEqualTo: barberId)
          .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime))
          .where('status', whereIn: [
            BookingStatus.pending.value,
            BookingStatus.confirmed.value,
          ])
          .get();

      if (conflictSnap.docs.isNotEmpty) {
        throw BookingConflictException(
          'This time slot is already booked for the selected specialist. '
          'Please choose a different time.',
        );
      }

      final newRef = _firestore.collection('bookings').doc();
      newDocId = newRef.id;
      tx.set(newRef, {
        'customerId': customerId,
        'customerName': customerName,
        'shopId': shopId,
        'shopName': shopName,
        'barberId': barberId,
        'barberName': barberName,
        'serviceName': serviceName,
        'serviceIds': serviceIds,
        'dateTime': Timestamp.fromDate(dateTime),
        'status': BookingStatus.pending.value,
        'isWalkIn': isWalkIn,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return newDocId;
  }

  // ── Cancel a booking ─────────────────────────────────────────────
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.canceled.value,
    });
  }

  // ── Confirm a booking (barber action) ────────────────────────────
  Future<void> confirmBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.confirmed.value,
    });
  }

  // ── Complete a booking (barber action) ────────────────────────────
  Future<void> completeBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.completed.value,
    });
  }

  // ── Reschedule a booking (customer action) ────────────────────────
  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'dateTime': Timestamp.fromDate(newDateTime),
    });
  }

  // ── Fetch booked time slots for a barber on a given date ──────────
  // Returns a Set of time strings in the same format as TimeSlotSelector
  // e.g. {"09:00 AM", "01:30 PM"} so the UI can gray them out.
  Future<Set<String>> fetchBookedSlotsForBarber(
      String barberId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final snap = await _firestore
        .collection('bookings')
        .where('barberId', isEqualTo: barberId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('dateTime', isLessThan: Timestamp.fromDate(dayEnd))
        .where('status', whereIn: [
          BookingStatus.pending.value,
          BookingStatus.confirmed.value,
        ])
        .get();

    return snap.docs.map((doc) {
      final dt = (doc.data()['dateTime'] as Timestamp).toDate();
      return _slotLabel(dt);
    }).toSet();
  }

  static String slotLabelFromDateTime(DateTime dt) => _slotLabel(dt);

  static String _slotLabel(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final isPM = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }
}

class BookingConflictException implements Exception {
  final String message;
  BookingConflictException(this.message);

  @override
  String toString() => message;
}
