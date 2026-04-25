// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _smsReminders = true;
  bool _emailNotifications = false;

  // Business hours
  final Map<String, bool> _workingDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': false,
  };
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _businessHoursDirty = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthBarber) {
      context.read<UserCubit>().streamUser(authState.user.uid);
    }
    _loadBusinessHours();
  }

  Future<void> _loadBusinessHours() async {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded || userState.user.shopId.isEmpty) return;
    final shop = await ShopRepository().fetchShop(userState.user.shopId);
    if (shop == null || shop.businessHours.isEmpty) return;
    final hours = shop.businessHours;
    setState(() {
      for (final day in _workingDays.keys) {
        final dayData = hours[day] as Map<String, dynamic>?;
        if (dayData != null) {
          _workingDays[day] = dayData['isOpen'] as bool? ?? _workingDays[day]!;
        }
      }
      final startStr = (hours['startTime'] as String?) ?? '9:00';
      final endStr = (hours['endTime'] as String?) ?? '18:00';
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');
      _startTime = TimeOfDay(
        hour: int.tryParse(startParts[0]) ?? 9,
        minute: int.tryParse(startParts.length > 1 ? startParts[1] : '0') ?? 0,
      );
      _endTime = TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 18,
        minute: int.tryParse(endParts.length > 1 ? endParts[1] : '0') ?? 0,
      );
    });
  }

  Map<String, dynamic> _buildBusinessHoursMap() {
    final map = <String, dynamic>{
      'startTime': '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
    };
    for (final entry in _workingDays.entries) {
      map[entry.key] = {'isOpen': entry.value};
    }
    return map;
  }

  Future<void> _saveBusinessHours() async {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded || userState.user.shopId.isEmpty) return;
    try {
      await ShopRepository().updateShop(
        userState.user.shopId,
        {'businessHours': _buildBusinessHoursMap()},
      );
      setState(() => _businessHoursDirty = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business hours saved.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _showEditProfileDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final specialties = ['Master Barber', 'Beard Specialist', 'Color Expert', 'Hair Stylist', 'Junior Barber', 'Owner'];
    String selectedSpecialty = specialties.contains(user.specialty) ? user.specialty : specialties.first;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('edit_profile'), style: AppTypography.heading3),
                  SizedBox(height: 20.h),
                  _buildEditField(nameController, 'Name', Icons.person_outline),
                  SizedBox(height: 16.h),
                  _buildEditField(phoneController, 'Phone', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  SizedBox(height: 16.h),
                  Text(context.tr('title_label'), style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSpecialty,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
                        style: AppTypography.bodyLarge,
                        items: specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setModalState(() => selectedSpecialty = val!),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    text: context.tr('save'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await context.read<UserCubit>().updateProfile(
                          uid: user.id,
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          specialty: selectedSpecialty,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    nameController.dispose();
    phoneController.dispose();
  }

  Widget _buildEditField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded) return;

    final picker = ImagePicker();
    final userCubit = context.read<UserCubit>();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    try {
      final repo = StorageRepository();
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
      final url = await repo.uploadAvatar(
        userState.user.id,
        await file.readAsBytes(),
        ext,
        bucket: 'barber shop',
      );
      await userCubit.updateProfilePic(userState.user.id, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadShopImage(String shopId) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading shop photo...')),
        );
      }
      final repo = StorageRepository();
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
      final url = await repo.uploadShopPhoto(
        shopId,
        await file.readAsBytes(),
        ext,
      );
      await ShopRepository().addShopImage(shopId, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop photo added successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload shop photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteShopImage(String shopId, String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Photo?', style: AppTypography.heading3),
        content: Text('Are you sure you want to remove this shop photo?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: Text(context.tr('cancel'), style: AppTypography.buttonText.copyWith(color: AppColors.textSecondary))
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text('Delete', style: AppTypography.buttonText.copyWith(color: AppColors.error))
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ShopRepository().removeShopImage(shopId, url);
      await StorageRepository().deleteShopPhoto(shopId, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo deleted.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete photo: $e'), backgroundColor: AppColors.error),
        );
      }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Barber Profile Card ──
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold));
                }
                if (state is UserLoaded) {
                  return _buildProfileCard(state.user);
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 32.h),

            // ── Shop Photos ──
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoaded && state.user.shopId.isNotEmpty) {
                  return _buildShopPhotosSection(state.user.shopId);
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 32.h),

            // ── Business Hours ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('business_hours'), style: AppTypography.heading3),
                if (_businessHoursDirty)
                  TextButton(
                    onPressed: _saveBusinessHours,
                    child: Text('Save', style: AppTypography.buttonText.copyWith(color: AppColors.primaryGold)),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTimeRangeCard(),
            SizedBox(height: 16.h),
            Text(context.tr('working_days'),
                style: AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ..._workingDays.entries.map((e) => _buildDayToggle(e.key, e.value)),
            SizedBox(height: 32.h),

            // ── Notification Preferences ──
            Text(context.tr('notifications'), style: AppTypography.heading3),
            SizedBox(height: 16.h),
            _buildNotificationSection(),
            SizedBox(height: 32.h),

            // ── App Info ──
            _buildInfoSection(),
            SizedBox(height: 24.h),

            // ── Logout ──
            PrimaryButton(
              text: context.tr('logout'),
              isOutline: true,
              onPressed: () => _showLogoutDialog(),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Shop Photos
  // ─────────────────────────────────────────────────────────────────
  Widget _buildShopPhotosSection(String shopId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('shop_photos'), style: AppTypography.heading3),
        SizedBox(height: 16.h),
        StreamBuilder<ShopModel?>(
          stream: ShopRepository().streamShop(shopId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
            }
            final shop = snapshot.data;
            final images = shop?.imagesList ?? [];

            return SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1,
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return GestureDetector(
                      onTap: () => _pickAndUploadShopImage(shopId),
                      child: Container(
                        width: 120.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.primaryGold, width: 1.5, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: AppColors.primaryGold, size: 32.sp),
                            SizedBox(height: 8.h),
                            Text(context.tr('add_photo'), style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold)),
                          ],
                        ),
                      ),
                    );
                  }

                  final url = images[index];
                  return Stack(
                    children: [
                      Container(
                        width: 120.w,
                        margin: EdgeInsets.only(right: 12.w),
                        child: PremiumImage(
                          imageUrl: url,
                          width: 120.w,
                          height: 120.h,
                          borderRadius: 12.r,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 16.w,
                        child: GestureDetector(
                          onTap: () => _deleteShopImage(shopId, url),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 16.sp, color: AppColors.background),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Profile Card
  // ─────────────────────────────────────────────────────────────────
  Widget _buildProfileCard(UserModel user) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              children: [
                PremiumImage(
                  imageUrl: user.profilePicUrl.isNotEmpty
                      ? user.profilePicUrl
                      : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                  width: 80.w,
                  height: 80.w,
                  borderRadius: 40.r,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt,
                        size: 14.sp, color: AppColors.background),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style:
                        AppTypography.heading3.copyWith(fontSize: 18)),
                SizedBox(height: 4.h),
                Text(user.specialty.isNotEmpty ? user.specialty : 'Master Barber', style: AppTypography.bodyMedium),
                SizedBox(height: 8.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: 14.sp, color: AppColors.primaryGold),
                      SizedBox(width: 4.w),
                      Text(
                        '5.0',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditProfileDialog(user),
            child: Icon(Icons.edit, color: AppColors.textHint, size: 20.sp),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Time Range Card
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTimeRangeCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildTimePicker(
                  'Start', _startTime, (t) => setState(() { _startTime = t; _businessHoursDirty = true; }))),
          Container(width: 1, height: 40.h, color: AppColors.divider),
          Expanded(
              child: _buildTimePicker(
                  'End', _endTime, (t) => setState(() { _endTime = t; _businessHoursDirty = true; }))),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryGold,
                  surface: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall),
          SizedBox(height: 4.h),
          Text(
            time.format(context),
            style:
                AppTypography.heading3.copyWith(color: AppColors.primaryGold),
          ),
        ],
      ),
    );
  }

  Widget _buildDayToggle(String day, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: AppTypography.bodyLarge),
          Switch(
            value: isActive,
            activeThumbColor: AppColors.primaryGold,
            inactiveTrackColor: AppColors.surfaceLight,
            onChanged: (val) => setState(() { _workingDays[day] = val; _businessHoursDirty = true; }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Notification Preferences
  // ─────────────────────────────────────────────────────────────────
  Widget _buildNotificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _buildNotificationTile(
            icon: Icons.notifications_outlined,
            title: context.tr('push_notifications'),
            subtitle: context.tr('push_notifications_sub'),
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          Divider(color: AppColors.divider, height: 1, indent: 56.w),
          _buildNotificationTile(
            icon: Icons.sms_outlined,
            title: context.tr('sms_reminders'),
            subtitle: context.tr('sms_reminders_sub'),
            value: _smsReminders,
            onChanged: (v) => setState(() => _smsReminders = v),
          ),
          Divider(color: AppColors.divider, height: 1, indent: 56.w),
          _buildNotificationTile(
            icon: Icons.email_outlined,
            title: context.tr('email_notifications'),
            subtitle: context.tr('email_notifications_sub'),
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryGold, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(subtitle, style: AppTypography.bodySmall),
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

  // ─────────────────────────────────────────────────────────────────
  // Language Picker
  // ─────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────────────────────────
  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showLanguagePicker,
            child: BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                final langLabel = langState.languageCode == 'ru' ? 'Русский' : 'English';
                return _buildInfoRow(Icons.language, context.tr('language'), langLabel);
              },
            ),
          ),
          Divider(color: AppColors.divider, height: 24.h),
          _buildInfoRow(Icons.info_outline, context.tr('app_version'), '1.0.0'),
          Divider(color: AppColors.divider, height: 24.h),
          _buildInfoRow(Icons.shield_outlined, context.tr('privacy_policy'), ''),
          Divider(color: AppColors.divider, height: 24.h),
          _buildInfoRow(Icons.description_outlined, context.tr('terms_of_service'), ''),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String trailing) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textHint, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(title, style: AppTypography.bodyLarge),
        ),
        if (trailing.isNotEmpty)
          Text(trailing, style: AppTypography.bodyMedium)
        else
          Icon(Icons.chevron_right, color: AppColors.textHint, size: 20.sp),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Logout Dialog
  // ─────────────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.error, size: 28),
            SizedBox(width: 8.w),
            Text(context.tr('logout_title'), style: AppTypography.heading3),
          ],
        ),
        content: Text(
          context.tr('logout_confirm'),
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel'),
                style: AppTypography.buttonText
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().signOut();
              GoRouter.of(context).go('/login');
            },
            child: Text(context.tr('logout'),
                style: AppTypography.buttonText
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
