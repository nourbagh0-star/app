part of 'appointments_cubit.dart';

abstract class AppointmentsState {}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<BookingModel> bookings;
  AppointmentsLoaded(this.bookings);
}

class AppointmentsError extends AppointmentsState {
  final String message;
  AppointmentsError(this.message);
}
