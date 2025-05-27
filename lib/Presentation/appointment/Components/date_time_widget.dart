import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/appointment/Screens/appointment_details_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart';
import 'package:wefix/Presentation/SubCategory/Components/calender_widget.dart';

class DateTimeWidget extends StatefulWidget {
  final String? date;
  final String? time;

  const DateTimeWidget({super.key, this.date, this.time});

  @override
  State<DateTimeWidget> createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  List<String> times = [
    "04:00 - 06:00 PM",
    "05:00 - 06:00 PM",
    "06:00 - 08:00 PM",
    "07:00 - 09:00 PM"
  ];
  double? totalPrice;
  List<int>? services;
  bool selectedGenderMale = true;
  bool selectedGenderFeMale = true;
  int selectedDate = 25;
  String? selectedTime;

  String selectedTab = "Later";
  bool? isAddedd = false;
  bool? isFemale = false;

  @override
  void initState() {
    // TODO: implement initState
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
              width: AppSize(context).width,
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
                      "${appProvider.appoitmentInfo["date"].toString().substring(0, 10)} - ${appProvider.appoitmentInfo["time"]}",
                      style: TextStyle(fontSize: AppSize(context).smallText2),
                    ),
                    TextButton(
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
        const Divider(
          color: AppColors.backgroundColor,
        ),
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
            const Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              message: "You will be charged 10 JOD extra",
              child: Icon(
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
              AppText(context).youwillbecharged10JODextra,
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
              setState(() {
                isFemale = value;
                appProvider.saveAppoitmentInfo({
                  "TicketTypeId": appProvider.appoitmentInfo["TicketTypeId"],
                  "gender": isFemale == false ? "Male" : "Female",
                  "date": appProvider.selectedDate ?? DateTime.now(),
                  "time": selectedTime ?? appProvider.appoitmentInfo["time"],
                  "services":
                      services ?? appProvider.appoitmentInfo["services"],
                  "totalPrice":
                      totalPrice ?? appProvider.appoitmentInfo["totalPrice"],
                  "totalTickets": appProvider.appoitmentInfo["totalTickets"]
                });

                log(appProvider.appoitmentInfo.toString());
              });
            },
          ),
        ),
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
        const SizedBox(
          height: 5,
        ),
      ],
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
                                      '${AppText(context, isFunction: true).later}'),
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
            CalenderWidget(
              focusedDay: DateTime.tryParse("2025-05-28"),
              selectedDay: DateTime.tryParse("2025-05-28"),
            ),
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
