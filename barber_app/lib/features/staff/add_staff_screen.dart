import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_ui/shared_ui.dart';

class AddStaffScreen extends StatefulWidget {
  final BarberModel? barber;

  const AddStaffScreen({super.key, this.barber});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedSpecialty = 'Master Barber';

  bool get _isEditing => widget.barber != null;

  String? _profileImageUrl;
  List<String> _portfolioImages = [];
  bool _isUploadingPortfolio = false;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;
  bool _isUploadingImage = false;

  // Working hours state
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

  final List<String> _specialties = [
    'Master Barber',
    'Beard Specialist',
    'Color Expert',
    'Hair Stylist',
    'Junior Barber',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.barber!;
      _nameController.text = b.name;
      _phoneController.text = b.phone;
      _bioController.text = b.bio;
      _selectedSpecialty = b.specialty;
      _profileImageUrl = b.imageUrl;
      _portfolioImages = List.from(b.portfolioImages);
      if (b.workingHours.isNotEmpty) {
        for (final day in _workingDays.keys) {
          final dayData = b.workingHours[day] as Map<String, dynamic>?;
          if (dayData != null) {
            _workingDays[day] = dayData['isOpen'] as bool? ?? _workingDays[day]!;
          }
        }
        final startStr = (b.workingHours['startTime'] as String?) ?? '9:00';
        final endStr = (b.workingHours['endTime'] as String?) ?? '18:00';
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
      }
    }
  }

  Map<String, dynamic> _buildWorkingHoursMap() {
    final map = <String, dynamic>{
      'startTime': '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
    };
    for (final entry in _workingDays.entries) {
      map[entry.key] = {'isOpen': entry.value};
    }
    return map;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    
    final bytes = await file.readAsBytes();
    final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageExt = ext;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
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
        title: Text(_isEditing ? context.tr('edit_staff') : context.tr('add_staff'), style: AppTypography.heading3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo placeholder
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    if (_pickedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.r),
                        child: Image.memory(
                          _pickedImageBytes!,
                          width: 100.r,
                          height: 100.r,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      PremiumImage(
                        imageUrl: _profileImageUrl!,
                        width: 100.r,
                        height: 100.r,
                        borderRadius: 50.r,
                      )
                    else
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.surface,
                        child: const Icon(Icons.person, size: 50, color: AppColors.textHint),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
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
            SizedBox(height: 32.h),

            // Full Name
            _buildLabel(context.tr('full_name')),
            SizedBox(height: 8.h),
            _buildTextField(_nameController, 'Enter full name', Icons.person_outline),
            SizedBox(height: 20.h),

            // Phone Number
            _buildLabel(context.tr('phone')),
            SizedBox(height: 8.h),
            _buildTextField(_phoneController, '+1 234 567 8900', Icons.phone_outlined, keyboardType: TextInputType.phone),
            SizedBox(height: 20.h),

            // Specialty
            _buildLabel(context.tr('specialty')),
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
                  value: _selectedSpecialty,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
                  style: AppTypography.bodyLarge,
                  items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => _selectedSpecialty = val!),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Bio
            _buildLabel(context.tr('bio')),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: 3,
                style: AppTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Brief description of experience...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Working Hours Section
            Text(context.tr('working_hours'), style: AppTypography.heading3),
            SizedBox(height: 16.h),

            // Time Range
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTimePicker('Start', _startTime, (t) => setState(() => _startTime = t))),
                  Container(width: 1, height: 40.h, color: AppColors.divider),
                  Expanded(child: _buildTimePicker('End', _endTime, (t) => setState(() => _endTime = t))),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Working Days
            Text(context.tr('working_days'), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            ..._workingDays.entries.map((entry) => _buildDayToggle(entry.key, entry.value)),

            SizedBox(height: 32.h),

            // Profile Gallery / Portfolio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Portfolio / Gallery', style: AppTypography.heading3),
                if (_isUploadingPortfolio)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2),
                  )
              ],
            ),
            SizedBox(height: 16.h),
            _buildPortfolioGallery(),

            SizedBox(height: 120.h),
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(20.w),
        child: PrimaryButton(
          text: _isUploadingImage ? context.tr('loading') : (_isEditing ? context.tr('save') : context.tr('add_staff')),
          onPressed: _isUploadingImage ? null : () async {
            setState(() => _isUploadingImage = true);
            try {
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

              String finalImageUrl = _profileImageUrl ?? widget.barber?.imageUrl ?? '';
              if (_pickedImageBytes != null && _pickedImageExt != null) {
                final repo = StorageRepository();
                finalImageUrl = await repo.uploadStaffPhoto(shopId, _pickedImageBytes!, _pickedImageExt!);
              }

              final barber = BarberModel(
                id: widget.barber?.id ?? '',
                name: _nameController.text,
                imageUrl: finalImageUrl,
                specialty: _selectedSpecialty,
                rating: widget.barber?.rating ?? 0.0,
                bio: _bioController.text,
                phone: _phoneController.text,
                workingHours: _buildWorkingHoursMap(),
                portfolioImages: _portfolioImages,
              );

              if (_isEditing) {
                await ShopRepository().updateBarber(shopId, barber.id, barber);
              } else {
                await ShopRepository().addBarber(shopId, barber);
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
                        Text(_isEditing ? context.tr('staff_updated') : context.tr('staff_added'), style: AppTypography.heading3),
                      ],
                    ),
                    content: Text(
                      _isEditing ? context.tr('staff_updated_msg') : context.tr('staff_added_msg'),
                      style: AppTypography.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          ctx.pop();
                          context.pop();
                        },
                        child: Text(context.tr('back_to_team'), style: AppTypography.buttonText.copyWith(color: AppColors.primaryGold)),
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
            } finally {
              if (mounted) setState(() => _isUploadingImage = false);
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

  Widget _buildTimePicker(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
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
            style: AppTypography.heading3.copyWith(color: AppColors.primaryGold),
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
            onChanged: (val) => setState(() => _workingDays[day] = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioGallery() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _portfolioImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _portfolioImages.length) {
            return GestureDetector(
              onTap: _pickAndUploadPortfolioImage,
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
                    Text('Add Photo', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold)),
                  ],
                ),
              ),
            );
          }

          final url = _portfolioImages[index];
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
                  onTap: () async {
                    setState(() => _portfolioImages.removeAt(index));
                    try {
                      await StorageRepository().deletePortfolioPhoto(url);
                    } catch (_) {}
                  },
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
  }

  Future<void> _pickAndUploadPortfolioImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploadingPortfolio = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
      
      final barberId = widget.barber?.id.isNotEmpty == true ? widget.barber!.id : DateTime.now().millisecondsSinceEpoch.toString();
      final url = await StorageRepository().uploadPortfolioPhoto(barberId, bytes, ext);
      
      setState(() {
        _portfolioImages.add(url);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload portfolio image: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPortfolio = false);
    }
  }
}
