import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_ui/shared_ui.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) => onDateSelected(selectedDay),
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
          todayTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.primaryGold),
          defaultTextStyle: AppTypography.bodyMedium,
          weekendTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTypography.heading3,
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
