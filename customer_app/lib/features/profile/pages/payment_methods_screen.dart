import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment Methods', style: AppTypography.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Cards', style: AppTypography.heading3),
            SizedBox(height: 20.h),
            _buildCardItem(
              brand: 'Visa',
              last4: '4242',
              expiry: '12/26',
              isDefault: true,
            ),
            SizedBox(height: 16.h),
            _buildCardItem(
              brand: 'Mastercard',
              last4: '8888',
              expiry: '04/25',
              isDefault: false,
            ),
            SizedBox(height: 110.h),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(24.w),
        child: PrimaryButton(
          text: 'Add New Card',
          isOutline: true,
          onPressed: () {
            // ScaffoldMessenger.of(context).showSnackBar(...);
          },
          isFullWidth: true,
        ),
      ),
    );
  }

  Widget _buildCardItem({
    required String brand,
    required String last4,
    required String expiry,
    required bool isDefault,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDefault ? AppColors.primaryGold : AppColors.divider,
          width: isDefault ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.credit_card, color: AppColors.primaryGold, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('$brand **** $last4', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    if (isDefault) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('Default', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold)),
                      ),
                    ]
                  ],
                ),
                SizedBox(height: 4.h),
                Text('Expires $expiry', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          if (!isDefault)
            Icon(Icons.more_vert, color: AppColors.textHint, size: 20.sp),
        ],
      ),
    );
  }
}
