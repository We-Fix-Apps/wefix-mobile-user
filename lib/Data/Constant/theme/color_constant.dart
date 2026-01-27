import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Functions/color.dart';

/// App Colors Class - Resource class for storing app level color constants
class AppColors {
  BuildContext context;
  AppColors(this.context);

  AppProvider get appProvider =>
      Provider.of<AppProvider>(context, listen: true);

  Color get primaryColor => HexColor.fromHex("E97C22");

  static const Color backgroundColor = Color(0xFFf4f4f4);
  static const Color secoundryColor = Color(0xFF778890);

  // static const Color primaryColor = Color(0xFFED7F26);
  // static const Color primaryColor = Color(0xFFE04471);
  static const Color greenColor = Color(0xFF33AB07);
  static const Color greenColorBack = Color(0xFFc8e6c8);

  static const Color blueColor = Color(0xFF3199C9);

  //todo:black color
  static const Color blackColor1 = Color(0xFF000000);
  static const Color blackColor2 = Color(0xFF30292F);
  static const Color blackColor3 = Color(0xFF191919);
  static const Color darkBackgroundColor = Color(0xFF2C2C2C);

  static const Color redColor = Color(0xFFC10707);
  static const Color yellowColor = Colors.yellowAccent;

  //todo:grey color
  static const Color greyColor1 = Color(0xFFC9C9C9);
  static const Color greyColor = Color(0xFFE4E4E4);
  static const Color greyColorback = Color(0xFFEDEDED);
  static const Color greyColorFont = Color(0xFFBEBEBE);
  static const Color greyColorButton = Color(0xFFD9D9D9);

  static const Color greyColor2 = Color(0xff707070);
  static const Color greyColor3 = Color(0xff949494);
  static const Color greyColor4 = Color(0xff929096);
  static const Color greyColor5 = Color(0xFF8C8C8C);
  static const Color lightGreyColor = Color(0xFFCCCCCC);
  static const Color lighterGreyColor = Color(0xFFececee);

  static const Color darkGreyColor = Color(0xFF6D6D6D);

  static const Color pink = Color(0xFFfe375e);
  static const Color green = Color(0xFF129271);

  //todo:white Color
  static const Color whiteColor1 = Color(0xFFFFFFFF);
  static const Color whiteColor2 = Color(0xFFFEFEFE);
  static const Color whiteColor3 = Color(0xFFF8F0FB);
  static const Color whiteColor4 = Color(0xFFDCF0E8);
}
