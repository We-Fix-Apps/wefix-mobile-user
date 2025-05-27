import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class CustomAppBar {
  // Todo :- Text style for title appbar
  static TextStyle textStyle({
    required BuildContext context,
  }) {
    return TextStyle(
      color: AppColors.blackColor1,
      fontSize: AppSize(context).largText2,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    );
  }

  // Todo :- AppBar with actions
  static AppBar appBar({
    required BuildContext context,
     Widget? title,
     Color ?color,
    Widget? leading,
    List<Widget>? actions,
    double? elevation,
  }) {
    return AppBar(
      title: title,
      centerTitle: true,
      elevation: elevation ?? 0.0,
      actions: actions,
      leading: leading,
      backgroundColor: color ?? AppColors.whiteColor1,
    );
  }

  // Todo :- AppBar with leading and actions
  static AppBar appBarWithlanding({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? landing,
    double? elevation,
  }) {
    return AppBar(
      title: Text(
        title,
        style: textStyle(context: context),
      ),
      elevation: elevation ?? 0.0,
      centerTitle: true,
      actions: actions,
      leading: landing,
    );
  }

  // Todo : AppBar with Tab View Tow Page
  static AppBar appBarWithTabViewTowPage({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? landing,
    Color? indicatorColor,
  }) {
    return AppBar(
      title: Text(
        title,
        style: textStyle(context: context),
      ),
      centerTitle: true,
      actions: actions,
      leading: landing,
      bottom: TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: indicatorColor,
        tabs: const [
          Tab(
            text: 'One',
          ),
          Tab(
            text: 'Tow',
          ),
        ],
      ),
    );
  }

  // Todo : AppBar with Tab View Three Page
  static AppBar appBarWithTabViewThreePage({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? landing,
    Color? indicatorColor,
  }) {
    return AppBar(
      title: Text(
        title,
        style: textStyle(context: context),
      ),
      centerTitle: true,
      actions: actions,
      leading: landing,
      bottom: TabBar(
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: indicatorColor,
        tabs: const [
          Tab(
            text: 'One',
          ),
          Tab(
            text: 'Tow',
          ),
          Tab(
            text: 'Three',
          ),
        ],
      ),
    );
  }
}
