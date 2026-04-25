import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ShopCubit _shopCubit;

  @override
  void initState() {
    super.initState();
    _shopCubit = ShopCubit();
    // Load services for this barber's shop
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
        title: Text(context.tr('services_title'), style: AppTypography.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryGold),
            onPressed: () => context.push('/services/add'),
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
                child: Text(context.tr('add_service_prompt'),
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
                final services = state.shop.services;
                if (services.isEmpty) {
                  return Center(
                    child: Text(context.tr('no_services'),
                        style: AppTypography.bodyMedium),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () =>
                          context.push('/services/edit/${service.id}', extra: service),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.name,
                                    style: AppTypography.bodyLarge),
                                SizedBox(height: 4.h),
                                Text('${service.durationInMinutes} min',
                                    style: AppTypography.bodySmall),
                              ],
                            ),
                            Row(
                              children: [
                                Text('\$${service.price.toStringAsFixed(0)}',
                                    style: AppTypography.heading3
                                        .copyWith(color: AppColors.primaryGold)),
                                SizedBox(width: 16.w),
                                const Icon(Icons.edit,
                                    color: AppColors.textHint, size: 20),
                              ],
                            ),
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
