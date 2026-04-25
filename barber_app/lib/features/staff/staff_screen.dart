import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late final ShopCubit _shopCubit;

  @override
  void initState() {
    super.initState();
    _shopCubit = ShopCubit();
    // Load staff for this barber's shop
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded && userState.shopId.isNotEmpty) {
      _shopCubit.loadShopDetails(userState.shopId);
    }
  }

  @override
  void dispose() {
    _shopCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('staff_title'), style: AppTypography.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.primaryGold),
            onPressed: () => context.push('/staff/add'),
          )
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, userState) {
          if (userState is UserLoaded && userState.shopId.isNotEmpty && _shopCubit.state is ShopInitial) {
            _shopCubit.loadShopDetails(userState.shopId);
          }
        },
        builder: (context, userState) {
          if (userState is UserLoaded && userState.shopId.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(context.tr('add_staff_prompt'),
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center),
              ),
            );
          }

          return BlocBuilder<ShopCubit, ShopState>(
            bloc: _shopCubit,
            builder: (context, state) {
              if (state is ShopDetailLoading || state is ShopInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                );
              }
              if (state is ShopError) {
                return Center(
                  child: Text('Error: ${state.message}',
                      style: AppTypography.bodyMedium),
                );
              }

              if (state is ShopDetailLoaded) {
                final barbers = state.shop.barbers;
                if (barbers.isEmpty) {
                  return Center(
                    child: Text(context.tr('no_staff'),
                        style: AppTypography.bodyMedium),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: barbers.length,
                  itemBuilder: (context, index) {
                    final barber = barbers[index];
                    return GestureDetector(
                      onTap: () =>
                          context.push('/staff/edit/${barber.id}', extra: barber),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            PremiumImage(
                              imageUrl: barber.imageUrl.isNotEmpty
                                  ? barber.imageUrl
                                  : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                              width: 60.w,
                              height: 60.w,
                              borderRadius: 30.r,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(barber.name,
                                      style: AppTypography.bodyLarge
                                          .copyWith(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4.h),
                                  Text(barber.specialty,
                                      style: AppTypography.bodySmall),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: AppColors.primaryGold),
                                      SizedBox(width: 4.w),
                                      Text(barber.rating.toStringAsFixed(1),
                                          style: AppTypography.bodySmall),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textHint),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
