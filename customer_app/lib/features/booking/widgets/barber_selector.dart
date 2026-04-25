import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class BarberSelector extends StatelessWidget {
  final List<BarberModel> barbers;
  final BarberModel? selectedBarber;
  final Function(BarberModel) onSelect;

  const BarberSelector({
    super.key,
    required this.barbers,
    required this.selectedBarber,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: barbers.length,
        itemBuilder: (context, index) {
          final barber = barbers[index];
          final isSelected = barber.id == selectedBarber?.id;
          return GestureDetector(
            onTap: () => onSelect(barber),
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGold : AppColors.divider,
                  width: isSelected ? 2 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PremiumImage(
                    imageUrl: barber.imageUrl,
                    width: 50.w,
                    height: 50.w,
                    borderRadius: 25.r,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    barber.name.split(' ').first,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
