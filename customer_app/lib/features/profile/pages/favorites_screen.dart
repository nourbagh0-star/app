import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_ui/shared_ui.dart';
import '../../home/widgets/shop_card_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favorites', style: AppTypography.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryGold),
            );
          }
          if (userState is! UserLoaded) {
            return Center(
              child: Text('Sign in to see your favorites.',
                  style: AppTypography.bodyMedium),
            );
          }
          final ids = userState.user.favoriteShopIds;
          if (ids.isEmpty) {
            return _buildEmptyState();
          }
          return _FavoriteShopList(
            favoriteIds: ids,
            currentUser: userState.user,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 60.sp, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(
            'No favorites yet',
            style: AppTypography.heading3
                .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the heart on any shop to save it here',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _FavoriteShopList extends StatefulWidget {
  final List<String> favoriteIds;
  final UserModel currentUser;

  const _FavoriteShopList({
    required this.favoriteIds,
    required this.currentUser,
  });

  @override
  State<_FavoriteShopList> createState() => _FavoriteShopListState();
}

class _FavoriteShopListState extends State<_FavoriteShopList> {
  List<ShopModel>? _shops;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  @override
  void didUpdateWidget(_FavoriteShopList old) {
    super.didUpdateWidget(old);
    if (old.favoriteIds != widget.favoriteIds) _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final shops =
          await ShopRepository().fetchShopsByIds(widget.favoriteIds);
      if (mounted) setState(() => _shops = shops);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold));
    }
    if (_error != null) {
      return Center(
          child: Text('Error: $_error', style: AppTypography.bodyMedium));
    }
    final shops = _shops ?? [];
    if (shops.isEmpty) {
      return Center(
          child: Text('No shops found.', style: AppTypography.bodyMedium));
    }
    return RefreshIndicator(
      color: AppColors.primaryGold,
      backgroundColor: AppColors.surface,
      onRefresh: _loadShops,
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ShopCardItem(
              shop: shop,
              isFavorite: true,
              onFavoriteToggle: () {
                final authState = context.read<AuthCubit>().state;
                String? uid;
                if (authState is AuthCustomer) uid = authState.user.uid;
                if (authState is AuthAuthenticated)
                  uid = authState.user.uid;
                if (uid != null) {
                  context.read<UserCubit>().toggleFavorite(
                        uid,
                        shop.id,
                        add: false,
                      );
                }
              },
              onTap: () => context.push('/shop/${shop.id}', extra: shop),
            ),
          );
        },
      ),
    );
  }
}
