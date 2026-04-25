import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _promoEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildToggleTile(
                    title: 'Push Notifications',
                    subtitle: 'New bookings & updates',
                    icon: Icons.notifications_active_outlined,
                    value: _pushEnabled,
                    onChanged: (val) => setState(() => _pushEnabled = val),
                  ),
                  Divider(color: AppColors.divider, height: 1, indent: 64.w),
                  _buildToggleTile(
                    title: 'SMS Reminders',
                    subtitle: 'Appointment reminders',
                    icon: Icons.sms_outlined,
                    value: _smsEnabled,
                    onChanged: (val) => setState(() => _smsEnabled = val),
                  ),
                  Divider(color: AppColors.divider, height: 1, indent: 64.w),
                  _buildToggleTile(
                    title: 'Promotional Emails',
                    subtitle: 'Offers and news',
                    icon: Icons.email_outlined,
                    value: _promoEnabled,
                    onChanged: (val) => setState(() => _promoEnabled = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 2.h),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryGold,
            inactiveTrackColor: AppColors.surfaceLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
