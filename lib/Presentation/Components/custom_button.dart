import 'package:flutter/material.dart';

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? buttonColor;
  final double? radius;
  const CustomButton2({
    Key? key,
    required this.text,
    required this.onTap,
    this.buttonColor,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: buttonColor ?? AppColors(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          radius ?? 0.0,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.whiteColor1,
          fontSize: AppSize(context).buttonText2,
        ),
      ),
    );
  }
}
