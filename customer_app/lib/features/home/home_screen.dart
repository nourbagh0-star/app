import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import 'widgets/category_list.dart';
import 'widgets/shop_card_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ShopCubit _shopCubit;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _shopCubit = ShopCubit()..loadShops();

    final authState = context.read<AuthCubit>().state;
    String? uid;
    if (authState is AuthCustomer) uid = authState.user.uid;
    if (authState is AuthBarber) uid = authState.user.uid;
    if (authState is AuthAuthenticated) uid = authState.user.uid;
    if (uid != null) context.read<UserCubit>().streamUser(uid);
  }

  @override
  void dispose() {
    _shopCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  List<ShopModel> _filterShops(List<ShopModel> shops) {
    var result = shops;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedCategory != null) {
      result = result
          .where((s) =>
              s.categories.isEmpty ||
              s.categories.any((c) =>
                  c.toLowerCase() == _selectedCategory!.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shopCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          String? uid;
          if (authState is AuthCustomer) uid = authState.user.uid;
          if (authState is AuthBarber) uid = authState.user.uid;
          if (authState is AuthAuthenticated) uid = authState.user.uid;
          if (uid != null) context.read<UserCubit>().streamUser(uid);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryGold,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                _shopCubit.loadShops();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('good_morning'),
                              style: AppTypography.bodyMedium),
                          SizedBox(height: 4.h),
                          BlocBuilder<UserCubit, UserState>(
                            builder: (context, userState) {
                              final name = userState is UserLoaded
                                  ? userState.name
                                  : '';
                              return Text(
                                name.isNotEmpty ? name : '...',
                                style: AppTypography.heading1,
                              );
                            },
                          ),
                          SizedBox(height: 24.h),
                          _buildSearchBar(),
                          SizedBox(height: 24.h),
                          Text(context.tr('categories'),
                              style: AppTypography.heading3),
                          SizedBox(height: 16.h),
                          CategoryList(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (cat) =>
                                setState(() => _selectedCategory = cat),
                          ),
                          SizedBox(height: 32.h),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory ?? context.tr('nearby_top_rated'),
                                style: AppTypography.heading3,
                              ),
                              if (_selectedCategory != null ||
                                  _searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedCategory = null;
                                    _searchQuery = '';
                                    _searchController.clear();
                                  }),
                                  child: Text(
                                    context.tr('clear'),
                                    style: AppTypography.bodyMedium
                                        .copyWith(
                                            color: AppColors.primaryGold),
                                  ),
                                )
                              else
                                Text(
                                  context.tr('see_all'),
                                  style: AppTypography.bodyMedium
                                      .copyWith(
                                          color: AppColors.primaryGold),
                                ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Shop List ──
                  BlocBuilder<ShopCubit, ShopState>(
                    builder: (context, state) {
                      if (state is ShopsLoading) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryGold),
                            ),
                          ),
                        );
                      }
                      if (state is ShopError) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                  'Error loading shops: ${state.message}',
                                  style: AppTypography.bodyMedium),
                            ),
                          ),
                        );
                      }
                      if (state is ShopsLoaded) {
                        final filtered = _filterShops(state.shops);
                        if (filtered.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 48.sp,
                                        color: AppColors.textHint),
                                    SizedBox(height: 12.h),
                                    Text(context.tr('no_shops_found'),
                                        style: AppTypography.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverPadding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final shop = filtered[index];
                                return Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 16.h),
                                  child: BlocBuilder<UserCubit,
                                      UserState>(
                                    builder: (context, userState) {
                                      final isFav = userState
                                              is UserLoaded &&
                                          userState.user.favoriteShopIds
                                              .contains(shop.id);
                                      return ShopCardItem(
                                        shop: shop,
                                        isFavorite: isFav,
                                        onFavoriteToggle: () {
                                          final authState = context
                                              .read<AuthCubit>()
                                              .state;
                                          String? uid;
                                          if (authState is AuthCustomer)
                                            uid = authState.user.uid;
                                          if (authState
                                              is AuthAuthenticated)
                                            uid = authState.user.uid;
                                          if (uid != null) {
                                            context
                                                .read<UserCubit>()
                                                .toggleFavorite(
                                                    uid, shop.id,
                                                    add: !isFav);
                                          }
                                        },
                                        onTap: () => context.push(
                                          '/shop/${shop.id}',
                                          extra: shop,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(
                          child: SizedBox.shrink());
                    },
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textHint),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.trim()),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(Icons.close,
                  color: AppColors.textHint, size: 18),
            )
          else
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: const Icon(Icons.tune,
                  color: AppColors.primaryGold, size: 20),
            ),
        ],
      ),
    );
  }
}
