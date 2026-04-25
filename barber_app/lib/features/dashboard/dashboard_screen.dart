import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final BarberScheduleCubit _scheduleCubit;

  @override
  void initState() {
    super.initState();
    _scheduleCubit = BarberScheduleCubit();
    _loadTodayBookings();
  }

  void _loadTodayBookings() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded && userState.shopId.isNotEmpty) {
      _scheduleCubit.loadBookingsForDate(userState.shopId, DateTime.now());
    }
    // Also listen for auth changes to get shopId as it loads
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
      child: BlocListener<UserCubit, UserState>(
        listener: (context, userState) {
          if (userState is UserLoaded && userState.shopId.isNotEmpty) {
            _scheduleCubit.loadBookingsForDate(
                userState.shopId, DateTime.now());
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(context.tr('dashboard_title'), style: AppTypography.heading2),
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: AppColors.primaryGold),
                onPressed: () {},
              )
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primaryGold,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              _loadTodayBookings();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    String name = '';
                    if (authState is AuthBarber) {
                      name = authState.user.displayName ??
                          authState.user.email ??
                          '';
                    }
                    return Text('Welcome back${name.isNotEmpty ? ', ${name.split(' ').first}' : ''}',
                        style: AppTypography.heading3);
                  },
                ),
                SizedBox(height: 24.h),

                // ── Stats Row ──
                BlocBuilder<BarberScheduleCubit, BarberScheduleState>(
                  builder: (context, state) {
                    final count = state is BarberScheduleLoaded
                        ? state.bookings.length
                        : 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                              context.tr('todays_appointments'),
                              '$count',
                              Icons.calendar_today),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                              context.tr('pending'), '–', Icons.hourglass_empty),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 32.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.tr('todays_schedule'),
                        style: AppTypography.heading3),
                    Text(
                      context.tr('view_calendar'),
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.primaryGold),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Today's Bookings ──
                BlocBuilder<BarberScheduleCubit, BarberScheduleState>(
                  builder: (context, state) {
                    if (state is BarberScheduleLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGold),
                      );
                    }
                    if (state is BarberScheduleError) {
                      return Text('Error: ${state.message}',
                          style: AppTypography.bodyMedium);
                    }
                    if (state is BarberScheduleLoaded) {
                      if (state.bookings.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: Text(context.tr('no_bookings_today'),
                                style: AppTypography.bodyMedium),
                          ),
                        );
                      }
                      return Column(
                        children: state.bookings
                            .map((b) => _buildBookingCard(b))
                            .toList(),
                      );
                    }
                    // If no shopId yet, show a prompt
                    return Padding(
                      padding: EdgeInsets.only(top: 32.h),
                      child: Center(
                        child: Text(
                          context.tr('complete_profile_prompt'),
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 24),
          SizedBox(height: 12.h),
          Text(value,
              style: AppTypography.heading2
                  .copyWith(color: AppColors.primaryGold)),
          SizedBox(height: 4.h),
          Text(title, style: AppTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b) {
    final hour = b.dateTime.hour;
    final minuteStr = b.dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return GestureDetector(
      onTap: () => _showBookingOptions(context, b),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryGold, width: 1),
              ),
              child: Column(
                children: [
                  Text('$displayHour:$minuteStr',
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold)),
                  Text(amPm,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.primaryGold)),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.serviceName,
                      style: AppTypography.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.h),
                  Text('Customer ID: ${b.customerId.length > 6 ? b.customerId.substring(0, 6) : b.customerId}...',
                      style: AppTypography.bodySmall),
                ],
              ),
            ),
            _statusDot(b.status),
          ],
        ),
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
                  Expanded(
                    child: Text('${context.tr("customer")}: ${b.customerName.isNotEmpty ? b.customerName : b.customerId.substring(0, 8)}', style: AppTypography.bodyMedium),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.content_cut, color: AppColors.textHint, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text('Service: ${b.serviceName}', style: AppTypography.bodyMedium),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.textHint, size: 20),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text('Time: $dateStr at $displayHour:$minuteStr $amPm', style: AppTypography.bodyMedium),
                  ),
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
                    'Booking is ${b.status.value}',
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

  Widget _statusDot(BookingStatus status) {
    final color = status == BookingStatus.confirmed
        ? AppColors.success
        : status == BookingStatus.canceled
            ? AppColors.error
            : AppColors.primaryGold;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
