import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart' hide AuthState;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthCustomer) {
      context.read<UserCubit>().streamUser(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('profile_title'), style: AppTypography.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // User Header
            BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                final name = userState is UserLoaded ? userState.name : '...';
                final email = userState is UserLoaded ? userState.email : '';
                final profilePicUrl = userState is UserLoaded ? userState.profilePicUrl : '';
                return Row(
                  children: [
                    profilePicUrl.isNotEmpty
                        ? PremiumImage(
                            imageUrl: profilePicUrl,
                            width: 80.w,
                            height: 80.w,
                            borderRadius: 40.r,
                          )
                        : CircleAvatar(
                            radius: 40.r,
                            backgroundColor: AppColors.surfaceLight,
                            child: const Icon(Icons.person, size: 40, color: AppColors.primaryGold),
                          ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: AppTypography.heading2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4.h),
                          Text(email,
                              style: AppTypography.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 32.h),

            // Membership Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceLight, AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('gold_member'), style: AppTypography.heading3.copyWith(color: AppColors.primaryGold)),
                      const Icon(Icons.star, color: AppColors.primaryGold),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text("150 ${context.tr("points_to_tier")}", style: AppTypography.bodyMedium),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Menu Items
            _buildMenuItem(Icons.edit, context.tr('edit_profile'), onTap: () => context.push('/profile/edit')),
            _buildMenuItem(Icons.payment, context.tr('payment_methods'), onTap: () => context.push('/profile/payment')),
            _buildMenuItem(Icons.notifications_none, context.tr('notifications'), onTap: () => context.push('/profile/notifications')),
            _buildMenuItem(Icons.favorite_border, context.tr('favorites'), onTap: () => context.push('/profile/favorites')),
            _buildMenuItem(Icons.security, context.tr('privacy_security'), onTap: () => context.push('/profile/privacy')),
            _buildMenuItem(Icons.help_outline, context.tr('help_support'), onTap: () => context.push('/profile/help')),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                final langLabel = langState.languageCode == 'ru' ? 'Русский' : 'English';
                return _buildMenuItemWithTrailing(
                  Icons.language,
                  context.tr('language'),
                  trailing: langLabel,
                  onTap: _showLanguagePicker,
                );
              },
            ),
            SizedBox(height: 20.h),
            _buildMenuItem(Icons.logout, context.tr('logout'), isDestructive: true, onTap: () {
              context.read<AuthCubit>().signOut();
              context.go('/login');
            }),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('language'), style: AppTypography.heading3),
                  SizedBox(height: 20.h),
                  _buildLanguageOption(ctx, 'en', 'English', '🇬🇧', langState.languageCode),
                  SizedBox(height: 12.h),
                  _buildLanguageOption(ctx, 'ru', 'Русский', '🇷🇺', langState.languageCode),
                  SizedBox(height: 8.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, String code, String label, String flag, String currentCode) {
    final isSelected = currentCode == code;
    return GestureDetector(
      onTap: () {
        context.read<LanguageCubit>().setLanguage(code);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.divider,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: AppTypography.bodyLarge)),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildMenuItemWithTrailing(IconData icon, String title, {required String trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
          SizedBox(width: 4.w),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
      onTap: onTap ?? () {},
    );
  }
}
