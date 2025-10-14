import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/B2b/b2b_api.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/advantages_model.dart';
import 'package:wefix/Data/model/branch_model.dart';
import 'package:wefix/Data/model/realstate_model.dart';
import 'package:wefix/Presentation/Components/tour_widget.dart';

import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/appointment/Components/attachments_widget.dart';
import 'package:wefix/Presentation/appointment/Components/date_time_widget.dart';
import 'package:wefix/Presentation/Checkout/Screens/checkout_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/main.dart';

import '../../../Business/orders/profile_api.dart';

class AppoitmentDetailsScreen extends StatefulWidget {
  const AppoitmentDetailsScreen({super.key});

  @override
  State<AppoitmentDetailsScreen> createState() =>
      _AppoitmentDetailsScreenState();
}

class _AppoitmentDetailsScreenState extends State<AppoitmentDetailsScreen>
    with TickerProviderStateMixin {
  List attachments = [
    "assets/icon/imge.svg",
    "assets/icon/vid.svg",
    "assets/icon/pdf.svg"
  ];

  late AnimationController _serviceController;
  bool needsMaterial = false;
  final TextEditingController materialCostController = TextEditingController();
  BranchesModel? branchesModel;

  late AnimationController _dateController;
  var key = GlobalKey<FormState>();
  String? selectedType;

  bool? loading = false;
  bool? loadingAdv = false;
  AdvantagesModel? advantagesModel;

  RealEstatesModel? realEstatesModel;
  List<int> selectedServiceIds = [];
  double totalPrice = 0.0;
  final List<GlobalKey<State<StatefulWidget>>> keyButton = [
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
  ];

  List<Map> content = [
    {
      "title": AppText(navigatorKey.currentState!.context).editAppointmentTime,
      "description": AppText(navigatorKey.currentState!.context)
          .editAppointmentTimeDescription,
      "image": "assets/image/date.png",
      "isTop": false
    },
    {
      "title":
          AppText(navigatorKey.currentState!.context).addAdditionalServices,
      "description": AppText(navigatorKey.currentState!.context)
          .addAdditionalServicesDescription,
      "image": "assets/image/Layer 12.png",
      "isTop": false
    },
    {
      "title": AppText(navigatorKey.currentState!.context).viewYourAttachments,
      "description": AppText(navigatorKey.currentState!.context)
          .viewYourAttachmentsDescription,
      "image": "assets/image/file.png",
      "isTop": true
    },
    {
      "title":
          AppText(navigatorKey.currentState!.context).continueYourAppointment,
      "description": AppText(navigatorKey.currentState!.context)
          .continueYourAppointmentDescription,
      "image": "assets/image/cont.png",
      "isTop": true
    }
  ];

  @override
  void initState() {
    getRealState();
    getBranches();
    getAdv();

    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomeTutorialCoachMark.createTutorial(keyButton, content);
        Future.delayed(const Duration(seconds: 1), () {
          Map showTour =
              json.decode(CacheHelper.getData(key: CacheHelper.showTour));
          CustomeTutorialCoachMark.showTutorial(context,
              isShow: showTour["appointmentDetails"] ?? true);
          setState(() {
            showTour["appointmentDetails"] = false;
          });
          CacheHelper.saveData(
              key: CacheHelper.showTour, value: json.encode(showTour));
          log(showTour.toString());
        });
      });
    } catch (e) {
      log(e.toString());
    }

    super.initState();

    _serviceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _dateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animations with slight delay
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _serviceController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _dateController.forward();
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageButton(),
        ],
        title: Text(AppText(context).appointmentDetails),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            children: [
              Stack(
                children: [
                  SvgPicture.asset("assets/icon/background.svg"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animate DateTimeWidget
                        DateTimeWidget(
                          dateKey: keyButton[0],
                          featureKey: keyButton[1],
                          date: appProvider.appoitmentInfo["date"]
                              .toString()
                              .substring(0, 10),
                          time: appProvider.appoitmentInfo["time"].toString(),
                        ),
                        appProvider.userModel?.customer.roleId == 2
                            ? SizedBox()
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SwitchListTile.adaptive(
                                      activeColor:
                                          AppColors(context).primaryColor,
                                      secondary: SvgPicture.asset(
                                        "assets/icon/optimizing.svg",
                                        height: AppSize(context).height * .05,
                                        width: AppSize(context).width * .1,
                                      ),
                                      title: Text(
                                        AppText(context)
                                            .needmaterialfromprovider,
                                        style: TextStyle(
                                          fontSize: AppSize(context).smallText2,
                                        ),
                                      ),
                                      inactiveThumbColor: AppColors.whiteColor1,
                                      inactiveTrackColor: AppColors.greyColor1,
                                      overlayColor: MaterialStateProperty.all(
                                        AppColors(context)
                                            .primaryColor
                                            .withOpacity(.2),
                                      ),
                                      value:
                                          appProvider.isMaterialFromProvider ??
                                              false,
                                      onChanged: (value) {
                                        appProvider
                                            .isMaterailFromProvider(value);
                                        setState(() => needsMaterial = value);
                                      },
                                    ),
                                  ),
                                  if (appProvider.isMaterialFromProvider ??
                                      false) ...[
                                    WidgetTextField(
                                      AppText(context, isFunction: true)
                                          .canyoutelluswhatmaterialisneeded,
                                      controller: materialCostController,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ],
                                  loadingAdv == true
                                      ? LoadingText(
                                          width: AppSize(context).width,
                                          height: AppSize(context).height * .05,
                                        )
                                      : ListView.builder(
                                          itemBuilder: (context, index) {
                                            final advantage = advantagesModel
                                                ?.advantages[index];
                                            final isSelected =
                                                selectedServiceIds.contains(
                                                    advantage?.id ?? -1);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SwitchListTile.adaptive(
                                                subtitle: Text(
                                                  languageProvider.lang == "ar"
                                                      ? advantage?.subTitleAr ??
                                                          ""
                                                      : advantage?.subTitleEn ??
                                                          "",
                                                  style: TextStyle(
                                                      fontSize: AppSize(context)
                                                          .smallText3,
                                                      color:
                                                          AppColors.greyColor2),
                                                ),
                                                activeColor: AppColors(context)
                                                    .primaryColor,
                                                secondary: advantage?.icon
                                                            .endsWith("svg") ??
                                                        false
                                                    ? SvgPicture.network(
                                                        advantage?.icon ?? "",
                                                        height: AppSize(context)
                                                                .height *
                                                            .05,
                                                        width: AppSize(context)
                                                                .width *
                                                            .1,
                                                      )
                                                    : Image.network(
                                                        advantage?.icon ?? "",
                                                        height: AppSize(context)
                                                                .height *
                                                            .05,
                                                        width: AppSize(context)
                                                                .width *
                                                            .1,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size:
                                                                AppSize(context)
                                                                        .width *
                                                                    .1,
                                                            color: AppColors
                                                                .greyColor2,
                                                          );
                                                        },
                                                      ),
                                                title: Text(
                                                  languageProvider.lang == "ar"
                                                      ? advantage?.titleAr ?? ""
                                                      : advantage?.titleEn ??
                                                          "",
                                                  style: TextStyle(
                                                    fontSize: AppSize(context)
                                                        .smallText2,
                                                  ),
                                                ),
                                                inactiveThumbColor:
                                                    AppColors.whiteColor1,
                                                inactiveTrackColor:
                                                    AppColors.greyColor1,
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                  AppColors(context)
                                                      .primaryColor
                                                      .withOpacity(.2),
                                                ),
                                                value: isSelected,
                                                onChanged: (value) {
                                                  setState(() {
                                                    final id = advantage?.id;
                                                    final price =
                                                        advantage?.price ?? 0.0;

                                                    if (value && id != null) {
                                                      if (!selectedServiceIds
                                                          .contains(id)) {
                                                        selectedServiceIds
                                                            .add(id);
                                                        totalPrice += price;
                                                      }
                                                    } else if (!value &&
                                                        id != null) {
                                                      selectedServiceIds
                                                          .remove(id);
                                                      totalPrice -= price;
                                                    }
                                                  });

                                                  log(selectedServiceIds
                                                      .toString());
                                                  log("Total Price: $totalPrice");

                                                  appProvider.saveAdvantages({
                                                    "advantages":
                                                        selectedServiceIds,
                                                    "totalPrice": totalPrice,
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                          itemCount: advantagesModel
                                                  ?.advantages.length ??
                                              0,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                        ),
                                ],
                              ),
                        const Divider(
                          color: AppColors.backgroundColor,
                        ),

                        Container(
                          key: keyButton[2],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "📎 ${AppText(context).attachments}",
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    showAttachmentBottomSheet(context);
                                  },
                                  child: Text(
                                    AppText(context).viewAttachments,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors(context).primaryColor,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const Divider(
                          color: AppColors.backgroundColor,
                        ),

                        realEstatesModel?.realEstates.isEmpty == true
                            ? const SizedBox()
                            : appProvider.userModel?.customer.roleId == 2
                                ? SizedBox()
                                : Text(
                                    "🏠	 ${AppText(context).propertyName}",
                                    style: TextStyle(
                                      fontSize: AppSize(context).smallText1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        const SizedBox(
                          height: 5,
                        ),

                        loading == true
                            ? const LoadingText(width: 100)
                            : realEstatesModel?.realEstates.isEmpty == true
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      width: AppSize(context).width,
                                      height: AppSize(context).height * 0.06,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundColor,
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            color: AppColors.greyColor3),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButton<String>(
                                            isDense: true,
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            value: selectedType,
                                            hint: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              child: Text(""),
                                            ),
                                            items: realEstatesModel?.realEstates
                                                .map((item) => DropdownMenuItem(
                                                      value: item.id.toString(),
                                                      child: Text(item.title),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              appProvider
                                                  .setRealStateId(value ?? "");
                                              setState(() {
                                                selectedType = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                        realEstatesModel?.realEstates.isEmpty == true
                            ? const SizedBox()
                            : const Divider(
                                color: AppColors.backgroundColor,
                              ),
                        Text(
                          "🏠 Branch name",
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: AppSize(context).width,
                            height: AppSize(context).height * 0.06,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: AppColors.greyColor3),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  isDense: true,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  value: selectedType,
                                  hint: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(""),
                                  ),
                                  items: branchesModel?.branches
                                      .map((item) => DropdownMenuItem(
                                            value: item.id.toString(),
                                            child: Text(item.name),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    appProvider.setRealStateId(value ?? "");
                                    setState(() {
                                      selectedType = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        key: keyButton[3],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomBotton(
              title: AppText(context).confirmAppointment,
              onTap: () {
                if (key.currentState!.validate()) {
                  Navigator.push(context, rightToLeft(const CheckoutScreen()));
                }
              }),
        ),
      ),
    );
  }

  Future getBranches() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    B2bApi.getBranches(token: appProvider.userModel?.token ?? '').then((value) {
      if (value != null) {
        setState(() {
          loading = false;
          branchesModel = value;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void showAttachmentBottomSheet(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppText(context, isFunction: true).attachmentPreview,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AttachmentsWidget(
                      image: appProvider.attachments[index].split('-').last,
                      url: appProvider.attachments[index],
                    );
                  },
                  itemCount: appProvider.attachments.length,
                  shrinkWrap: true),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future getRealState() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.getRealState(
      token: '${appProvider.userModel?.token}',
    ).then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            loading = false;
            realEstatesModel = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }
    });
  }

  Future getAdv() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loadingAdv = true;
      });
    }
    await BookingApi.getAdvantages(
      token: '${appProvider.userModel?.token}',
    ).then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            advantagesModel = value;
            loadingAdv = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingAdv = false;
          });
        }
      }
    });
  }
}
