import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final authState = context.read<AuthCubit>().state;
    String? uid;
    if (authState is AuthCustomer) uid = authState.user.uid;
    if (authState is AuthAuthenticated) uid = authState.user.uid;
    if (uid != null) {
      context.read<AppointmentsCubit>().loadAppointments(uid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('bookings_title'), style: AppTypography.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textHint,
          tabs: [
            Tab(text: context.tr('upcoming')),
            Tab(text: context.tr('past')),
            Tab(text: context.tr('canceled')),
          ],
        ),
      ),
      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            );
          }
          if (state is AppointmentsError) {
            return Center(
              child: Text('Error: ${state.message}',
                  style: AppTypography.bodyMedium),
            );
          }

          final bookings =
              state is AppointmentsLoaded ? state.bookings : <BookingModel>[];

          final upcoming = bookings
              .where((b) =>
                  b.status == BookingStatus.pending ||
                  b.status == BookingStatus.confirmed)
              .toList();
          final past = bookings
              .where((b) =>
                  b.dateTime.isBefore(DateTime.now()) &&
                  b.status != BookingStatus.canceled)
              .toList();
          final canceled = bookings
              .where((b) => b.status == BookingStatus.canceled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(upcoming, 'upcoming'),
              _buildList(past, 'past'),
              _buildList(canceled, 'canceled'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 48.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text('No $type appointments.',
                style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGold,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        final authState = context.read<AuthCubit>().state;
        String? uid;
        if (authState is AuthCustomer) uid = authState.user.uid;
        if (authState is AuthAuthenticated) uid = authState.user.uid;
        if (uid != null) {
          context.read<AppointmentsCubit>().loadAppointments(uid);
        }
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          return _buildCard(b, type);
        },
      ),
    );
  }

  Widget _buildCard(BookingModel b, String type) {
    final dt = b.dateTime;
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final isUpcoming = type == 'upcoming';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '$day/$month/${dt.year}  $hour:$minute',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primaryGold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              _buildStatusChip(b.status),
            ],
          ),
          SizedBox(height: 12.h),
          Text(b.shopName,
              style: AppTypography.heading3.copyWith(fontSize: 16.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text('with ${b.barberName}',
              style: AppTypography.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 4.h),
          Text(b.serviceName,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (isUpcoming) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: context.tr('reschedule'),
                    isOutline: true,
                    onPressed: () => context.push('/reschedule/${b.id}'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    text: context.tr('cancel'),
                    onPressed: () => _showCancelDialog(b.id),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String label;
    switch (status) {
      case BookingStatus.confirmed:
        color = AppColors.success;
        label = context.tr('confirmed');
        break;
      case BookingStatus.canceled:
        color = AppColors.error;
        label = context.tr('canceled');
        break;
      default:
        color = AppColors.primaryGold;
        label = context.tr('pending');
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label,
          style: AppTypography.bodySmall
              .copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('cancel_appointment'), style: AppTypography.heading3),
        content: Text(
          context.tr('cancel_confirm'),
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('no'),
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AppointmentsCubit>().cancelBooking(bookingId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(context.tr('appointment_canceled')),
                    backgroundColor: AppColors.error),
              );
            },
            child: Text(context.tr('yes_cancel'),
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.primaryGold)),
          ),
        ],
      ),
    );
  }
}
