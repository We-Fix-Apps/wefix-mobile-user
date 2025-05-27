import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class CustomBotton extends StatelessWidget {
  final String title;
  final String? price;
  final double? textSize;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? width;
  final Function()? onTap;
  final bool? border;
  final double? radius;
  final bool? isAddToCart;
  final bool? loading;
  final Color ?borderColor;
  const CustomBotton({
    super.key,
    required this.title,
    this.onTap,
    this.textSize,
    this.radius,
    this.isAddToCart,
    this.height,
    this.child,
    this.color,
    this.width,
    this.textColor,
    this.loading = false,
    this.border = false,
    this.price,
     this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InkWell(
        borderRadius: BorderRadius.circular(radius ?? 10),
        onTap: onTap,
        child: Container(
          height: height ?? AppSize(context).height * 0.057,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
              color: color ?? AppColors(context).primaryColor,
              borderRadius: BorderRadius.circular(radius ?? 10),
              border: border == false
                  ? null
                  : Border.all(
                      color: borderColor ?? AppColors(context).primaryColor,
                    )),
          child: isAddToCart ?? false
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.whiteColor1,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        price.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.whiteColor1,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: loading == true
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: AppColors.whiteColor1,
                          ),
                        )
                      : child ??
                          Center(
                            child: loading == true
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: AppColors.whiteColor1,
                                    ),
                                  )
                                : Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: textSize ??
                                          AppSize(context).smallText2,
                                      fontWeight: FontWeight.bold,
                                      color: textColor ?? AppColors.whiteColor1,
                                    ),
                                  ),
                          ),
                ),
        ),
      ),
    );
  }
}
