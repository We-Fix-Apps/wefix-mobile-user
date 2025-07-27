import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Home/home_apis.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/sub_cat_model.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/time_appointment_model.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/Profile/Screens/proparity_screen.dart';
import 'package:wefix/Presentation/SubCategory/Components/tab_indecator.dart';
import 'package:wefix/Presentation/appointment/Screens/appointment_details_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/calender_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/service_card_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/service_quintity_card.dart';
import 'package:wefix/layout_screen.dart';

class SubServicesScreen extends StatefulWidget {
  final String title;
  final int catId;

  const SubServicesScreen({
    super.key,
    required this.title,
    required this.catId,
  });

  @override
  State<SubServicesScreen> createState() => _SubServicesScreenState();
}

class _SubServicesScreenState extends State<SubServicesScreen> {
  int selectedDate = 25;
  String? selectedTime;
  bool selectedGenderMale = true;
  bool selectedGenderFeMale = true;
  double totalPrice = 0.0;
  SubsicripeModel? subsicripeModel;

  Map<String, dynamic> appoitmentData = {};

  List<int> dates = [25, 26, 27, 28, 29, 30, 31];
  List<int> services = [];
  bool? status;

  List<Map> serviceId = [];
  bool loading5 = false;
  int totalTickets = 0;
  TimeAppoitmentModel? timeAppoitmentModel;

  String selectedTab = "Later";
  bool? isAddedd = false;

  bool? isLoading = false;
  bool? loading6 = false;
  bool? loadingTime = false;

  int count = 0;

  SubServiceModel? subServiceModel;

  @override
  void initState() {
    getTime();
    getSubCat();
    isSubsicribed();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: const [
            LanguageButton(),
          ],
          centerTitle: true,
          titleTextStyle: TextStyle(
              fontSize: AppSize(context).mediumText3,
              color: AppColors.blackColor1,
              fontWeight: FontWeight.bold),
          title: Text(widget.title),
        ),
        body: (isLoading == true) && (loadingTime == true)
            ? LinearProgressIndicator(
                color: AppColors(context).primaryColor,
                backgroundColor: AppColors.secoundryColor,
              )
            : subServiceModel?.service.length == 0
                ? const EmptyScreen()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: subServiceModel?.service.length ?? 0,
                          itemBuilder: (context, index) {
                            return subServiceModel
                                        ?.service[index].haveQuantity ==
                                    true
                                ? ServiceQuintityCardWidget(
                                    isSubsicribed: subsicripeModel?.status,
                                    increment: () {
                                      setState(() {
                                        subServiceModel!
                                            .service[index].quantity++;
                                        subsicripeModel?.status == false
                                            ? totalPrice += subServiceModel!
                                                .service[index].discountPrice
                                            : totalPrice += subServiceModel!
                                                    .service[index]
                                                    .subscriptionPrice ??
                                                0;
                                        totalTickets += subServiceModel
                                                ?.service[index].numOfTicket ??
                                            0;
                                      });

                                      // Check if service already exists in the list
                                      final existingIndex =
                                          serviceId.indexWhere(
                                        (element) =>
                                            element["ServiceId"] ==
                                            subServiceModel!.service[index].id,
                                      );

                                      if (existingIndex != -1) {
                                        // Update quantity if exists
                                        serviceId[existingIndex]["quantity"] =
                                            subServiceModel!
                                                .service[index].quantity;
                                      } else {
                                        // Add new service if not exists
                                        serviceId.add({
                                          "ServiceId": subServiceModel!
                                              .service[index].id,
                                          "quantity": subServiceModel!
                                              .service[index].quantity,
                                        });
                                      }

                                      log(serviceId.toString());
                                    },
                                    decrement: () {
                                      if (subServiceModel!
                                              .service[index].quantity >
                                          0) {
                                        setState(() {
                                          subServiceModel!
                                              .service[index].quantity--;
                                          subsicripeModel?.status == false
                                              ? totalPrice -= subServiceModel!
                                                  .service[index].discountPrice
                                              : totalPrice -= subServiceModel!
                                                      .service[index]
                                                      .subscriptionPrice ??
                                                  0;
                                          totalTickets -= subServiceModel
                                                  ?.service[index]
                                                  .numOfTicket ??
                                              0;
                                        });

                                        final existingIndex =
                                            serviceId.indexWhere(
                                          (element) =>
                                              element["ServiceId"] ==
                                              subServiceModel!
                                                  .service[index].id,
                                        );

                                        if (existingIndex != -1) {
                                          if (subServiceModel!
                                                  .service[index].quantity ==
                                              0) {
                                            // Quantity reached 0, remove from list
                                            serviceId.removeAt(existingIndex);
                                          } else {
                                            // Just update quantity
                                            serviceId[existingIndex]
                                                    ["quantity"] =
                                                subServiceModel!
                                                    .service[index].quantity;
                                          }
                                        }
                                      }

                                      log(serviceId.toString());
                                    },
                                    count: subServiceModel!
                                            .service[index].quantity ??
                                        0,
                                    isAddedd: subServiceModel!
                                        .service[index].isSelected,
                                    services: subServiceModel!.service[index],
                                    onTap: () {
                                      log(services.toString());
                                    },
                                  )
                                : ServiceCardWidget(
                                    isSubsicribed: subsicripeModel?.status,
                                    isAddedd: subServiceModel!
                                        .service[index].isSelected,
                                    services: subServiceModel!.service[index],
                                    onTap: () {
                                      setState(() {
                                        subServiceModel!
                                                .service[index].isSelected =
                                            !subServiceModel!
                                                .service[index].isSelected;

                                        if (subServiceModel!
                                                .service[index].isSelected ==
                                            true) {
                                          serviceId.add({
                                            "ServiceId": subServiceModel!
                                                .service[index].id,
                                            "quantity": 1,
                                          });
                                          subsicripeModel?.status == false
                                              ? totalPrice += subServiceModel!
                                                  .service[index].discountPrice
                                              : totalPrice += subServiceModel!
                                                      .service[index]
                                                      .subscriptionPrice ??
                                                  0;

                                          totalTickets += subServiceModel
                                                  ?.service[index]
                                                  .numOfTicket ??
                                              0;
                                          // Add the service price
                                        } else {
                                          final existingIndex =
                                              serviceId.indexWhere(
                                            (element) =>
                                                element["ServiceId"] ==
                                                subServiceModel!
                                                    .service[index].id,
                                          );

                                          serviceId.removeAt(existingIndex);

                                          subsicripeModel?.status == false
                                              ? totalPrice -= subServiceModel!
                                                  .service[index].discountPrice
                                              : totalPrice -= subServiceModel!
                                                      .service[index]
                                                      .subscriptionPrice ??
                                                  0;

                                          totalTickets -= subServiceModel
                                                  ?.service[index]
                                                  .numOfTicket ??
                                              0;
                                          // Remove the service price
                                        }
                                        isAddedd = subServiceModel!
                                            .service[index].isSelected;
                                      });
                                      log(services.toString());
                                    },
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
        bottomNavigationBar: serviceId.isEmpty
            ? const SizedBox()
            : Material(
                elevation: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: AppSize(context).height * .1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppText(context).total,
                              style: TextStyle(
                                fontSize: AppSize(context).smallText1,
                                color: AppColors.secoundryColor,
                              ),
                            ),
                            Text(
                              "${AppText(context).jod} ${totalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: AppSize(context).smallText2,
                                color: AppColors(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        CustomBotton(
                          title: AppText(context).continuesss,
                          width: AppSize(context).width * .3,
                          onTap: () {
                            showBottomSheetFun();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  showBottomSheetFun() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      useSafeArea: true,
      isScrollControlled: true, // allow full height
      backgroundColor: AppColors.whiteColor1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: AppSize(context).height * .9,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              int selectedTabIndex = 0; // track selected tab

              return DefaultTabController(
                length: 2,
                initialIndex: selectedTabIndex,
                child: Builder(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Row
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppText(context, isFunction: true)
                                    .selectDateTime,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),

                        // TabBar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .shade300, // Background for the whole tab bar
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            onTap: (index) {
                              setModalState(() {
                                selectedTabIndex = index;
                              });
                            },
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            indicator: RoundedTabIndicator(
                              color: AppColors(context).primaryColor, // Blue
                              radius: 12,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                  child: Text(
                                AppText(context, isFunction: true).later,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize(context).smallText2),
                              )),
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/icon/alert.gif",
                                      width: 30,
                                      height: 30,
                                      repeat: ImageRepeat.repeat,
                                    ),
                                    Text(
                                      AppText(context, isFunction: true)
                                          .emergency,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              AppSize(context).smallText2),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tab View
                        Expanded(
                          child: TabBarView(
                            children: [
                              _dateTimeContent(setModalState),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(),
                                  Center(
                                    child: Text(
                                        AppText(context, isFunction: true)
                                            .estimatedTimeToArrivalminutes),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CustomBotton(
                                      title: AppText(context, isFunction: true)
                                          .continuesss,
                                      loading: loading6,
                                      onTap: () {
                                        setModalState(() {
                                          loading6 = true;
                                        });
                                        chaeckAvalable().then((value) {
                                          setModalState(() {
                                            loading6 = false;
                                          });
                                          if (status == false) {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return WidgetDialog(
                                                    title: AppText(context,
                                                            isFunction: true)
                                                        .warning,
                                                    desc: AppText(context,
                                                            isFunction: true)
                                                        .wearesorryapp,
                                                    isError: true);
                                              },
                                            );
                                          } else {
                                            Navigator.pop(context);
                                            AppProvider appProvider =
                                                Provider.of<AppProvider>(
                                                    context,
                                                    listen: false);

                                            appProvider.saveAppoitmentInfo({
                                              "TicketTypeId": 1,
                                              "date": DateTime.now(),
                                              "time": "After 90 - 120 minutes",
                                              "services": serviceId,
                                              "totalPrice": totalPrice,
                                              "totalTickets": totalTickets,
                                              "gender": "Male",
                                            });

                                            if (subsicripeModel?.status ==
                                                true) {
                                              if ((subsicripeModel?.objSubscribe
                                                          ?.emeregencyVisit ??
                                                      0) <=
                                                  0) {
                                                showUpgradeDialog(context);
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  downToTop(
                                                      const UploadOptionsScreen()),
                                                );
                                              }
                                            } else {
                                              Navigator.push(
                                                context,
                                                downToTop(
                                                    const UploadOptionsScreen()),
                                              );
                                            }
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor1,
          icon: Center(
            child: Text(
              "🚀",
              style: TextStyle(fontSize: AppSize(context).largText1),
            ),
          ),
          title: Text(
            AppText(context, isFunction: true).upgradeandSaveBig,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // ignore: prefer_const_constructors
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                AppText(context, isFunction: true)
                    .subscribenowandsave50JODDonmissoutonthisspecialoffer,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity, // Ensures buttons take full width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomBotton(
                      height: AppSize(context).height * .04,
                      title: AppText(context, isFunction: true).subscribeNow,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            downToTop(HomeLayout(
                              index: 2,
                            )),
                            (route) => false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomBotton(
                      border: true,
                      color: AppColors.whiteColor1,
                      height: AppSize(context).height * .04,
                      title: AppText(context, isFunction: true).skip,
                      textColor: AppColors(context).primaryColor,
                      onTap: () {
                        pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dateTimeContent(StateSetter setModalState) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Date Selection
              CalenderWidget(
                onday: () {
                  getTime().then((value) {
                    setModalState(() {});
                  });
                },
              ),
              const SizedBox(height: 20),
              // Time Selection
              loadingTime == true
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LoadingText(
                        width: AppSize(context).width,
                        height: AppSize(context).height * .04,
                      ),
                    )
                  : SizedBox(
                      height: AppSize(context).height * .05,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: timeAppoitmentModel?.timesList.length,
                        itemBuilder: (context, index) {
                          final timeItem =
                              timeAppoitmentModel?.timesList[index];
                          final isSelected = timeItem?.time == selectedTime;
                          final isDisabled = timeItem?.status == false;

                          return GestureDetector(
                            onTap: isDisabled
                                ? null
                                : () {
                                    setModalState(() =>
                                        selectedTime = timeItem?.time ?? "");
                                    setState(() {}); // Reflect changes
                                  },
                            child: Opacity(
                              opacity:
                                  isDisabled ? 0.4 : 1.0, // visually greyed out
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors(context).primaryColor
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  timeItem?.time ?? "",
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.whiteColor1
                                        : AppColors.blackColor1,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomBotton(
              loading: loading6,
              title: AppText(context, isFunction: true).continuesss,
              onTap: () {
                if (selectedTime != null) {
                  setModalState(() {
                    loading6 = true;
                  });
                  chaeckAvalable().then((value) {
                    setModalState(() {
                      loading6 = false;
                    });
                    if (status == false) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return WidgetDialog(
                              title: AppText(context, isFunction: true).warning,
                              desc: AppText(context, isFunction: true)
                                  .wearesorryapp,
                              isError: true);
                        },
                      );
                    } else {
                      appProvider.saveAppoitmentInfo({
                        "TicketTypeId": 3,
                        "date": appProvider.selectedDate ?? DateTime.now(),
                        "time": selectedTime,
                        "services": serviceId,
                        "totalPrice": totalPrice,
                        "totalTickets": totalTickets,
                        "gender": "Male",
                      });
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        downToTop(UploadOptionsScreen(
                          data: {
                            "TicketTypeId": 3,
                            "date": appProvider.selectedDate ?? DateTime.now(),
                            "time": selectedTime,
                            "services": services,
                            "totalPrice": totalPrice,
                            "totalTickets": totalTickets,
                            "gender": "Male",
                          },
                        )),
                      );
                    }
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return WidgetDialog(
                        title: AppText(context, isFunction: true).warning,
                        desc: "Please select a time",
                        isError: true,
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Continue Button
        ],
      ),
    );
  }

  maleOrFemail() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: false,
      backgroundColor: AppColors.whiteColor1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, set) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: AppSize(context).width,
              height: AppSize(context).height * 0.4,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppText(context, isFunction: true)
                            .chooseTechniciaGender,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          set(() {
                            selectedGenderMale = true;
                            selectedGenderFeMale = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: selectedGenderMale == true
                                    ? AppColors(context).primaryColor
                                    : AppColors.greyColor1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/image/Layer 12.png",
                              height: AppSize(context).height * .2,
                              width: AppSize(context).width * .4,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          set(() {
                            selectedGenderFeMale = true;
                            selectedGenderMale = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: selectedGenderFeMale == true
                                    ? AppColors(context).primaryColor
                                    : AppColors.greyColor1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/image/Layer 13.png",
                              height: AppSize(context).height * .2,
                              width: AppSize(context).width * .4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppSize(context).height * .05,
                  ),
                  CustomBotton(
                      title: AppText(context, isFunction: true).continuesss,
                      onTap: () {
                        pop(context);
                        Navigator.push(context,
                            downToTop(const AppoitmentDetailsScreen()));
                      }),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future getSubCat() async {
    setState(() {
      isLoading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      HomeApis.getSubCatService(
              token: appProvider.userModel?.token ?? "",
              id: widget.catId.toString())
          .then((value) {
        setState(() {
          subServiceModel = value;
          isLoading = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future getTime() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    setState(() {
      loadingTime = true;
    });

    final selectedDateStr = appProvider.selectedDate.toString().isEmpty
        ? DateTime.now().toString().substring(0, 10)
        : appProvider.selectedDate.toString().substring(0, 10);

    final result = await ProfileApis.getAppitmentTime(
      token: '${appProvider.userModel?.token}',
      date: selectedDateStr,
    );

    if (result != null) {
      log(result.toString());

      DateTime now = DateTime.now();
      DateTime selectedDate = DateTime.parse(selectedDateStr);
      bool isToday = now.year == selectedDate.year &&
          now.month == selectedDate.month &&
          now.day == selectedDate.day;

      if (isToday) {
        result.timesList.removeWhere((element) {
          final parts = element.time.split(' - ');
          if (parts.length != 2) return true;

          try {
            String startTimeStr = parts[0].trim(); // e.g. "08:00"
            String endTimeStr = parts[1].trim(); // e.g. "10:00 AM"
            String period = endTimeStr.split(' ').last; // "AM" or "PM"

            // Append AM/PM to start time
            startTimeStr = '$startTimeStr $period';

            // Create full datetime string
            final fullDateTimeStr =
                '${DateFormat('yyyy-MM-dd').format(now)} $startTimeStr';

            // Parse it
            final startDateTime =
                DateFormat('yyyy-MM-dd hh:mm a').parse(fullDateTimeStr);

            return now.isAfter(startDateTime); // remove if expired
          } catch (e) {
            log('Time parsing error: $e');
            return true; // remove on parse failure
          }
        });
      }

      setState(() {
        timeAppoitmentModel = result;
        loadingTime = false;

        // Select the first valid slot
        for (TimesList element in timeAppoitmentModel?.timesList ?? []) {
          if (element.status == true) {
            selectedTime = element.time;
            break;
          }
        }
      });
    }
  }

  Future chaeckAvalable() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    setState(() {
      loading6 = true;
    });

    await ProfileApis.chaeckAvalable(
            token: '${appProvider.userModel?.token}',
            date: DateFormat('yyyy-MM-dd')
                .format(appProvider.selectedDate ?? DateTime.now()))
        .then((value) {
      setState(() {
        loading6 = false;
        status = value;
      });
    });
  }

  Future isSubsicribed() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    setState(() {
      loading5 = true;
    });

    await ProfileApis.isSubsicribe(
      token: '${appProvider.userModel?.token}',
    ).then((value) {
      if (value != null) {
        setState(() {
          subsicripeModel = value;
        });

        setState(() {
          loading5 = false;
        });
      } else {
        setState(() {
          loading5 = false;
        });
      }
    });
  }
}
