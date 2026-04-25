import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  late final BarberScheduleCubit _scheduleCubit;

  @override
  void initState() {
    super.initState();
    _scheduleCubit = BarberScheduleCubit();
    _loadBookingsForDate(_selectedDate);
  }

  void _loadBookingsForDate(DateTime date) {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded && userState.shopId.isNotEmpty) {
      _scheduleCubit.loadBookingsForDate(userState.shopId, date);
    }
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scheduleCubit,
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, userState) {
          if (userState is UserLoaded && userState.shopId.isNotEmpty) {
            _scheduleCubit.loadBookingsForDate(userState.shopId, _selectedDate);
          }
        },
        builder: (context, userState) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(context.tr('schedule_title'), style: AppTypography.heading2),
              backgroundColor: AppColors.background,
              elevation: 0,
              actions: [
                if (userState is UserLoaded)
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primaryGold),
                    onPressed: () => _showWalkInDialog(context, userState.user),
                  ),
              ],
            ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _selectedDate,
              calendarFormat: CalendarFormat.week,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _selectedDate = selectedDay);
                _loadBookingsForDate(selectedDay);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                ),
                todayTextStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.primaryGold),
                defaultTextStyle: AppTypography.bodyMedium,
                weekendTextStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTypography.heading3,
                leftChevronIcon:
                    const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                rightChevronIcon:
                    const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
            ),
            const Divider(color: AppColors.divider),
            Expanded(
              child: BlocBuilder<BarberScheduleCubit, BarberScheduleState>(
                builder: (context, state) {
                  if (state is BarberScheduleLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold),
                    );
                  }
                  if (state is BarberScheduleError) {
                    return Center(
                      child: Text('Error: ${state.message}',
                          style: AppTypography.bodyMedium),
                    );
                  }

                  List<BookingModel> bookings = [];
                  if (state is BarberScheduleLoaded) {
                    bookings = state.bookings;
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryGold,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      _loadBookingsForDate(_selectedDate);
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(20.w),
                    itemCount: 25, // 9:00 AM to 9:00 PM
                    itemBuilder: (context, index) {
                      final hour = 9 + (index ~/ 2);
                      final minute = (index % 2) == 0 ? 0 : 30;
                      final timeString = '$hour:${minute == 0 ? '00' : '30'}';
                      // Find if there is a booking at this time
                      final booking = bookings.where((b) =>
                          b.dateTime.hour == hour &&
                          b.dateTime.minute == minute &&
                          b.status != BookingStatus.canceled).firstOrNull;

                      return Container(
                        height: 80.h,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: AppColors.divider, width: 0.5)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60.w,
                              child: Text(
                                timeString,
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textHint),
                              ),
                            ),
                            if (booking != null)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showBookingOptions(context, booking),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.h),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold
                                          .withValues(alpha: 0.1),
                                      border: Border(
                                          left: BorderSide(
                                              color: AppColors.primaryGold,
                                              width: 4.w)),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(booking.serviceName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                    color: AppColors.primaryGold)),
                                        Text(
                                            booking.customerName.isNotEmpty ? booking.customerName : context.tr('customer'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.bodySmall),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: Text(context.tr('available'),
                                        style: AppTypography.bodySmall
                                            .copyWith(color: AppColors.textHint)),
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
      },
    ),
  );
}

  void _showBookingOptions(BuildContext context, BookingModel b) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        final hour = b.dateTime.hour;
        final minuteStr = b.dateTime.minute.toString().padLeft(2, '0');
        final amPm = hour < 12 ? 'AM' : 'PM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final dateStr = '${b.dateTime.day}/${b.dateTime.month}/${b.dateTime.year}';

        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('appointment_details'), style: AppTypography.heading3),
              SizedBox(height: 16.h),
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.textHint, size: 20),
                  SizedBox(width: 8.w),
                  Text('${context.tr('customer')}: ${b.customerName.isNotEmpty ? b.customerName : b.customerId.substring(0, 8)}', style: AppTypography.bodyMedium),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.content_cut, color: AppColors.textHint, size: 20),
                  SizedBox(width: 8.w),
                  Text('${context.tr('service')}: ${b.serviceName}', style: AppTypography.bodyMedium),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.textHint, size: 20),
                  SizedBox(width: 8.w),
                  Text('${context.tr('time')}: $dateStr at $displayHour:$minuteStr $amPm', style: AppTypography.bodyMedium),
                ],
              ),
              SizedBox(height: 24.h),
              if (b.status == BookingStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('cancel'),
                        isOutline: true,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _scheduleCubit.cancelBooking(b.id);
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('confirm'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _scheduleCubit.confirmBooking(b.id);
                        },
                      ),
                    ),
                  ],
                ),
              ] else if (b.status == BookingStatus.confirmed) ...[
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('cancel'),
                        isOutline: true,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _scheduleCubit.cancelBooking(b.id);
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('mark_complete'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _scheduleCubit.completeBooking(b.id);
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    '${context.tr('booking_status')} ${b.status.value}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  void _showWalkInDialog(BuildContext context, UserModel barberUser) async {
    // Show a small loading indicator while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
    );

    List<BarberModel> barbers = [];
    try {
      barbers = await ShopRepository().fetchShopBarbers(barberUser.shopId);
    } catch (_) {}

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading safely
    }

    if (barbers.isEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barbers found in shop.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (!context.mounted) return;

    final nameController = TextEditingController();
    final serviceController = TextEditingController(text: 'Walk-in Haircut');
    
    // Generate time slots
    final slots = <String>[];
    for (int i = 0; i < 25; i++) {
      final hour = 9 + (i ~/ 2);
      final minute = (i % 2) == 0 ? 0 : 30;
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
    String selectedSlot = slots.first;
    BarberModel selectedBarber = barbers.first;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Walk-in', style: AppTypography.heading3),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: nameController,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Customer Name',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: serviceController,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Service (e.g. Haircut)',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.divider, width: 0.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BarberModel>(
                              value: selectedBarber,
                              isExpanded: true,
                              dropdownColor: AppColors.surface,
                              icon: const Icon(Icons.person, color: AppColors.textHint),
                              style: AppTypography.bodyLarge,
                              items: barbers.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                              onChanged: (val) => setModalState(() => selectedBarber = val!),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.divider, width: 0.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSlot,
                              isExpanded: true,
                              dropdownColor: AppColors.surface,
                              icon: const Icon(Icons.access_time, color: AppColors.textHint),
                              style: AppTypography.bodyLarge,
                              items: slots.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => setModalState(() => selectedSlot = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    text: isSaving ? 'Saving...' : 'Add Walk-in',
                    isFullWidth: true,
                    onPressed: isSaving ? null : () async {
                      if (nameController.text.trim().isEmpty) return;
                      setModalState(() => isSaving = true);

                      final timeParts = selectedSlot.split(':');
                      final hour = int.parse(timeParts[0]);
                      final minute = int.parse(timeParts[1]);
                      final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, minute);

                      try {
                        await BookingRepository().createBookingWithTransaction(
                          customerId: 'walk-in',
                          customerName: '${nameController.text.trim()} (Walk-in)',
                          shopId: barberUser.shopId,
                          shopName: '',
                          barberId: selectedBarber.id,
                          barberName: selectedBarber.name,
                          serviceName: serviceController.text.trim(),
                          serviceIds: [],
                          dateTime: dt,
                          isWalkIn: true,
                        );
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          _loadBookingsForDate(_selectedDate);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Walk-in added.'), backgroundColor: AppColors.success),
                          );
                        }
                      } catch (e) {
                         setModalState(() => isSaving = false);
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                            );
                         }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
