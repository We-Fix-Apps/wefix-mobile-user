import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/time_appointment_model.dart';

import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/calender_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/tab_indecator.dart';
import 'package:wefix/layout_screen.dart';

class DateTimeWidget extends StatefulWidget {
  final String? date;
  final String? time;
  final GlobalKey? dateKey;
  final GlobalKey? featureKey;

  const DateTimeWidget(
      {super.key, this.date, this.time, this.dateKey, this.featureKey});

  @override
  State<DateTimeWidget> createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  // List<String> times = [
  //   "04:00 - 06:00 PM",
  //   "05:00 - 06:00 PM",
  //   "06:00 - 08:00 PM",
  //   "07:00 - 09:00 PM"
  // ];
  double? totalPrice;
  List<int>? services;
  bool selectedGenderMale = true;
  bool selectedGenderFeMale = true;
  int selectedDate = 25;
  String? selectedTime;

  String selectedTab = "Later";
  bool? isAddedd = false;
  bool? isFemale = false;
  TimeAppoitmentModel? timeAppoitmentModel;

  bool? loading5 = false;
  bool? loadingTime = false;

  SubsicripeModel? subsicripeModel;

  @override
  void initState() {
    // TODO: implement initState
    isSubsicribed();
    getTime();
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    selectedTime = appProvider.appoitmentInfo["time"];
    setState(() {
      isFemale =
          appProvider.appoitmentInfo["gender"] == "Female" ? true : false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🕓 ${AppText(context).dateTime}",
          style: TextStyle(
            fontSize: AppSize(context).smallText1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              key: widget.dateKey,
              width: AppSize(context).width,
              height: AppSize(context).height * .07,
              decoration: BoxDecoration(
                  color: AppColors.whiteColor1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.greyColor1)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${(() {
                        final dateValue = appProvider.appoitmentInfo["date"];
                        if (dateValue == null) return '';
                        if (dateValue is DateTime) {
                          return DateFormat('yyyy-MM-dd').format(dateValue);
                        }
                        final dateStr = dateValue.toString();
                        try {
                          final parsedDate = DateTime.parse(dateStr);
                          return DateFormat('yyyy-MM-dd').format(parsedDate);
                        } catch (e) {
                          return dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
                        }
                      })()} - ${appProvider.appoitmentInfo["time"] ?? ''}",
                      style: TextStyle(fontSize: AppSize(context).smallText2),
                    ),
                    appProvider.appoitmentInfo["TicketTypeId"] == 1
                        ? const SizedBox()
                        : TextButton(
                            onPressed: () {
                              showBottomSheetFun();
                            },
                            child: Text(
                              AppText(context).change,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors(context).primaryColor),
                            ))
                  ],
                ),
              )),
        ),
        const SizedBox(
          height: 5,
        ),
        appProvider.userModel?.customer.roleId == 2
            ? SizedBox()
            : const Divider(
                color: AppColors.backgroundColor,
              ),
        appProvider.userModel?.customer.roleId == 2
            ? SizedBox()
            : Container(
                key: widget.featureKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "👨‍🔧 ${AppText(context).technicianGender}",
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          message:
                              ((subsicripeModel?.numberOnFemalUse ?? 0) > 0)
                                  ? AppText(context).youwillbechargedTicketextra
                                  : AppText(context).youwillbecharged10JODextra,
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.greyColor1,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SwitchListTile.adaptive(
                        activeColor: AppColors(context).primaryColor,
                        secondary: Image.asset(
                          "assets/image/Layer 12.png",
                          height: AppSize(context).height * .05,
                          width: AppSize(context).width * .1,
                        ),
                        title: Text(
                          AppText(context).needafemaletechnicianforsupport,
                          style: TextStyle(
                            fontSize: AppSize(context).smallText2,
                          ),
                        ),
                        subtitle: Text(
                          ((subsicripeModel?.numberOnFemalUse ?? 0) > 0)
                              ? AppText(context).youwillbechargedTicketextra
                              : AppText(context).youwillbecharged10JODextra,
                          style: TextStyle(
                            fontSize: AppSize(context).smallText3,
                            color: AppColors.greyColor2,
                          ),
                        ),
                        inactiveThumbColor: AppColors.whiteColor1,
                        inactiveTrackColor: AppColors.greyColor1,
                        overlayColor: MaterialStateProperty.all(
                          AppColors(context).primaryColor.withOpacity(.2),
                        ),
                        value: isFemale ?? false,
                        onChanged: (value) {
                          // if (subsicripeModel?.status == true) {
                          //   if ((subsicripeModel?.numberOnFemalUse ?? 0) <= 0) {
                          //     showUpgradeDialog(context);
                          //   } else {
                          //     setState(() {
                          //       isFemale = value;
                          //       appProvider.saveAppoitmentInfo({
                          //         "TicketTypeId":
                          //             appProvider.appoitmentInfo["TicketTypeId"],
                          //         "gender": isFemale == false ? "Male" : "Female",
                          //         "date": appProvider.selectedDate ?? DateTime.now(),
                          //         "time":
                          //             selectedTime ?? appProvider.appoitmentInfo["time"],
                          //         "services":
                          //             services ?? appProvider.appoitmentInfo["services"],
                          //         "totalPrice": totalPrice ??
                          //             appProvider.appoitmentInfo["totalPrice"],
                          //         "totalTickets": appProvider.appoitmentInfo["totalTickets"]
                          //       });

                          //       log(appProvider.appoitmentInfo.toString());
                          //     });
                          //   }
                          // }

                          setState(() {
                            isFemale = value;
                            appProvider.saveAppoitmentInfo({
                              "TicketTypeId":
                                  appProvider.appoitmentInfo["TicketTypeId"],
                              "gender": isFemale == false ? "Male" : "Female",
                              "date":
                                  appProvider.selectedDate ?? DateTime.now(),
                              "time": selectedTime ??
                                  appProvider.appoitmentInfo["time"],
                              "services": services ??
                                  appProvider.appoitmentInfo["services"],
                              "totalPrice": totalPrice ??
                                  appProvider.appoitmentInfo["totalPrice"],
                              "totalTickets":
                                  appProvider.appoitmentInfo["totalTickets"]
                            });

                            log(appProvider.appoitmentInfo.toString());
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )

        // Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: CheckboxListTile(
        //       // fillColor: MaterialStateProperty.all(
        //       //   AppColors(context).primaryColor,
        //       // ),
        //       activeColor: AppColors(context).primaryColor,
        //       checkColor: AppColors.whiteColor1,
        //       value: isFemale,

        //       secondary: Image.asset(
        //         "assets/image/Layer 12.png",
        //         height: AppSize(context).height * .05,
        //         width: AppSize(context).width * .1,
        //       ),
        //       title: Text(
        //         AppText(context).needafemaletechnicianforsupport,
        //         style: TextStyle(
        //           fontSize: AppSize(context).smallText2,
        //         ),
        //       ),
        //       onChanged: (value) {
        //         setState(() {
        //           isFemale = value;
        //           appProvider.saveAppoitmentInfo({
        //             "TicketTypeId": appProvider.appoitmentInfo["TicketTypeId"],
        //             "gender": isFemale == false ? "Male" : "Female",
        //             "date": appProvider.selectedDate ?? DateTime.now(),
        //             "time": selectedTime ?? appProvider.appoitmentInfo["time"],
        //             "services":
        //                 services ?? appProvider.appoitmentInfo["services"],
        //             "totalPrice":
        //                 totalPrice ?? appProvider.appoitmentInfo["totalPrice"],
        //           });

        //           log(appProvider.appoitmentInfo.toString());
        //         });
        //       },
        //     )),
        ,
        const SizedBox(
          height: 5,
        ),
      ],
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
                            downToTop(const HomeLayout(
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                        AppText(context, isFunction: true)
                                              .estimatedTimeToArrivalminutes,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors(context)
                                                  .primaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: AppColors(context)
                                                    .primaryColor,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '90 - 120 ${AppText(context).minutes}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CustomBotton(
                                      title: AppText(context, isFunction: true)
                                          .continuesss,
                                      onTap: () {
                                        // Set Emergency time when continuing
                                        AppProvider appProvider =
                                            Provider.of<AppProvider>(context,
                                                listen: false);
                                        appProvider.saveAppoitmentInfo({
                                          "TicketTypeId":
                                              appProvider.appoitmentInfo[
                                                  "TicketTypeId"],
                                          "gender": isFemale == false
                                              ? "Male"
                                              : "Female",
                                          "date": appProvider.selectedDate ??
                                              DateTime.now(),
                                          "time": "After 90 - 120 minutes",
                                          "services": services ??
                                              appProvider.appoitmentInfo[
                                                  "services"],
                                          "totalPrice": totalPrice ??
                                              appProvider.appoitmentInfo[
                                                  "totalPrice"],
                                          "totalTickets":
                                              appProvider.appoitmentInfo[
                                                  "totalTickets"]
                                        });
                                        Navigator.pop(context);
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

  Future getTime() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    setState(() {
      loadingTime = true;
    });

    final selectedDateStr = appProvider.selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(appProvider.selectedDate!)
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

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

  Widget _dateTimeContent(StateSetter setModalState) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Column(
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
                        final timeItem = timeAppoitmentModel?.timesList[index];
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
                              margin: const EdgeInsets.symmetric(horizontal: 6),
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
            title: AppText(context, isFunction: true).continuesss,
            onTap: () {
              setState(() {
                appProvider.saveAppoitmentInfo({
                  "TicketTypeId": appProvider.appoitmentInfo["TicketTypeId"],
                  "gender": selectedGenderFeMale == true ? "Male" : "Female",
                  "date": appProvider.selectedDate ?? DateTime.now(),
                  "time": selectedTime ?? appProvider.appoitmentInfo["time"],
                  "services":
                      services ?? appProvider.appoitmentInfo["services"],
                  "totalPrice":
                      totalPrice ?? appProvider.appoitmentInfo["totalPrice"],
                });
              });
              log(appProvider.appoitmentInfo.toString());
              pop(context);
            },
          ),
        ),
        // Continue Button
      ],
    );
  }

  maleOrFemail() {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

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
                          setState(() {
                            selectedGenderMale = true;
                            selectedGenderFeMale = false;
                          });
                        },
                        child: Banner(
                          message: "+10 JOD",
                          location: BannerLocation.topEnd,
                          color: AppColors(context).primaryColor,
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
                      ),
                      InkWell(
                        onTap: () {
                          set(() {
                            selectedGenderFeMale = true;
                            selectedGenderMale = false;
                          });

                          setState(() {
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
                        setState(() {
                          appProvider.saveAppoitmentInfo({
                            "TicketTypeId":
                                appProvider.appoitmentInfo["TicketTypeId"],
                            "gender": selectedGenderFeMale == true
                                ? "Male"
                                : "Female",
                            "date": appProvider.selectedDate ?? DateTime.now(),
                            "time": selectedTime ??
                                appProvider.appoitmentInfo["time"],
                            "services": services ??
                                appProvider.appoitmentInfo["services"],
                            "totalPrice": totalPrice ??
                                appProvider.appoitmentInfo["totalPrice"],
                          });
                        });
                        log(appProvider.appoitmentInfo.toString());

                        pop(context);
                      }),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
