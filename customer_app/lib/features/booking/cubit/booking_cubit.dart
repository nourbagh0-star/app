import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/shared_ui.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repo;

  BookingCubit({BookingRepository? repo})
      : _repo = repo ?? BookingRepository(),
        super(BookingInitial());

  Future<void> confirmBooking({
    required String userId,
    required String customerName,
    required String shopId,
    required String shopName,
    required String barberId,
    required String barberName,
    required String serviceName,
    required List<String> serviceIds,
    required DateTime dateTime,
  }) async {
    emit(BookingLoading());
    try {
      await _repo.createBookingWithTransaction(
        customerId: userId,
        customerName: customerName,
        shopId: shopId,
        shopName: shopName,
        barberId: barberId,
        barberName: barberName,
        serviceName: serviceName,
        serviceIds: serviceIds,
        dateTime: dateTime,
      );
      emit(BookingSuccess());
    } on BookingConflictException catch (e) {
      emit(BookingError(e.message));
    } catch (e) {
      emit(BookingError('Failed to book appointment. Please try again.'));
    }
  }
}
