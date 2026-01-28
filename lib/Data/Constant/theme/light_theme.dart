import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

ThemeData lightThemes = ThemeData(
  primaryColor: AppColors.whiteColor1,
  // ignore: deprecated_member_use
  focusColor: Colors.grey.withOpacity(0.5),
  hoverColor: Colors.transparent,
  shadowColor: AppColors.greyColor2,
  fontFamily: 'Poppins',
  unselectedWidgetColor: AppColors.blackColor2,
  scaffoldBackgroundColor: AppColors.whiteColor1,
  splashColor: Colors.transparent,
  canvasColor: AppColors.whiteColor1,
  appBarTheme: const AppBarTheme(
    elevation: 0.0,
    backgroundColor: AppColors.whiteColor1,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.blackColor2,
    ),
    foregroundColor: AppColors.blackColor2,
    iconTheme: IconThemeData(
      color: AppColors.blackColor2,
    ),
    surfaceTintColor: AppColors.whiteColor1,
    titleTextStyle: TextStyle(color: AppColors.blackColor2, fontSize: 20.0, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
    shadowColor: AppColors.whiteColor1,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: AppColors.blackColor2,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(color: AppColors.blackColor2, fontSize: 11)),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.blackColor2),
);
