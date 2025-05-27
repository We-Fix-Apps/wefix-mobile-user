import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';

class WidgetDialog extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final String desc;
  final String? bottonText;

  final bool isError;
  final bool? isDesc;

  const WidgetDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.isError,
    this.onTap,
    this.isDesc = false,
    this.bottonText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: AppSize(context).width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteColor1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppSize(context).width * 0.3,
                  height: AppSize(context).width * 0.3,
                  child: isError == false
                      ? SvgPicture.asset("assets/icon/success.svg")
                      : SvgPicture.asset("assets/icon/error.svg"),
                ),
                SizedBox(height: AppSize(context).height * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: "Poppins",
                    fontSize: AppSize(context).mediumText3,
                    color: AppColors.blackColor1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSize(context).height * 0.02),
                isDesc == true
                    ? SizedBox(
                        height: AppSize(context).height * 0.45,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                desc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontFamily: "Poppins",
                                  fontSize: AppSize(context).smallText2,
                                  color: AppColors.greyColor3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: "Poppins",
                          fontSize: AppSize(context).smallText2,
                          color: AppColors.greyColor3,
                        ),
                      ),
                SizedBox(height: AppSize(context).height * 0.02),
                GestureDetector(
                  onTap: onTap ??
                      () {
                        pop(context);
                      },
                  child: Container(
                    width: AppSize(context).width * 0.3,
                    height: AppSize(context).height * 0.05,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors(context).primaryColor,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Text(
                      bottonText ?? AppText(context).back,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: "Poppins",
                        fontSize: AppSize(context).smallText2,
                        color: AppColors.whiteColor1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
