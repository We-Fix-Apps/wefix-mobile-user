import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class LoadingAllProducts extends StatefulWidget {
  const LoadingAllProducts({super.key});

  @override
  State<LoadingAllProducts> createState() => _LoadingAllProductsState();
}

class _LoadingAllProductsState extends State<LoadingAllProducts> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .7,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20),
      itemBuilder: (context, index) {
        return Container(
          width: AppSize(context).width * .45,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            color: AppColors.whiteColor1,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                blurStyle: BlurStyle.outer,
                color: AppColors.greyColor,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                    height: AppSize(context).height * .12,
                    child: LoadingText(width: AppSize(context).width)),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LoadingText(width: AppSize(context).width * 0.4),
                      SizedBox(height: AppSize(context).height * 0.01),
                      LoadingText(width: AppSize(context).width * 0.2),
                      SizedBox(height: AppSize(context).height * 0.01),
                      const Spacer(),
                      Row(
                        children: [
                          LoadingText(width: AppSize(context).width * 0.2),
                          const Spacer(),
                          SvgPicture.asset(
                            "assets/icon/solar_heart-broken.svg",
                            height: AppSize(context).height * .04,
                            color: AppColors.greyColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
