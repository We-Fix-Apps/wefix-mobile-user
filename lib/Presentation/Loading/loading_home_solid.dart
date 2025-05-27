import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class LoadingHomeSolid extends StatefulWidget {
  const LoadingHomeSolid({super.key});

  @override
  State<LoadingHomeSolid> createState() => _LoadingHomeSolidState();
}

class _LoadingHomeSolidState extends State<LoadingHomeSolid> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize(context).height * 0.3,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: 5,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
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
                                LoadingText(
                                    width: AppSize(context).width * 0.2),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
