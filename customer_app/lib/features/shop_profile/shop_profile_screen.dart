import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:go_router/go_router.dart';

class ShopProfileScreen extends StatefulWidget {
  final String shopId;
  final ShopModel? shopModel;

  const ShopProfileScreen({
    super.key,
    required this.shopId,
    this.shopModel,
  });

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ShopCubit _shopCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _shopCubit = ShopCubit();
    _shopCubit.loadShopDetails(widget.shopId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shopCubit.close();
    super.dispose();
  }

  void _toggleFavorite(String shopId, bool currentlyFavorite) {
    final authState = context.read<AuthCubit>().state;
    String? uid;
    if (authState is AuthCustomer) uid = authState.user.uid;
    if (authState is AuthAuthenticated) uid = authState.user.uid;
    if (uid == null) return;
    context
        .read<UserCubit>()
        .toggleFavorite(uid, shopId, add: !currentlyFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shopCubit,
      child: BlocBuilder<ShopCubit, ShopState>(
        builder: (context, state) {
          final shop =
              state is ShopDetailLoaded ? state.shop : widget.shopModel;
          final isLoading = state is ShopDetailLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.h,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    if (shop != null)
                      BlocBuilder<UserCubit, UserState>(
                        builder: (context, userState) {
                          final isFav = userState is UserLoaded &&
                              userState.user.favoriteShopIds
                                  .contains(shop.id);
                          return IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFav
                                  ? AppColors.error
                                  : Colors.white,
                            ),
                            onPressed: () =>
                                _toggleFavorite(shop.id, isFav),
                          );
                        },
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: PremiumImage(
                      imageUrl: shop?.coverImageUrl ?? '',
                      borderRadius: 0,
                    ),
                    title: Text(
                      shop?.name ?? '',
                      style: AppTypography.heading3.copyWith(
                        shadows: const [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 2))
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold),
                    ),
                  )
                else if (shop != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppColors.primaryGold,
                                      size: 20),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${shop.rating.toStringAsFixed(1)}',
                                    style: AppTypography.bodyMedium
                                        .copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  if (shop.reviewCount > 0) ...[
                                    SizedBox(width: 4.w),
                                    Text(
                                      '(${shop.reviewCount} reviews)',
                                      style: AppTypography.bodySmall
                                          .copyWith(
                                              color: AppColors.textHint),
                                    ),
                                  ],
                                ],
                              ),
                              Flexible(
                                child: Text(shop.address,
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.primaryGold,
                            labelColor: AppColors.primaryGold,
                            unselectedLabelColor: AppColors.textHint,
                            tabs: const [
                              Tab(text: 'Services'),
                              Tab(text: 'Specialists'),
                              Tab(text: 'Reviews'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildServicesList(shop),
                        _buildBarbersList(shop),
                        _buildReviewsTab(shop),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            bottomNavigationBar: shop == null
                ? null
                : SafeArea(
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                            top: BorderSide(
                                color: AppColors.divider, width: 0.5)),
                      ),
                      child: PrimaryButton(
                        text: 'Book Appointment',
                        onPressed: () {
                          context.push('/booking/${shop.id}', extra: shop);
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList(ShopModel shop) {
    if (shop.services.isEmpty) {
      return Center(
          child: Text('No services listed.',
              style: AppTypography.bodyMedium));
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shop.services.length,
      separatorBuilder: (context, index) =>
          const Divider(color: AppColors.divider),
      itemBuilder: (context, index) {
        final s = shop.services[index];
        return ListTile(
          title: Text(s.name, style: AppTypography.bodyLarge),
          subtitle: Text('${s.durationInMinutes} min',
              style: AppTypography.bodySmall),
          trailing: Text(
            '\$${s.price.toStringAsFixed(0)}',
            style:
                AppTypography.heading3.copyWith(color: AppColors.primaryGold),
          ),
        );
      },
    );
  }

  Widget _buildBarbersList(ShopModel shop) {
    if (shop.barbers.isEmpty) {
      return Center(
          child: Text('No specialists listed.',
              style: AppTypography.bodyMedium));
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shop.barbers.length,
      itemBuilder: (context, index) {
        final b = shop.barbers[index];
        return GestureDetector(
          onTap: () {
            context.push('/barber/${shop.id}/${b.id}', extra: {'shop': shop, 'barber': b});
          },
          child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            children: [
              PremiumImage(
                imageUrl: b.imageUrl,
                width: 60.w,
                height: 60.w,
                borderRadius: 30.r,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.name,
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(b.specialty,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.primaryGold, size: 14),
                    SizedBox(width: 4.w),
                    Text(b.rating.toStringAsFixed(1),
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  // ── Reviews Tab ──────────────────────────────────────────────────

  Widget _buildReviewsTab(ShopModel shop) {
    return StreamBuilder<List<ReviewModel>>(
      stream: ShopRepository().streamReviews(shop.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          children: [
            // Write a review button
            BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                if (userState is! UserLoaded ||
                    userState.user.role != 'customer') {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: PrimaryButton(
                    text: 'Write a Review',
                    isOutline: true,
                    onPressed: () => _showReviewDialog(
                        context, shop, userState.user),
                  ),
                );
              },
            ),
            const Divider(color: AppColors.divider),
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGold))
                  : reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rate_review_outlined,
                                  size: 48.sp,
                                  color: AppColors.textHint),
                              SizedBox(height: 12.h),
                              Text('No reviews yet.',
                                  style: AppTypography.bodyMedium),
                              SizedBox(height: 4.h),
                              Text('Be the first to leave one!',
                                  style: AppTypography.bodySmall
                                      .copyWith(
                                          color: AppColors.textHint)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(20.w),
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: AppColors.divider),
                          itemBuilder: (context, index) =>
                              _buildReviewCard(reviews[index]),
                        ),
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
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(dateStr,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textHint)),
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
      BuildContext context, ShopModel shop, UserModel user) {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20.r))),
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
                  Text('Leave a Review',
                      style: AppTypography.heading3),
                  SizedBox(height: 4.h),
                  Text(shop.name,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textHint)),
                  SizedBox(height: 20.h),
                  // Star selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedRating = i + 1.0),
                        child: Icon(
                          i < selectedRating
                              ? Icons.star
                              : Icons.star_border,
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
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                            color: AppColors.divider, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                            color: AppColors.divider, width: 0.5),
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
                        userName: user.name.isNotEmpty
                            ? user.name
                            : 'Anonymous',
                        userAvatarUrl: user.profilePicUrl,
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                        createdAt: DateTime.now(),
                      );
                      try {
                        await ShopRepository()
                            .addReview(shop.id, review);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Review submitted. Thank you!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to submit review: $e'),
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
