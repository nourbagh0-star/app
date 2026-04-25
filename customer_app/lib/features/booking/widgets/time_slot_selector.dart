import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class TimeSlotSelector extends StatelessWidget {
  final String? selectedTime;
  final Function(String) onSelect;
  final Set<String> bookedSlots;
  final bool isLoading;

  const TimeSlotSelector({
    super.key,
    required this.selectedTime,
    required this.onSelect,
    this.bookedSlots = const {},
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      );
    }

    final slots = [
      '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
      '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
      '03:00 PM', '03:30 PM',
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: slots.map((time) {
        final isSelected = time == selectedTime;
        final isBooked = bookedSlots.contains(time);

        Color bgColor;
        Color borderColor;
        Color textColor;

        if (isBooked) {
          bgColor = AppColors.surfaceLight;
          borderColor = AppColors.divider;
          textColor = AppColors.textHint;
        } else if (isSelected) {
          bgColor = AppColors.primaryGold;
          borderColor = AppColors.primaryGold;
          textColor = AppColors.background;
        } else {
          bgColor = AppColors.surface;
          borderColor = AppColors.divider;
          textColor = AppColors.textPrimary;
        }

        return GestureDetector(
          onTap: isBooked ? null : () => onSelect(time),
          child: Container(
            width: (MediaQuery.of(context).size.width - 40.w - 24.w) / 3,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            alignment: Alignment.center,
            child: isBooked
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: AppTypography.bodySmall.copyWith(
                          color: textColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Booked',
                        style: AppTypography.bodySmall.copyWith(
                          color: textColor,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  )
                : Text(
                    time,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        );
      }).toList(),
    );
  }
}
