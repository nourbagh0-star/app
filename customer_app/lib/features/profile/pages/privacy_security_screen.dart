import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Privacy & Security', style: AppTypography.heading3),
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
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    leading: const Icon(Icons.lock_outline, color: AppColors.textPrimary),
                    title: Text('Change Password', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                    onTap: () {
                      // Handle password change
                    },
                  ),
                  Divider(color: AppColors.divider, height: 1, indent: 60.w),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    leading: const Icon(Icons.fingerprint, color: AppColors.textPrimary),
                    title: Text('Face ID / Touch ID', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    trailing: Switch(
                      value: _biometricsEnabled,
                      activeThumbColor: AppColors.primaryGold,
                      inactiveTrackColor: AppColors.surfaceLight,
                      onChanged: (val) => setState(() => _biometricsEnabled = val),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Delete Account', style: AppTypography.bodyLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () => _showDeleteDialog(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Account', style: AppTypography.heading3.copyWith(color: AppColors.error)),
        content: Text('Are you sure you want to permanently delete your account? This action cannot be undone.', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.buttonText.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // handle deletion
            },
            child: Text('Delete', style: AppTypography.buttonText.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
