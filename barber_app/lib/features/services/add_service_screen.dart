import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const AddServiceScreen({super.key, this.service});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  int _durationMinutes = 30;
  String _selectedCategory = 'Haircut';

  bool get _isEditing => widget.service != null;

  final List<String> _categories = ['Haircut', 'Beard', 'Facial', 'Massage', 'Color', 'Other'];
  final List<int> _durations = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.service!;
      _nameController.text = s.name;
      _priceController.text = s.price.toStringAsFixed(0);
      _durationMinutes = s.durationInMinutes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? context.tr('edit_service') : context.tr('add_service'), style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Name
            _buildLabel(context.tr('service_name')),
            SizedBox(height: 8.h),
            _buildTextField(_nameController, 'e.g. Classic Fade', Icons.content_cut),
            SizedBox(height: 20.h),

            // Category
            _buildLabel(context.tr('category')),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
                  style: AppTypography.bodyLarge,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Price
            _buildLabel(context.tr('price')),
            SizedBox(height: 8.h),
            _buildTextField(_priceController, '0.00', Icons.attach_money, keyboardType: TextInputType.number),
            SizedBox(height: 20.h),

            // Duration
            _buildLabel(context.tr('duration')),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: _durations.map((d) {
                final isSelected = d == _durationMinutes;
                return GestureDetector(
                  onTap: () => setState(() => _durationMinutes = d),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGold : AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGold : AppColors.divider,
                        width: isSelected ? 2 : 0.5,
                      ),
                    ),
                    child: Text(
                      '$d min',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isSelected ? AppColors.background : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),

            // Description
            _buildLabel(context.tr('description_optional')),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: TextField(
                controller: _descController,
                maxLines: 3,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Brief description of this service...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
            SizedBox(height: 120.h),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(20.w),
        child: PrimaryButton(
          text: _isEditing ? context.tr('save') : context.tr('add_service'),
          onPressed: () async {
            final userState = context.read<UserCubit>().state;
            if (userState is! UserLoaded) return;

            String shopId = userState.user.shopId;
            if (shopId.isEmpty) {
              shopId = await ShopRepository().createShop(
                ownerId: userState.user.id,
                name: '${userState.user.name}\'s Shop',
                address: 'Edit address in profile',
              );
              await AuthRepository().linkBarberToShop(userState.user.id, shopId);
            }

            final service = ServiceModel(
              id: widget.service?.id ?? '',
              name: _nameController.text,
              price: double.tryParse(_priceController.text) ?? 0.0,
              durationInMinutes: _durationMinutes,
              description: _descController.text,
            );

            try {
              if (_isEditing) {
                await ShopRepository().updateService(shopId, service.id, service);
              } else {
                await ShopRepository().addService(shopId, service);
              }

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    title: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                        SizedBox(width: 8.w),
                        Text(_isEditing ? context.tr('service_updated') : context.tr('service_added'), style: AppTypography.heading3),
                      ],
                    ),
                    content: Text(
                      _isEditing ? context.tr('service_updated_msg') : context.tr('service_added_msg'),
                      style: AppTypography.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ctx.pop();
                          context.pop();
                        },
                        child: Text(context.tr('back_to_services'), style: AppTypography.buttonText.copyWith(color: AppColors.primaryGold)),
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
}
