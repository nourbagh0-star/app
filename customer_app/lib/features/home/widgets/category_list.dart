import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class CategoryList extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryList({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.content_cut, 'name': 'Haircut'},
      {'icon': Icons.face, 'name': 'Beard'},
      {'icon': Icons.spa, 'name': 'Facial'},
      {'icon': Icons.back_hand, 'name': 'Massage'},
      {'icon': Icons.color_lens, 'name': 'Color'},
    ];

    final double circleDiameter = (60.w).clamp(48.0, 72.0);
    final double iconSize = (24.sp).clamp(18.0, 28.0);

    return SizedBox(
      height: circleDiameter + 8.h + 18.sp + 4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final name = categories[index]['name'] as String;
          final isSelected = name == selectedCategory;

          return GestureDetector(
            onTap: () =>
                onCategorySelected(isSelected ? null : name),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categories[index]['icon'] as IconData,
                      color: isSelected
                          ? AppColors.background
                          : AppColors.primaryGold,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    width: circleDiameter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
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
