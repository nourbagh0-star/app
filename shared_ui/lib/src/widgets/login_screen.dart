import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../backend/auth_service.dart';
import '../backend/database_service.dart';

class LoginScreen extends StatefulWidget {
  final String appTitle;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const LoginScreen({
    super.key,
    required this.appTitle,
    required this.onLogin,
    required this.onSignUp,
    required this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _authService.signInWithEmailAndPassword(email, password);
      
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await _authService.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email before logging in. A new link has been sent.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      if (!mounted) return;
      widget.onLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),

              // ── Logo / Branding ──
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.content_cut,
                    size: 36.sp, color: AppColors.background),
              ),
              SizedBox(height: 24.h),
              Text(widget.appTitle, style: AppTypography.heading1),
              SizedBox(height: 8.h),
              Text('Welcome back',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textHint)),
              SizedBox(height: 48.h),

              // ── Email Field ──
              _buildTextField(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),

              // ── Password Field ──
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: 12.h),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.primaryGold),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // ── Login Button ──
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                  : PrimaryButton(
                      text: 'Log In',
                      onPressed: _handleLogin,
                    ),
              // ── Seed Database (Temp) ──
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seeding database...')),
                    );
                    try {
                      await DatabaseService().seedDummyData();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Database seeded successfully! 🔥')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Seed failed: $e')),
                      );
                    }
                  },
                  child: Text('Seed Database (Dev Only)', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold)),
                ),
                SizedBox(height: 16.h),
              ],

              // ── Divider ──
              Row(
                children: [
                  Expanded(
                      child:
                          Divider(color: AppColors.divider, thickness: 0.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('or continue with',
                        style: AppTypography.bodySmall),
                  ),
                  Expanded(
                      child:
                          Divider(color: AppColors.divider, thickness: 0.5)),
                ],
              ),
              SizedBox(height: 24.h),

              // ── Social Buttons ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.g_mobiledata, 'Google'),
                  SizedBox(width: 16.w),
                  _buildSocialButton(Icons.apple, 'Apple'),
                ],
              ),
              SizedBox(height: 40.h),

              // ── Sign Up Link ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: AppTypography.bodyMedium),
                  GestureDetector(
                    onTap: widget.onSignUp,
                    child: Text(
                      'Sign Up',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            SizedBox(width: 8.w),
            Text(label, style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}
