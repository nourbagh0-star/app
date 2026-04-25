import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ForgotPasswordScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // ── Back Button ──
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary, size: 20),
                ),
              ),
              SizedBox(height: 40.h),

              // ── Lock Icon ──
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                  ),
                  child: Icon(Icons.lock_reset,
                      size: 36.sp, color: AppColors.primaryGold),
                ),
              ),
              SizedBox(height: 32.h),

              // ── Header ──
              Center(
                child: Text('Forgot Password?', style: AppTypography.heading1),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Enter the email address associated with your account and we'll send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textHint, height: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              // ── Email Field ──
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textHint, size: 20),
                    hintText: 'Email address',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // ── Send Button ──
              PrimaryButton(
                text: 'Send Reset Link',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reset link sent! Check your email.',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),

              // ── Back to Login ──
              Center(
                child: GestureDetector(
                  onTap: widget.onBack,
                  child: Text(
                    'Back to Log In',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
