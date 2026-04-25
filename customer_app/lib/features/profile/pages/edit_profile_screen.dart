// removed dart:io
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_ui/shared_ui.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthCustomer) {
      context.read<UserCubit>().streamUser(authState.user.uid);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateControllers(UserLoaded state) {
    if (_nameController.text.isEmpty) _nameController.text = state.name;
    if (_emailController.text.isEmpty) _emailController.text = state.email;
    if (_phoneController.text.isEmpty) _phoneController.text = state.phone;
  }

  Future<void> _pickAndUploadImage() async {
    final userState = context.read<UserCubit>().state;
    if (userState is! UserLoaded) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final repo = StorageRepository();
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
      final url = await repo.uploadAvatar(
        userState.user.id,
        await file.readAsBytes(),
        ext,
      );
      await context.read<UserCubit>().updateProfilePic(userState.user.id, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated.'),
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
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveChanges(UserLoaded state) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty'), backgroundColor: AppColors.error),
      );
      return;
    }
    try {
      await context.read<UserCubit>().updateProfile(
            uid: state.user.id,
            name: name,
            phone: phone,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully', style: AppTypography.bodyMedium),
            backgroundColor: AppColors.surface,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) _populateControllers(state);
      },
      builder: (context, state) {
        final userLoaded = state is UserLoaded ? state : null;
        final profilePicUrl = userLoaded?.profilePicUrl ?? '';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Edit Profile', style: AppTypography.heading3),
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Stack(
                      children: [
                        _isUploading
                            ? SizedBox(
                                width: 100.w,
                                height: 100.w,
                                child: const CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                  strokeWidth: 3,
                                ),
                              )
                            : profilePicUrl.isNotEmpty
                                ? PremiumImage(
                                    imageUrl: profilePicUrl,
                                    width: 100.w,
                                    height: 100.w,
                                    borderRadius: 50.r,
                                  )
                                : CircleAvatar(
                                    radius: 50.r,
                                    backgroundColor: AppColors.surfaceLight,
                                    child: const Icon(Icons.person, size: 50, color: AppColors.primaryGold),
                                  ),
                        if (!_isUploading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, size: 16.sp, color: AppColors.background),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 48.h),

                // Form Fields
                _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline),
                SizedBox(height: 20.h),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                SizedBox(height: 20.h),
                _buildTextField(label: 'Phone Number', controller: _phoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                SizedBox(height: 110.h),
              ],
            ),
          ),
          bottomSheet: Container(
            color: AppColors.background,
            padding: EdgeInsets.all(24.w),
            child: PrimaryButton(
              text: 'Save Changes',
              onPressed: userLoaded != null ? () => _saveChanges(userLoaded) : null,
              isFullWidth: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textHint)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: AppTypography.bodyLarge.copyWith(
              color: readOnly ? AppColors.textHint : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18.h),
            ),
          ),
        ),
      ],
    );
  }
}
