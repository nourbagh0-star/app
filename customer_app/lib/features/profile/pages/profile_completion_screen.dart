import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthCustomer) context.go('/home');
        if (state is AuthBarber) context.go('/dashboard');
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(28.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  // Header
                  Text('Complete Your Profile',
                      style: AppTypography.heading1),
                  SizedBox(height: 8.h),
                  Text('Tell us a little about yourself to get started.',
                      style: AppTypography.bodyMedium),
                  SizedBox(height: 40.h),

                  // Name
                  Text('Full Name', style: AppTypography.bodyLarge),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. James Carter',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 24.h),

                  // Phone
                  Text('Phone Number', style: AppTypography.bodyLarge),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+1 555 000 0000',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24.h),

                  // Role
                  Text('I am a…', style: AppTypography.bodyLarge),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildRoleChip('customer', 'Customer', Icons.person),
                      SizedBox(width: 12.w),
                      _buildRoleChip('barber', 'Barber', Icons.content_cut),
                    ],
                  ),
                  SizedBox(height: 48.h),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryGold),
                            )
                          : PrimaryButton(
                              text: 'Continue',
                              isFullWidth: true,
                              onPressed: _submit,
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label, IconData icon) {
    final selected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primaryGold.withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AppColors.primaryGold : AppColors.divider,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color:
                      selected ? AppColors.primaryGold : AppColors.textHint,
                  size: 28),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.primaryGold
                      : AppColors.textPrimary,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthCubit>().state;
    final uid = authState is AuthNeedsProfileCompletion
        ? authState.user.uid
        : null;
    if (uid == null) return;

    context.read<AuthCubit>().completeProfile(
          uid: uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        );
  }
}
