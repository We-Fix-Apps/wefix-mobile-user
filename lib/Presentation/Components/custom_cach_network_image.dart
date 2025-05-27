import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class WidgetCachNetworkImage extends StatelessWidget {
  final String image;
  final BoxFit? boxFit;
  final double? height;
  final double? redios;
  final double? width;
  const WidgetCachNetworkImage({
    Key? key,
    required this.image,
    this.boxFit,
    this.height,
    this.width,
    this.redios,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: image.replaceAll(' ', ''),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: boxFit ?? BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(redios ?? 0),
        ),
      ),
      placeholder: (context, url) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                          AppColors(context).primaryColor))),
            ),
          ],
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.lightGreyColor,
      ),
    );
  }
}
