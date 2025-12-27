import 'dart:ui';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/B2B/ticket/create_update_ticket_screen_v2.dart';
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

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;
  TabController? tabController;
  late TutorialCoachMark tutorialCoachMark;

  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();

  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();
  GlobalKey keyButton5 = GlobalKey();
  
  // GlobalKey to access HomeScreen state
  final GlobalKey<State<HomeScreen>> _homeScreenKey = GlobalKey<State<HomeScreen>>();

  @override
  void initState() {
    handelCurrentIndex(widget.index);
    createTutorial();
    Future.delayed(const Duration(seconds: 3), showTutorial);

    super.initState();
  }

  List<Widget> get screen => [
    HomeScreen(key: _homeScreenKey),
    BookingScreen(),
    const SubscriptionScreen(),
    const ProfileScreen(),
    const ContactUsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Check if user is a B2B account (Admin 18, Team Leader 20, or Super User 26)
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUserRoleId = appProvider.userModel?.customer.roleId;
    
    int? roleIdInt;
    if (currentUserRoleId is int) {
      roleIdInt = currentUserRoleId;
    } else if (currentUserRoleId is String) {
      roleIdInt = int.tryParse(currentUserRoleId);
    } else if (currentUserRoleId != null) {
      roleIdInt = int.tryParse(currentUserRoleId.toString());
    }
    
    final isB2bAccount = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 26);
    
    // Use b2b_icon.svg for B2B accounts, otherwise use a different icon
    final String centerIconPath = isB2bAccount 
        ? "assets/icon/b2b_icon.svg" 
        : "assets/icon/smile.svg";
    
    List<TabItem> items = [
      TabItem(
          activeIcon: SvgPicture.asset(
            "assets/icon/home.svg",
            color: AppColors.greyColor2,
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
            color: AppColors.greyColor2,
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
            centerIconPath,
            color: AppColors.whiteColor1,
            height: 20,
          ),
          icon: SvgPicture.asset(
            centerIconPath,
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
          initialActiveIndex: widget.index ?? 2,
          items: items,
          onTap: (int i) => changeBottomIndex(i),
        ),
      ),
    );
  }

  void changeBottomIndex(int index) {
    // For company users, make the third button (index 2) navigate to create ticket screen
    if (index == 2) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final currentUserRoleId = appProvider.userModel?.customer.roleId;
      
      // Parse roleId to integer
      int? roleIdInt;
      if (currentUserRoleId is int) {
        roleIdInt = currentUserRoleId;
      } else if (currentUserRoleId is String) {
        roleIdInt = int.tryParse(currentUserRoleId);
      } else if (currentUserRoleId != null) {
        roleIdInt = int.tryParse(currentUserRoleId.toString());
      }
      
      // Check if user is a company user (Admin 18, Team Leader 20, or Super User 26)
      final isCompanyUser = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 26);
      
      if (isCompanyUser) {
        // Navigate to create ticket screen for company users
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateUpdateTicketScreenV2(),
          ),
        ).then((success) {
          // If ticket was created successfully, refresh the tickets list in B2BHome
          if (success == true && context.mounted) {
            // Access HomeScreen state and refresh B2BHome tickets
            final homeScreenState = _homeScreenKey.currentState;
            if (homeScreenState != null && homeScreenState.mounted) {
              try {
                (homeScreenState as dynamic).refreshB2BHomeTickets();
              } catch (e) {
                // Method doesn't exist, ignore
              }
            }
          }
        });
        return; // Don't change the current index
      }
    }
    
    setState(() {
      currentIndex = index;
    });
  }

  void handelCurrentIndex(int? index) {
    if (index != null) {
      currentIndex = index;
    }
  }

  void showTutorial() {
    try {
    tutorialCoachMark.show(context: context);
    } catch (e) {
      // Silently fail if tutorial wasn't created or has no targets
    }
  }

  void createTutorial() {
    final targets = _createTargets();
    
    // Only create tutorial if there are valid targets
    if (targets.isEmpty) {
      return;
    }
    
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "Target 0",
        keyTarget: keyButton1,
        contents: [
          TargetContent(
            // align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Search for service",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "You can search for any service you want just by typing a few letters",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton,
        color: Colors.purple,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Titulo lorem ipsum",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.previous();
                    },
                    child: const Icon(Icons.chevron_left),
                  ),
                ],
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Target 2",
        keyTarget: keyButton4,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Multiples content",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          TargetContent(
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Multiples content",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ))
        ],
        shape: ShapeLightFocus.RRect,
      ),
    );
    targets.add(TargetFocus(
      identify: "Target 3",
      keyTarget: keyButton5,
      contents: [
        TargetContent(
            align: ContentAlign.right,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Title lorem ipsum",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Target 4",
      keyTarget: keyButton3,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  tutorialCoachMark.previous();
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.network(
                    "https://juststickers.in/wp-content/uploads/2019/01/flutter.png",
                    height: 200,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Image Load network",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(
      TargetFocus(
        identify: "Target 5",
        keyTarget: keyButton2,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "Multiples contents",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          TargetContent(
              align: ContentAlign.bottom,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Multiples contents",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ))
        ],
      ),
    );

    return targets;
  }
}
