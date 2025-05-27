import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/Home/home_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/active_ticket_model.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Home/Components/popular_section_widget.dart';
import 'package:wefix/Presentation/Home/Components/services_list_widget.dart';
import 'package:wefix/Presentation/Home/Components/special_offer_widget.dart';
import 'package:wefix/Presentation/Home/components/slider_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';
import 'package:wefix/Presentation/appointment/Components/border_animated_widget.dart';
import 'package:wefix/layout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  ActiveTicketModel? ticketModel;
  List<Category> allSearchCategories = [];
  bool startsSearch = false;

  @override
  void initState() {
    super.initState();
    getActiveTicket();
    getAllHomeApis().then((value) {});

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Slide from bottom to top (down to up)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // start offscreen bottom
      end: Offset.zero, // on screen
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward(); // Start animation on screen load
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  HomeModel? homeModel;
  bool loading = false;
  bool loading2 = false;

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: AppSize(context).width * .5,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  rightToLeft(const HomeLayout(
                    index: 3,
                  )),
                  (route) => false);
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.backgroundColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: SvgPicture.asset(
                      "assets/icon/smile.svg",
                      color: AppColors(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppText(context).hello} ${appProvider.userModel?.customer.name ?? "Guest"} 🖐",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSize(context).smallText2,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: AppSize(context).smallText1,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        actions: [
          const LanguageButton(),
          const SizedBox(
            width: 5,
          ),
          SvgPicture.asset("assets/icon/line.svg"),
          InkWell(
            onTap: () {
              Navigator.push(context, rightToLeft(NotificationsScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Badge(
                child: SvgPicture.asset("assets/icon/notification.svg"),
              ),
            ),
          ),
        ],
      ),
      body: (loading && loading2) == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : RefreshIndicator(
              color: AppColors(context).primaryColor,
              onRefresh: () {
                getAllHomeApis();
                getActiveTicket();
                return Future.delayed(
                  const Duration(seconds: 5),
                );
              },
              child: Stack(
                children: [
                  SvgPicture.asset("assets/icon/background.svg"),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderWidget(
                              images: homeModel?.sliders
                                      .map((e) => e.image ?? "")
                                      .toList() ??
                                  []),
                          const Divider(color: AppColors.backgroundColor),
                          SizedBox(height: AppSize(context).height * .02),
                          ticketModel?.tickets == null
                              ? SizedBox()
                              : AnimatedBorderContainer(
                                  child: Container(
                                    width: AppSize(context).width,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor1,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WidgetCachNetworkImage(
                                            width: AppSize(context).width * .3,
                                            height:
                                                AppSize(context).height * .15,
                                            image: ticketModel
                                                    ?.tickets.qrCodePath ??
                                                "",
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  languageProvider.lang == "ar"
                                                      ? ticketModel?.tickets
                                                              .descriptionAr ??
                                                          ""
                                                      : ticketModel?.tickets
                                                              .description ??
                                                          "",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: AppSize(context)
                                                        .smallText1,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  ticketModel?.tickets
                                                          .selectedDateTime ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: AppSize(context)
                                                        .smallText2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: AppSize(context).height * .02),
                          Text(
                            "🛠️ ${AppText(context).popularServices}",
                            style: TextStyle(
                              fontSize: AppSize(context).smallText1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          OffersSection(
                            services: homeModel?.servicePopular ?? [],
                          ),
                          const Divider(color: AppColors.backgroundColor),
                          SizedBox(height: AppSize(context).height * .01),
                          Text(
                            "🎉 ${AppText(context).specialOffer}",
                            style: TextStyle(
                              fontSize: AppSize(context).smallText1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          InkWell(
                            onTap: () {},
                            child: PopularServicesSection(
                              services: homeModel?.serviceOffers ?? [],
                            ),
                          ),
                          SizedBox(height: AppSize(context).height * .2),
                        ],
                      ),
                    ),
                  ),

                  // Animated Bottom Sheet
                  SlideTransition(
                    position: _offsetAnimation,
                    child: DraggableScrollableSheet(
                      initialChildSize: ticketModel?.tickets != null
                          ? 0.5
                          : 0.65, // higher initial size
                      minChildSize: 0.2,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.whiteColor1,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: ListView(
                            controller: scrollController,
                            children: [
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              WidgetTextField(
                                  "${AppText(context).searchforservice}",
                                  fillColor:
                                      AppColors.greyColorback.withOpacity(.5),
                                  haveBorder: false,
                                  radius: 15, onChanged: (value) {
                                setState(() {
                                  allSearchCategories.clear();
                                  startsSearch = true;
                                });

                                for (var category
                                    in homeModel?.categories ?? []) {
                                  if (languageProvider.lang == "ar"
                                      ? category.titleAr
                                              ?.toLowerCase()
                                              .contains(value.toLowerCase()) ??
                                          false
                                      : category.titleEn
                                              ?.toLowerCase()
                                              .contains(value.toLowerCase()) ??
                                          false) {
                                    setState(() {
                                      allSearchCategories.add(category);
                                    });
                                  }
                                }
                              }),
                              ServicesWidget(
                                  categories: startsSearch == false
                                      ? homeModel?.categories ?? []
                                      : allSearchCategories),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future getActiveTicket() async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.getActiveTicket(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          ticketModel = value;
          loading2 = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading2 = false;
      });
    }
  }

  Future getAllHomeApis() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      HomeApis.allHomeApis(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          homeModel = value;
          loading = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading = false;
      });
    }
  }
}
