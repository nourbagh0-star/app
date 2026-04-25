import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';

part 'barber_schedule_state.dart';

class BarberScheduleCubit extends Cubit<BarberScheduleState> {
  final BookingRepository _repo;
  StreamSubscription<List<BookingModel>>? _subscription;

  BarberScheduleCubit({BookingRepository? repo})
      : _repo = repo ?? BookingRepository(),
        super(BarberScheduleInitial());

  /// Streams bookings for [shopId] on [date]. Defaults to today.
  void loadBookingsForDate(String shopId, DateTime date) {
    emit(BarberScheduleLoading());
    _subscription?.cancel();
    _subscription = _repo.streamShopBookings(shopId, date).listen(
      (bookings) => emit(BarberScheduleLoaded(bookings, date)),
      onError: (e) => emit(BarberScheduleError(e.toString())),
    );
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      await _repo.confirmBooking(bookingId);
    } catch (e) {
      emit(BarberScheduleError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repo.cancelBooking(bookingId);
    } catch (e) {
      emit(BarberScheduleError(e.toString()));
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      await _repo.completeBooking(bookingId);
    } catch (e) {
      emit(BarberScheduleError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
