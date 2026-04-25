part of 'barber_schedule_cubit.dart';

abstract class BarberScheduleState {}

class BarberScheduleInitial extends BarberScheduleState {}

class BarberScheduleLoading extends BarberScheduleState {}

class BarberScheduleLoaded extends BarberScheduleState {
  final List<BookingModel> bookings;
  final DateTime date;
  BarberScheduleLoaded(this.bookings, this.date);
}

class BarberScheduleError extends BarberScheduleState {
  final String message;
  BarberScheduleError(this.message);
}
