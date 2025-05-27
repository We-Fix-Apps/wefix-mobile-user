import 'dart:developer';

import 'package:flutter/material.dart';
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
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/appointment/Screens/appointment_details_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/calender_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/service_card_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/service_quintity_card.dart';

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
  String selectedTime = "04:00 - 06:00 PM";
  bool selectedGenderMale = true;
  bool selectedGenderFeMale = true;
  double totalPrice = 0.0;
  SubsicripeModel? subsicripeModel;

  Map<String, dynamic> appoitmentData = {};

  List<int> dates = [25, 26, 27, 28, 29, 30, 31];
  List<int> services = [];

  List<Map> serviceId = [];
  bool loading5 = false;
  int totalTickets = 0;

  List<String> weekDays = ["TUE", "WED", "THU", "FRI", "SAT", "SUN", "MON"];
  List<String> times = [
    "04:00 - 06:00 PM",
    "05:00 - 06:00 PM",
    "06:00 - 08:00 PM",
    "07:00 - 09:00 PM"
  ];

  String selectedTab = "Later";
  bool? isAddedd = false;

  bool? isLoading = false;
  int count = 0;

  SubServiceModel? subServiceModel;

  @override
  void initState() {
    getSubCat();
    isSubsicribed();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageButton(),
        ],
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: isLoading == true
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
                          return subServiceModel?.service[index].haveQuantity ==
                                  true
                              ? ServiceQuintityCardWidget(
                                  isSubsicribed: subsicripeModel?.status,
                                  increment: () {
                                    setState(() {
                                      subServiceModel!
                                          .service[index].quantity++;
                                      totalPrice += subServiceModel!
                                              .service[index].discountPrice ??
                                          0.0;
                                      totalTickets += subServiceModel
                                              ?.service[index].numOfTicket ??
                                          0;
                                    });

                                    // Check if service already exists in the list
                                    final existingIndex = serviceId.indexWhere(
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
                                        "ServiceId":
                                            subServiceModel!.service[index].id,
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
                                        totalPrice -= subServiceModel!
                                                .service[index].discountPrice ??
                                            0.0;
                                        totalTickets -= subServiceModel
                                                ?.service[index].numOfTicket ??
                                            0;
                                      });

                                      final existingIndex =
                                          serviceId.indexWhere(
                                        (element) =>
                                            element["ServiceId"] ==
                                            subServiceModel!.service[index].id,
                                      );

                                      if (existingIndex != -1) {
                                        if (subServiceModel!
                                                .service[index].quantity ==
                                            0) {
                                          // Quantity reached 0, remove from list
                                          serviceId.removeAt(existingIndex);
                                        } else {
                                          // Just update quantity
                                          serviceId[existingIndex]["quantity"] =
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
                                        totalPrice += subServiceModel!
                                            .service[index].discountPrice;

                                        totalTickets += subServiceModel
                                                ?.service[index].numOfTicket ??
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

                                        totalPrice -= subServiceModel!
                                            .service[index].discountPrice;

                                        totalTickets -= subServiceModel
                                                ?.service[index].numOfTicket ??
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
          height: AppSize(context).height * .8,
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
                            color: AppColors.whiteColor1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            onTap: (index) {
                              setModalState(() {
                                selectedTabIndex = index;
                              });
                            },
                            indicator: const BoxDecoration(
                              color: AppColors.whiteColor1,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            labelColor: AppColors(context).primaryColor,
                            unselectedLabelColor: AppColors.blackColor1,
                            tabs: [
                              Tab(
                                  text:
                                      AppText(context, isFunction: true).later),
                              Tab(
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/icon/alert.gif",
                                      width: 30,
                                      height: 30,
                                      repeat: ImageRepeat.repeat,
                                    ),
                                    Text(AppText(context, isFunction: true)
                                        .emergency)
                                  ],
                                ),
                              ),
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
                                      onTap: () {
                                        Navigator.pop(context);
                                        AppProvider appProvider =
                                            Provider.of<AppProvider>(context,
                                                listen: false);

                                        appProvider.saveAppoitmentInfo({
                                          "TicketTypeId": 1,
                                          "date": DateTime.now(),
                                          "time": "After 30 - 120 minutes",
                                          "services": serviceId,
                                          "totalPrice": totalPrice,
                                          "totalTickets": totalTickets,
                                          "gender": "Male",
                                        });
                                        Navigator.push(
                                          context,
                                          downToTop(
                                              const UploadOptionsScreen()),
                                        );
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

  Widget _dateTimeContent(StateSetter setModalState) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            // Date Selection
            CalenderWidget(),
            const SizedBox(height: 20),
            // Time Selection
            SizedBox(
              height: AppSize(context).height * .05,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: times.length,
                itemBuilder: (context, index) {
                  final time = times[index];
                  final isSelected = time == selectedTime;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => selectedTime = time);
                      setState(() {}); // ✅ Reflect changes outside the sheet
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors(context).primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.whiteColor1
                              : AppColors.blackColor1,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
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
            title: AppText(context, isFunction: true).continuesss,
            onTap: () {
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
            },
          ),
        ),
        // Continue Button
      ],
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
