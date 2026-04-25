import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import '../booking/widgets/date_selector.dart';
import '../booking/widgets/time_slot_selector.dart';

class RescheduleScreen extends StatefulWidget {
  final String appointmentId;
  const RescheduleScreen({super.key, required this.appointmentId});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  BookingModel? _booking;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isSubmitting = false;
  Set<String> _bookedSlots = {};
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppointmentsCubit>().state;
    if (state is AppointmentsLoaded) {
      try {
        _booking = state.bookings
            .firstWhere((b) => b.id == widget.appointmentId);
        _selectedDate = _booking!.dateTime;
      } catch (_) {}
    }
    if (_booking != null) _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    if (_booking == null) return;
    setState(() {
      _loadingSlots = true;
      _bookedSlots = {};
    });
    try {
      final slots = await BookingRepository().fetchBookedSlotsForBarber(
        _booking!.barberId,
        _selectedDate,
      );
      // Don't mark the booking's own current slot as booked
      final currentSlot =
          BookingRepository.slotLabelFromDateTime(_booking!.dateTime);
      slots.remove(currentSlot);
      if (mounted) setState(() => _bookedSlots = slots);
    } catch (_) {
      if (mounted) setState(() => _bookedSlots = {});
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _onConfirm() async {
    if (_booking == null || _selectedTime == null) return;

    final isPM = _selectedTime!.contains('PM');
    final cleaned =
        _selectedTime!.replaceAll(' AM', '').replaceAll(' PM', '');
    final parts = cleaned.split(':');
    int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final newDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    setState(() => _isSubmitting = true);
    try {
      await context
          .read<AppointmentsCubit>()
          .rescheduleBooking(_booking!.id, newDateTime);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 28),
              SizedBox(width: 8.w),
              Expanded(
                  child: Text('Rescheduled!',
                      style: AppTypography.heading3)),
            ],
          ),
          content: Text(
            'Your appointment at ${_booking!.shopName} has been moved to '
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at $_selectedTime.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                ctx.pop();
                context.go('/history');
              },
              child: Text(
                'View Bookings',
                style: AppTypography.buttonText
                    .copyWith(color: AppColors.primaryGold),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Reschedule', style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: _booking == null
          ? Center(
              child: Text('Booking not found.',
                  style: AppTypography.bodyMedium),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentBookingCard(),
                  SizedBox(height: 32.h),
                  Text('Select New Date',
                      style: AppTypography.heading3),
                  SizedBox(height: 12.h),
                  DateSelector(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _selectedTime = null;
                      });
                      _loadBookedSlots();
                    },
                  ),
                  SizedBox(height: 32.h),
                  Text('Select New Time',
                      style: AppTypography.heading3),
                  SizedBox(height: 12.h),
                  TimeSlotSelector(
                    selectedTime: _selectedTime,
                    onSelect: (time) =>
                        setState(() => _selectedTime = time),
                    bookedSlots: _bookedSlots,
                    isLoading: _loadingSlots,
                  ),
                  SizedBox(height: 120.h),
                ],
              ),
            ),
      bottomSheet: _booking == null
          ? null
          : Container(
              color: AppColors.background,
              padding: EdgeInsets.all(20.w),
              child: _isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold))
                  : PrimaryButton(
                      text: 'Confirm Reschedule',
                      onPressed:
                          _selectedTime != null ? _onConfirm : null,
                    ),
            ),
    );
  }

  Widget _buildCurrentBookingCard() {
    final b = _booking!;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Booking',
            style: AppTypography.label.copyWith(
                color: AppColors.primaryGold, letterSpacing: 1.5),
          ),
          SizedBox(height: 12.h),
          Text(b.shopName,
              style: AppTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text(b.serviceName,
              style: AppTypography.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 12.h),
          const Divider(color: AppColors.divider),
          SizedBox(height: 8.h),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.textHint),
              SizedBox(width: 8.w),
              Text(
                '${b.dateTime.day}/${b.dateTime.month}/${b.dateTime.year}',
                style: AppTypography.bodyMedium,
              ),
              SizedBox(width: 20.w),
              const Icon(Icons.access_time,
                  size: 16, color: AppColors.textHint),
              SizedBox(width: 8.w),
              Text(
                '${b.dateTime.hour}:${b.dateTime.minute.toString().padLeft(2, '0')}',
                style: AppTypography.bodyMedium,
              ),
              SizedBox(width: 20.w),
              const Icon(Icons.person_outline,
                  size: 16, color: AppColors.textHint),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(b.barberName,
                    style: AppTypography.bodyMedium,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
