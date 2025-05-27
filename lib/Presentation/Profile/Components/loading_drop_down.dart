import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class DropDownLoading extends StatelessWidget {
  const DropDownLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSize(context).height * 0.055,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.greyColor3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingText(
            width: AppSize(context).width * 0.3,
            height: 10,
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: AppColors.whiteColor1),
        ],
      ),
    );
  }
}
