import 'dart:developer';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/cart_model.dart';
import 'package:wefix/Presentation/Home/Screens/home_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/contact_us_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/bookings_screen.dart';
import 'package:wefix/Presentation/Profile/profile_screen.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Subscriptions/Screens/Subscriptions_screen.dart';

class HomeLayout extends StatefulWidget {
  final int? index;
  const HomeLayout({Key? key, this.index}) : super(key: key);
  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

CartModel? cartModel;

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;
  TabController? tabController;

  @override
  void initState() {
    handelCurrentIndex(widget.index);

    super.initState();
  }

  List<Widget> screen = [
    const HomeScreen(),
    BookingScreen(),
    const SubscriptionScreen(),
    const ProfileScreen(),
    const ContactUsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    List<TabItem> items = [
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/home.svg",
            color: AppColors(context).primaryColor,
            height: 20,
          ),
          icon: SvgPicture.asset(
            "assets/icon/home.svg",
            color: AppColors.greyColor2,
            height: 20,
          ),
          title: AppText(context).home),
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/booking.svg",
            color: AppColors(context).primaryColor,
            height: 20,
          ),
          icon: SvgPicture.asset(
            "assets/icon/booking.svg",
            color: AppColors.greyColor2,
            height: 20,
          ),
          title: AppText(context).bookings),
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/smile.svg",
            color: AppColors.whiteColor1,
            height: 20,
          ),
          icon: SvgPicture.asset(
            "assets/icon/smile.svg",
            color: AppColors.whiteColor1,
            height: 20,
          ),
          title: AppText(context).subscription),
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/user.svg",
            color: AppColors(context).primaryColor,
            height: 20,
          ),
          icon: SvgPicture.asset(
            "assets/icon/user.svg",
            color: AppColors.greyColor2,
            height: 20,
          ),
          title: AppText(context).profile),
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/supportheadphones.svg",
            color: AppColors(context).primaryColor,
            height: 20,
          ),
          icon: SvgPicture.asset(
            "assets/icon/supportheadphones.svg",
            color: AppColors.greyColor2,
            height: 20,
          ),
          title: AppText(context).contactUs),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (currentIndex > 0) {
          navigateToReplacement(
              context,
              const HomeLayout(
                index: 0,
              ));
        }
        return true;
      },
      child: Scaffold(
        body: screen[currentIndex],
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Colors.white,
          activeColor: AppColors(context).primaryColor,
          style: TabStyle.fixedCircle,
          color: Colors.grey,
          elevation: 1,
          height: 60,
          curve: Curves.linearToEaseOut,
          cornerRadius: 20,
          
          controller: tabController,
          initialActiveIndex: widget.index ?? 0,
          items: items,
          onTap: (int i) => changeBottomIndex(i),
        ),
      ),
    );
  }

  void changeBottomIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void handelCurrentIndex(int? index) {
    if (index != null) {
      currentIndex = index;
    }
  }
}
