import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const PremiumImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = 40.0;
    if (height != null && height != double.infinity) {
      iconSize = height! * 0.4;
    } else if (width != null && width != double.infinity) {
      iconSize = width! * 0.4;
    }

    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(Icons.storefront, color: AppColors.textHint, size: iconSize),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceLight,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceLight,
          child: Center(
            child: Icon(Icons.storefront, color: AppColors.textHint, size: iconSize),
          ),
        ),
      ),
    );
  }
}
