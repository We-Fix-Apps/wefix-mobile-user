import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/Home/home_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/active_ticket_model.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Presentation/B2B/home_b2b.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/tour_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Home/Components/popular_section_widget.dart';
import 'package:wefix/Presentation/Home/Components/services_list_widget.dart';
import 'package:wefix/Presentation/Home/Components/slider_widget.dart';
import 'package:wefix/Presentation/Home/Components/special_offer_widget.dart';
import 'package:wefix/Presentation/Home/Components/steps_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';
import 'package:wefix/Presentation/appointment/Components/border_animated_widget.dart';
import 'package:wefix/layout_screen.dart';
import 'package:wefix/main.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey? keyButton;
  const HomeScreen({super.key, this.keyButton});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  ActiveTicketModel? ticketModel;
  List<Category> allSearchCategories = [];
  bool startsSearch = false;

  late TutorialCoachMark tutorialCoachMark;

  final List<GlobalKey<State<StatefulWidget>>> keyButtons = [
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
  ];

  List<Map> contents = [
    {
      "title": AppText(navigatorKey.currentState!.context).yourdetails,
      "description": AppText(navigatorKey.currentState!.context).checkProfile,
      "image": "assets/image/profile.png",
      "isTop": false,
    },
    {
      "title": AppText(navigatorKey.currentState!.context).searchforservice,
      "description": AppText(navigatorKey.currentState!.context).youcansearch,
      "image": "assets/image/search.png",
      "isTop": false,
    },
  ];
  SubsicripeModel? subsicripeModel;
  bool loading5 = false;

  @override
  void initState() {
    super.initState();
    isSubsicribed();

    getAllHomeApis().then((value) {
      _controller.forward();

      getActiveTicket();

      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomeTutorialCoachMark.createTutorial(keyButtons, contents);
          Future.delayed(const Duration(seconds: 2), () {
            final tourData = CacheHelper.getData(key: CacheHelper.showTour);
            Map showTour = tourData != null && tourData != 'null'
                ? json.decode(tourData)
                : {
                    "home": true,
                    "subCategory": true,
                    "addAttachment": true,
                    "appointmentDetails": true,
                    "checkout": true,
                  };
            CustomeTutorialCoachMark.showTutorial(context,
                isShow: showTour["home"] ?? true);
            setState(() {
              showTour["home"] = false;
            });
            CacheHelper.saveData(
                key: CacheHelper.showTour, value: json.encode(showTour));
            log(showTour.toString());
          });
        });
      } catch (e) {
        log(e.toString());
      }
    });

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
  }

  getCatId() {
    for (SliderModel element in homeModel?.sliders ?? []) {
      log("Category ID: ${element.categoryId}");
      return element.categoryId;
    }
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
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    return appProvider.userModel?.customer.roleId == 2
        ? loading5 == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors(context).primaryColor,
                  backgroundColor: AppColors.secoundryColor,
                ),
              )
            : subsicripeModel?.status == false
                ? EmptyScreen(
                    image: "assets/icon/contract_empty.svg",
                    title: "You don't have any subscriptions yet",
                    subtitle: "Subscribe now",
                    titleBtn: "Subscribe now",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          downToTop(const HomeLayout(
                            index: 2,
                          )),
                          (route) => false);
                    },
                  )
                : B2BHome(
                    subsicripeModel: subsicripeModel,
                  )
        : Scaffold(
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          child: SvgPicture.asset(
                            "assets/icon/smile.svg",
                            key: keyButtons[0],
                            color: AppColors(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                "${AppText(context).hello} ${appProvider.userModel?.customer.name ?? "Guest"} 🖐",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSize(context).smallText2,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                DateFormat('MMM d, yyyy').format(DateTime.now()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText1,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                SvgPicture.asset(
                  "assets/icon/line.svg",
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, rightToLeft(NotificationsScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Badge(
                      child: SvgPicture.asset(
                        "assets/icon/notification.svg",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: (loading) == true
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
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SliderWidget(
                                      catId: homeModel?.sliders
                                              .map((e) => e.categoryId ?? 0)
                                              .toList() ??
                                          [],
                                      images: homeModel?.sliders
                                              .map((e) => e.image ?? "")
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                        color: AppColors.backgroundColor),
                                    if (ticketModel?.tickets.isNotEmpty ??
                                        false)
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "🔍 ${AppText(context).progressOverview}",
                                            style: TextStyle(
                                              fontSize:
                                                  AppSize(context).smallText1,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  rightToLeft(
                                                      TicketDetailsScreen(
                                                          id: ticketModel!
                                                              .tickets[0].id
                                                              .toString())));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  appProvider.lang == "en"
                                                      ? Column(
                                                          children: [
                                                            ticketModel!
                                                                        .tickets[
                                                                            0]
                                                                        .process
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    "request registered"
                                                                ? Image.asset(
                                                                    "assets/image/1en.png",
                                                                    width: AppSize(context)
                                                                            .width *
                                                                        .9,
                                                                  )
                                                                : ticketModel!
                                                                            .tickets[
                                                                                0]
                                                                            .process
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "visit scheduled"
                                                                    ? Image
                                                                        .asset(
                                                                        "assets/image/2en.png",
                                                                        width: AppSize(context).width *
                                                                            .9,
                                                                      )
                                                                    : ticketModel!.tickets[0].process.toString().toLowerCase() ==
                                                                            "ready to visit"
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/image/3en.png",
                                                                            width:
                                                                                AppSize(context).width * .9,
                                                                          )
                                                                        : ticketModel!.tickets[0].process.toString().toLowerCase() ==
                                                                                "awaiting rating"
                                                                            ? Image.asset(
                                                                                "assets/image/4en.png",
                                                                                width: AppSize(context).width * .9,
                                                                              )
                                                                            : ticketModel!.tickets[0].isWithMaterial == true
                                                                                ? Image.asset(
                                                                                    "assets/image/4en.png",
                                                                                    width: AppSize(context).width * .9,
                                                                                  )
                                                                                : const SizedBox()
                                                          ],
                                                        )
                                                      : Column(
                                                          children: [
                                                            ticketModel!
                                                                        .tickets[
                                                                            0]
                                                                        .process
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    "request registered"
                                                                ? Image.asset(
                                                                    "assets/image/1-01-01.png",
                                                                    width: AppSize(context)
                                                                            .width *
                                                                        .9,
                                                                  )
                                                                : ticketModel!
                                                                            .tickets[
                                                                                0]
                                                                            .process
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "visit scheduled"
                                                                    ? Image
                                                                        .asset(
                                                                        "assets/image/2-01-01.png",
                                                                        width: AppSize(context).width *
                                                                            .9,
                                                                      )
                                                                    : ticketModel!.tickets[0].process.toString().toLowerCase() ==
                                                                            "ready to visit"
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/image/3-01-01.png",
                                                                            width:
                                                                                AppSize(context).width * .9,
                                                                          )
                                                                        : ticketModel!.tickets[0].process.toString().toLowerCase() ==
                                                                                "awaiting rating"
                                                                            ? Image.asset(
                                                                                "assets/image/4-01-01.png",
                                                                                width: AppSize(context).width * .9,
                                                                              )
                                                                            : ticketModel!.tickets[0].isWithMaterial == true
                                                                                ? Image.asset(
                                                                                    "assets/image/5-01.png",
                                                                                    width: AppSize(context).width * .9,
                                                                                  )
                                                                                : const SizedBox(),
                                                          ],
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                            color: AppColors.backgroundColor,
                                            height: 1,
                                          ),
                                        ],
                                      ),
                                    // SizedBox(height: AppSize(context).height * .02),
                                    ticketModel?.tickets.isEmpty ?? true
                                        ? const SizedBox()
                                        : Center(
                                            child: SizedBox(
                                              height:
                                                  AppSize(context).height * .16,
                                              width: AppSize(context).width,
                                              child: ListView.separated(
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const SizedBox(
                                                  width: 10,
                                                ),
                                                itemCount: ticketModel
                                                        ?.tickets.length ??
                                                    0,
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return AnimatedBorderContainer(
                                                    child: Container(
                                                      width: AppSize(context)
                                                              .width *
                                                          .93,
                                                      height: AppSize(context)
                                                              .height *
                                                          .2,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .whiteColor1,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  WidgetCachNetworkImage(
                                                                width: AppSize(
                                                                            context)
                                                                        .width *
                                                                    .3,
                                                                height: AppSize(
                                                                            context)
                                                                        .height *
                                                                    .15,
                                                                image: ticketModel
                                                                        ?.tickets[
                                                                            index]
                                                                        .qrCodePath ??
                                                                    "",
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    languageProvider.lang ==
                                                                            "ar"
                                                                        ? ticketModel?.tickets[index].descriptionAr ??
                                                                            ""
                                                                        : ticketModel?.tickets[index].description ??
                                                                            "",
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          AppSize(context)
                                                                              .smallText1,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                          "🕑 "),
                                                                      Text(
                                                                        ticketModel?.tickets[index].selectedDateTime ??
                                                                            "",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              AppSize(context).smallText2,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                          "🗓 "),
                                                                      Text(
                                                                        ticketModel?.tickets[index].selectedDate.toString().substring(0,
                                                                                10) ??
                                                                            "",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              AppSize(context).smallText2,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                        height: AppSize(context).height * .02),
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
                                    const Divider(
                                        color: AppColors.backgroundColor),
                                    SizedBox(
                                        height: AppSize(context).height * .01),
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
                                        services:
                                            homeModel?.serviceOffers ?? [],
                                      ),
                                    ),
                                    SizedBox(
                                        height: AppSize(context).height * .2),
                                  ],
                                ),
                              ),
                            ],
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
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30)),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    WidgetTextField(
                                        "${AppText(context).searchforservice}",
                                        key: keyButtons[1],
                                        fillColor: AppColors.greyColorback
                                            .withOpacity(.5),
                                        haveBorder: false,
                                        radius: 15, onChanged: (value) {
                                      setState(() {
                                        allSearchCategories.clear();
                                        startsSearch = true;
                                      });

                                      final searchValue = value.toLowerCase();

                                      for (var category
                                          in homeModel?.categories ?? []) {
                                        final isCategoryTitleMatch =
                                            languageProvider.lang == "ar"
                                                ? category.titleAr
                                                        ?.toLowerCase()
                                                        .contains(
                                                            searchValue) ??
                                                    false
                                                : category.titleEn
                                                        ?.toLowerCase()
                                                        .contains(
                                                            searchValue) ??
                                                    false;

                                        bool isMatchInSubCategoryOrService =
                                            false;

                                        // ✅ Check subcategories if they exist
                                        if (category.subCategory != null &&
                                            category.subCategory!.isNotEmpty) {
                                          for (var subCat
                                              in category.subCategory!) {
                                            final isSubTitleMatch =
                                                languageProvider.lang == "ar"
                                                    ? subCat.titleAr
                                                            ?.toLowerCase()
                                                            .contains(
                                                                searchValue) ??
                                                        false
                                                    : subCat.titleEn
                                                            ?.toLowerCase()
                                                            .contains(
                                                                searchValue) ??
                                                        false;

                                            final isServiceMatch =
                                                (subCat.service
                                                            as List<Service>?)
                                                        ?.any((srv) {
                                                      return languageProvider
                                                                  .lang ==
                                                              "ar"
                                                          ? srv.nameAr
                                                                  ?.toLowerCase()
                                                                  .contains(
                                                                      searchValue) ??
                                                              false
                                                          : srv.name
                                                                  ?.toLowerCase()
                                                                  .contains(
                                                                      searchValue) ??
                                                              false;
                                                    }) ??
                                                    false;

                                            if (isSubTitleMatch ||
                                                isServiceMatch) {
                                              isMatchInSubCategoryOrService =
                                                  true;
                                              break;
                                            }
                                          }
                                        }

                                        // ✅ Fallback: check services directly inside category (if any)
                                        if (!isMatchInSubCategoryOrService &&
                                            category is dynamic &&
                                            category.service != null) {
                                          final isDirectServiceMatch = (category
                                                          .service
                                                      as List<Service>?)
                                                  ?.any((srv) {
                                                return languageProvider.lang ==
                                                        "ar"
                                                    ? srv.nameAr
                                                            ?.toLowerCase()
                                                            .contains(
                                                                searchValue) ??
                                                        false
                                                    : srv.name
                                                            ?.toLowerCase()
                                                            .contains(
                                                                searchValue) ??
                                                        false;
                                              }) ??
                                              false;

                                          if (isDirectServiceMatch) {
                                            isMatchInSubCategoryOrService =
                                                true;
                                          }
                                        }

                                        // ✅ If any match — add the category
                                        if (isCategoryTitleMatch ||
                                            isMatchInSubCategoryOrService) {
                                          setState(() {
                                            allSearchCategories.add(category);
                                          });
                                        }
                                      }
                                    }),
                                    SizedBox(
                                        height: AppSize(context).height * .01),
                                    ServicesWidget(
                                      roleId:homeModel?.roleId ?? 0,
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

  Future isSubsicribed({isfromPlaceOreder = true}) async {
    AppProvider appProvider = Provider.of(context, listen: false);

    setState(() {
      loading5 = true;
    });

    await ProfileApis.isSubsicribe(
            token: '${appProvider.userModel?.token}', isCompany: true)
        .then((value) {
      if (value != null) {
        setState(() {
          subsicripeModel = value;
        });

        setState(() {
          loading5 = false;
        });
      } else {
        // addRequest().then((value) {
        //   showUpgradeDialog(context);
        // });
        setState(() {
          loading5 = false;
        });
      }
    });
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
    await Permission.notification.request();
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
