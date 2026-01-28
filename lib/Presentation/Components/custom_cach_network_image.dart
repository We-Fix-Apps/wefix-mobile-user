import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class WidgetCachNetworkImage extends StatelessWidget {
  final String image;
  final BoxFit boxFit;
  final double? height;
  final double? width;
  final double radius;

  const WidgetCachNetworkImage({
    super.key,
    required this.image,
    this.boxFit = BoxFit.cover,
    this.height,
    this.width,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: Uri.encodeFull(image),
        height: height,
        width: width,
        fit: boxFit,

        // 🔑 مهم جدًا للـ Grid
        memCacheHeight: height?.toInt(),
        memCacheWidth: width?.toInt(),

        placeholder: (_, __) => Container(
          color: AppColors.lightGreyColor,
          alignment: Alignment.center,
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                AppColors(context).primaryColor,
              ),
            ),
          ),
        ),

        errorWidget: (_, __, ___) => Container(
          color: AppColors.lightGreyColor,
        ),
      ),
    );
  }
}
