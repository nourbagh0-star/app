import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final BookingRepository _repo;
  StreamSubscription<List<BookingModel>>? _subscription;

  AppointmentsCubit({BookingRepository? repo})
      : _repo = repo ?? BookingRepository(),
        super(AppointmentsInitial());

  void loadAppointments(String userId) {
    emit(AppointmentsLoading());
    _subscription?.cancel();
    _subscription = _repo.streamUserBookings(userId).listen(
      (bookings) => emit(AppointmentsLoaded(bookings)),
      onError: (e) => emit(AppointmentsError(e.toString())),
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repo.cancelBooking(bookingId);
      // Stream will automatically update the state
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    try {
      await _repo.rescheduleBooking(bookingId, newDateTime);
      // Stream will automatically update the state
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
