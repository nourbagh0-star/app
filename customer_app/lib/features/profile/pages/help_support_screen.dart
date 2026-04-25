import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Help & Support', style: AppTypography.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.headset_mic_outlined, size: 48.sp, color: AppColors.primaryGold),
                  SizedBox(height: 16.h),
                  Text('How can we help you?', style: AppTypography.heading3),
                  SizedBox(height: 8.h),
                  Text('Our support team is available 24/7', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    text: 'Contact Support',
                    onPressed: () {},
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            Text('Frequently Asked Questions', style: AppTypography.heading3),
            SizedBox(height: 16.h),
            _buildFaqItem('How do I cancel my appointment?', 'You can cancel your appointment up to 2 hours before the scheduled time through the Bookings tab.'),
            _buildFaqItem('What payment methods are accepted?', 'We accept all major credit cards including Visa, Mastercard, and American Express.'),
            _buildFaqItem('How do loyalty points work?', 'You earn 10 points for every dollar spent. Points can be redeemed for discounts on future services.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primaryGold,
          collapsedIconColor: AppColors.textHint,
          title: Text(question, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          childrenPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
          children: [
            Text(answer, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
