import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class ServiceSelector extends StatelessWidget {
  final List<ServiceModel> services;
  final List<ServiceModel> selectedServices;
  final Function(ServiceModel) onSelect;

  const ServiceSelector({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final isSelected = selectedServices.any((s) => s.id == service.id);
          
          return GestureDetector(
            onTap: () => onSelect(service),
            child: Container(
              width: 140.w,
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGold : AppColors.divider,
                  width: isSelected ? 2 : 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.content_cut,
                        color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                        size: 24.sp,
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGold,
                          size: 18.sp,
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    service.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(0)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${service.durationInMinutes} min',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
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
