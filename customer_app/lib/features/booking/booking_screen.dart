import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import 'cubit/booking_cubit.dart';
import 'widgets/date_selector.dart';
import 'widgets/time_slot_selector.dart';
import 'widgets/barber_selector.dart';
import 'widgets/service_selector.dart';

class BookingScreen extends StatelessWidget {
  final String shopId;
  final ShopModel? shopModel;

  const BookingScreen({super.key, required this.shopId, this.shopModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(),
      child: _BookingView(shopId: shopId, shopModel: shopModel),
    );
  }
}

class _BookingView extends StatefulWidget {
  final String shopId;
  final ShopModel? shopModel;

  const _BookingView({required this.shopId, this.shopModel});

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  ShopModel? _shop;
  bool _loadingShop = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  BarberModel? _selectedBarber;
  final List<ServiceModel> _selectedServices = [];

  Set<String> _bookedSlots = {};
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    if (widget.shopModel != null &&
        (widget.shopModel!.services.isNotEmpty ||
            widget.shopModel!.barbers.isNotEmpty)) {
      _shop = widget.shopModel;
    } else {
      _loadShopDetails();
    }
  }

  Future<void> _loadShopDetails() async {
    setState(() => _loadingShop = true);
    try {
      final repo = ShopRepository();
      final shop = await repo.fetchShopWithDetails(widget.shopId);
      if (mounted) setState(() => _shop = shop);
    } catch (_) {
      if (mounted) setState(() => _shop = widget.shopModel);
    } finally {
      if (mounted) setState(() => _loadingShop = false);
    }
  }

  Future<void> _loadBookedSlots() async {
    if (_selectedBarber == null) return;
    setState(() {
      _loadingSlots = true;
      _bookedSlots = {};
    });
    try {
      final slots = await BookingRepository().fetchBookedSlotsForBarber(
        _selectedBarber!.id,
        _selectedDate,
      );
      if (mounted) setState(() => _bookedSlots = slots);
    } catch (_) {
      if (mounted) setState(() => _bookedSlots = {});
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  double get _totalPrice =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.price);

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Booking Confirmed', style: AppTypography.heading2),
              content: Text(
                'Your appointment at ${_shop?.name ?? 'the shop'} is confirmed.',
                style: AppTypography.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
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
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Book Appointment', style: AppTypography.heading3),
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
        ),
        body: _loadingShop
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGold))
            : _shop == null
                ? Center(
                    child: Text('Failed to load shop.',
                        style: AppTypography.bodyMedium))
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Service',
                              style: AppTypography.heading3),
                          SizedBox(height: 12.h),
                          if (_shop!.services.isNotEmpty)
                            ServiceSelector(
                              services: _shop!.services,
                              selectedServices: _selectedServices,
                              onSelect: (service) {
                                setState(() {
                                  if (_selectedServices
                                      .any((s) => s.id == service.id)) {
                                    _selectedServices
                                        .removeWhere((s) => s.id == service.id);
                                  } else {
                                    _selectedServices.add(service);
                                  }
                                });
                              },
                            )
                          else
                            Text('No services available.',
                                style: AppTypography.bodyMedium),
                          SizedBox(height: 32.h),
                          Text('Select Specialist',
                              style: AppTypography.heading3),
                          SizedBox(height: 12.h),
                          if (_shop!.barbers.isNotEmpty)
                            BarberSelector(
                              barbers: _shop!.barbers,
                              selectedBarber: _selectedBarber,
                              onSelect: (barber) {
                                setState(() {
                                  _selectedBarber = barber;
                                  _selectedTime = null;
                                });
                                _loadBookedSlots();
                              },
                            )
                          else
                            Text('No specialists available.',
                                style: AppTypography.bodyMedium),
                          SizedBox(height: 32.h),
                          Text('Select Date', style: AppTypography.heading3),
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
                          Text('Available Slots',
                              style: AppTypography.heading3),
                          SizedBox(height: 12.h),
                          if (_selectedBarber == null)
                            Text(
                              'Select a specialist to see available slots.',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textHint),
                            )
                          else
                            TimeSlotSelector(
                              selectedTime: _selectedTime,
                              onSelect: (time) =>
                                  setState(() => _selectedTime = time),
                              bookedSlots: _bookedSlots,
                              isLoading: _loadingSlots,
                            ),
                          if (_selectedServices.isNotEmpty ||
                              _selectedBarber != null ||
                              _selectedTime != null) ...[
                            SizedBox(height: 32.h),
                            _buildBookingSummary(),
                          ],
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
        bottomSheet: Container(
          color: AppColors.background,
          padding: EdgeInsets.all(20.w),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final isLoading = state is BookingLoading;
              final canBook = _selectedServices.isNotEmpty &&
                  _selectedBarber != null &&
                  _selectedTime != null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedServices.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedServices.length} service${_selectedServices.length > 1 ? 's' : ''} selected',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          'Total: \$${_totalPrice.toStringAsFixed(0)}',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryGold))
                      : PrimaryButton(
                          text: 'Confirm Booking',
                          isFullWidth: true,
                          onPressed: canBook ? _onConfirm : null,
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final dateStr = '$day/$month/${_selectedDate.year}';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: AppTypography.label.copyWith(
              color: AppColors.primaryGold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          _summaryRow(Icons.content_cut, 'Services',
              _selectedServices.isEmpty
                  ? '—'
                  : _selectedServices.map((s) => s.name).join(', ')),
          SizedBox(height: 10.h),
          _summaryRow(Icons.person_outline, 'Specialist',
              _selectedBarber?.name ?? '—'),
          SizedBox(height: 10.h),
          _summaryRow(Icons.calendar_today, 'Date', dateStr),
          SizedBox(height: 10.h),
          _summaryRow(Icons.access_time, 'Time', _selectedTime ?? '—'),
          if (_selectedServices.isNotEmpty) ...[
            SizedBox(height: 12.h),
            const Divider(color: AppColors.divider),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '\$${_totalPrice.toStringAsFixed(0)}',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textHint),
        SizedBox(width: 10.w),
        SizedBox(
          width: 80.w,
          child: Text(label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textHint)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _onConfirm() {
    final authState = context.read<AuthCubit>().state;
    String? uid;
    if (authState is AuthCustomer) uid = authState.user.uid;
    if (authState is AuthAuthenticated) uid = authState.user.uid;
    if (uid == null || _shop == null || _selectedBarber == null) return;
    if (_selectedServices.isEmpty) return;

    final userState = context.read<UserCubit>().state;
    final customerName = userState is UserLoaded ? userState.user.name : '';

    // Parse time like "09:30 AM" or "01:30 PM"
    final isPM = _selectedTime!.contains('PM');
    final cleaned = _selectedTime!.replaceAll(' AM', '').replaceAll(' PM', '');
    final timeParts = cleaned.split(':');
    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    final bookingDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
    final primaryService = _selectedServices.first;

    context.read<BookingCubit>().confirmBooking(
          userId: uid,
          customerName: customerName,
          shopId: _shop!.id,
          shopName: _shop!.name,
          barberId: _selectedBarber!.id,
          barberName: _selectedBarber!.name,
          serviceName: primaryService.name,
          serviceIds: _selectedServices.map((s) => s.id).toList(),
          dateTime: bookingDateTime,
        );
  }
}
