import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class BarberProfileScreen extends StatelessWidget {
  final ShopModel shop;
  final BarberModel barber;

  const BarberProfileScreen({
    super.key,
    required this.shop,
    required this.barber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(barber.name, style: AppTypography.heading3),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barber Info Header
            Center(
              child: Column(
                children: [
                  if (barber.imageUrl.isNotEmpty)
                    PremiumImage(
                      imageUrl: barber.imageUrl,
                      width: 120.w,
                      height: 120.w,
                      borderRadius: 60.r,
                    )
                  else
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, size: 60.sp, color: AppColors.textHint),
                    ),
                  SizedBox(height: 16.h),
                  Text(barber.name, style: AppTypography.heading2),
                  SizedBox(height: 4.h),
                  Text(
                    barber.specialty.isNotEmpty ? barber.specialty : 'Specialist',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.primaryGold),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: AppColors.primaryGold, size: 20.sp),
                      SizedBox(width: 4.w),
                      Text(
                        barber.rating.toStringAsFixed(1),
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Bio Section
            if (barber.bio.isNotEmpty) ...[
              Text('About', style: AppTypography.heading3),
              SizedBox(height: 12.h),
              Text(
                barber.bio,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
              SizedBox(height: 32.h),
            ],

            // Portfolio Section
            if (barber.portfolioImages.isNotEmpty) ...[
              Text('Portfolio Gallery', style: AppTypography.heading3),
              SizedBox(height: 12.h),
              _buildPortfolioGallery(),
              SizedBox(height: 32.h),
            ],

            // Schedule Section
            Text('Schedule', style: AppTypography.heading3),
            SizedBox(height: 12.h),
            _buildScheduleBox(),
            SizedBox(height: 32.h),
            
            // Reviews Section
            Text('Reviews', style: AppTypography.heading3),
            SizedBox(height: 12.h),
            _buildReviewsSection(context),
            SizedBox(height: 120.h), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(20.w),
        child: PrimaryButton(
          text: 'Book Appointment',
          onPressed: () {
            // Navigate to Booking Screen and pass shop (could also support preselecting barber later)
            context.push('/booking/${shop.id}', extra: shop);
          },
        ),
      ),
    );
  }

  Widget _buildScheduleBox() {
    final Map<String, dynamic> hours = barber.workingHours;
    if (hours.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Center(
          child: Text('Schedule not set.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
        ),
      );
    }

    final String startTime = hours['startTime'] ?? '09:00';
    final String endTime = hours['endTime'] ?? '18:00';

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: days.map((day) {
          final dayData = hours[day] as Map<String, dynamic>?;
          final isOpen = dayData?['isOpen'] as bool? ?? false;
          final timeStr = isOpen ? '$startTime - $endTime' : 'Closed';

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day, style: AppTypography.bodyLarge),
                Text(
                  timeStr,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isOpen ? Colors.white : AppColors.error,
                    fontWeight: isOpen ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolioGallery() {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: barber.portfolioImages.length,
        itemBuilder: (context, index) {
          final url = barber.portfolioImages[index];
          return Container(
            margin: EdgeInsets.only(right: 16.w),
            child: PremiumImage(
              imageUrl: url,
              width: 140.w,
              height: 180.h,
              borderRadius: 16.r,
            ),
          );
        },
      ),
    );
  }

  // ── Reviews Section ─────────────────────────────────────────────
  
  Widget _buildReviewsSection(BuildContext context) {
    return StreamBuilder<List<ReviewModel>>(
      stream: ShopRepository().streamBarberReviews(shop.id, barber.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          children: [
            // Write a review button
            BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                if (userState is! UserLoaded || userState.user.role != 'customer') {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: PrimaryButton(
                    text: 'Write a Review',
                    isOutline: true,
                    onPressed: () => _showReviewDialog(context, shop, barber, userState.user),
                  ),
                );
              },
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            else if (reviews.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    Icon(Icons.rate_review_outlined, size: 48.sp, color: AppColors.textHint),
                    SizedBox(height: 12.h),
                    Text('No reviews yet.', style: AppTypography.bodyMedium),
                    SizedBox(height: 4.h),
                    Text('Be the first to leave one!',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textHint)),
                  ],
                ),
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
                itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final day = review.createdAt.day.toString().padLeft(2, '0');
    final month = review.createdAt.month.toString().padLeft(2, '0');
    final dateStr = '$day/$month/${review.createdAt.year}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumImage(
                imageUrl: review.userAvatarUrl,
                width: 36.w,
                height: 36.w,
                borderRadius: 18.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(dateStr,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
              _buildStars(review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(review.comment, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star : Icons.star_border,
          color: AppColors.primaryGold,
          size: 14.sp,
        );
      }),
    );
  }

  void _showReviewDialog(
      BuildContext context, ShopModel shop, BarberModel barber, UserModel user) {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text('Leave a Review', style: AppTypography.heading3),
                  SizedBox(height: 4.h),
                  Text(barber.name, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedRating = i + 1.0),
                        child: Icon(
                          i < selectedRating ? Icons.star : Icons.star_border,
                          color: AppColors.primaryGold,
                          size: 36.sp,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  PrimaryButton(
                    text: 'Submit Review',
                    isFullWidth: true,
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final review = ReviewModel(
                        id: '',
                        userId: user.id,
                        userName: user.name.isNotEmpty ? user.name : 'Anonymous',
                        userAvatarUrl: user.profilePicUrl,
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                        createdAt: DateTime.now(),
                      );
                      try {
                        await ShopRepository().addBarberReview(shop.id, barber.id, review);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted. Thank you!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to submit review: $e'),
                              backgroundColor: AppColors.error,
                            ),
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
  }
}
