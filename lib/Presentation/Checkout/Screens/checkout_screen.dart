import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/CreateOrder/create_order_api.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/appitment_model.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Presentation/Address/Screens/address_screen.dart';
import 'package:wefix/Presentation/Components/google_calender.dart';
import 'package:wefix/Presentation/Components/tour_widget.dart';
import 'package:wefix/Presentation/Profile/Components/usage_details_widget.dart';
import 'package:wefix/Presentation/appointment/Components/location_map_widget.dart';
import 'package:wefix/Presentation/Checkout/Components/coboun_widget.dart';
import 'package:wefix/Presentation/Checkout/Components/payment_summary_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/layout_screen.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:wefix/main.dart';

// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   clientId:
//       "167167966746-njsoq8k438u5q6015bkpaahsbmbl0onk.apps.googleusercontent.com",
//   scopes: [
//     'email',
//     'https://www.googleapis.com/auth/calendar',
//     'https://www.googleapis.com/auth/calendar.events',
//   ],
// );

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Placemark> placemarks = [];
  final List<GlobalKey<State<StatefulWidget>>> keyButton = [
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
    GlobalKey<State<StatefulWidget>>(),
  ];

  List<Map> content = [
    {
      "title": AppText(navigatorKey.currentState!.context).changeLocation,
      "description": AppText(navigatorKey.currentState!.context).changeLocationDescription,
      "isTop": false
    },
    {
      "title": AppText(navigatorKey.currentState!.context).getDiscount,
      "description": AppText(navigatorKey.currentState!.context).getDiscountDescription,
      "image": "assets/images/discountshape.svg",
      "isTop": false
    },
    {
      "title": AppText(navigatorKey.currentState!.context).paymentSummary,
      "description": AppText(navigatorKey.currentState!.context).paymentSummaryDescription,
      "image": "assets/images/lump-sum-payment-rgb-color-icon-vector.jpg",
      "isTop": true
    },
    {
      "title": AppText(navigatorKey.currentState!.context).placeOrderAndChoosePaymentMethod,
      "description": AppText(navigatorKey.currentState!.context).placeOrderAndChoosePaymentMethodDescription,
      "image": "assets/image/cont.png",
      "isTop": true
    }
  ];

  @override
  void initState() {
    // googleSignIn?.signOut();
    AppProvider appProvider = Provider.of(context, listen: false);
    setState(() {
      isFemale = appProvider.appoitmentInfo["gender"] == "Female" ? true : false;
    });

    // try {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     CustomeTutorialCoachMark.createTutorial(keyButton, content);
    //     Future.delayed(const Duration(seconds: 1), () {
    //       Map showTour =
    //           json.decode(CacheHelper.getData(key: CacheHelper.showTour));
    //       CustomeTutorialCoachMark.showTutorial(context,
    //           isShow: showTour["checkout"] ?? true);
    //       setState(() {
    //         showTour["checkout"] = false;
    //       });
    //       CacheHelper.saveData(
    //           key: CacheHelper.showTour, value: json.encode(showTour));
    //       log(showTour.toString());
    //     });
    //   });
    // } catch (e) {
    //   log(e.toString());
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomeTutorialCoachMark.createTutorial(keyButton, content);
      Future.delayed(const Duration(seconds: 1), () {
        CustomeTutorialCoachMark.showTutorial(context, isShow: true);
      });
    });
    isSubsicribed(
      isfromPlaceOreder: false,
    );
    super.initState();
  }

  bool loading = false;
  bool loading2 = false;
  bool loading3 = false;
  bool loading5 = false;
  bool? isFemale;

  // bool? isSubsicribe;
  SubsicripeModel? subsicripeModel;
  AppointmentModel? appointmentModel;

  String selectedPayment = 'visa';
  double? discountAmount;
  double? totalafterDiscount;
  double? totalDiscountAmount;

  static GoogleSignIn? googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      // 'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );
  static GoogleSignInAccount? user;

  TextEditingController promoCodeController = TextEditingController();

  signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn!.signIn();
      if (googleUser == null) return;
      user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseAuth.instance.signInWithCredential(credential);
      print("✅ Logged in: ${user?.email}");
      return user;
    } catch (e) {
      print("❌ Sign-in error: $e");
    }
  }

  Future<void> addAppointmentToGoogleCalendar({
    required String date, // e.g. "2025-07-27"
    required String time, // e.g. "8:00 - 10:00 AM"
    String? address,
    String? serviceName,
  }) async {
    final user = await signInWithGoogle();
    if (user == null) {
      print("❌ Google sign-in failed");
      return;
    }

    final authHeaders = await user.authHeaders;
    if (authHeaders == null) {
      print("❌ Auth headers are null — missing scopes?");
      return;
    }

    // Parse the date part
    final DateTime dateOnly = DateTime.parse(date); // 2025-07-27

    // Define fixed slot mapping
    final Map<String, List<TimeOfDay>> timeSlots = {
      "08:00 - 10:00 AM": [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 10, minute: 0)],
      "After 90 - 120 minutes": [
        TimeOfDay.now(),
        TimeOfDay.now(),
      ],
      "10:00 - 12:00 AM": [const TimeOfDay(hour: 10, minute: 0), const TimeOfDay(hour: 12, minute: 0)], // This is actually 10 AM to 12 PM

      "12:00 - 02:00 PM": [const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 14, minute: 0)],
      "02:00 - 04:00 PM": [const TimeOfDay(hour: 14, minute: 0), const TimeOfDay(hour: 16, minute: 0)],
      "04:00 - 06:00 PM": [const TimeOfDay(hour: 16, minute: 0), const TimeOfDay(hour: 18, minute: 0)],
    };

    if (!timeSlots.containsKey(time)) {
      print("❌ Unsupported time slot: $time");
      return;
    }

    final start = timeSlots[time]![0];
    final end = timeSlots[time]![1];

    final DateTime startDateTime = DateTime(dateOnly.year, dateOnly.month, dateOnly.day, start.hour, start.minute);
    final DateTime endDateTime = DateTime(dateOnly.year, dateOnly.month, dateOnly.day, end.hour, end.minute);

    final client = GoogleHttpClient(authHeaders);
    final calendarApi = calendar.CalendarApi(client);

    final event = calendar.Event(
      summary: 'Appointment with WeFix',
      colorId: "1",
      reminders: calendar.EventReminders(
        useDefault: false,
        overrides: [
          calendar.EventReminder(method: 'popup', minutes: 30),
          calendar.EventReminder(method: 'popup', minutes: 5),
        ],
      ),
      description: serviceName ?? 'Service Appointment',
      start: calendar.EventDateTime(
        dateTime: startDateTime,
        timeZone: 'Asia/Amman',
      ),
      end: calendar.EventDateTime(
        dateTime: endDateTime,
        timeZone: 'Asia/Amman',
      ),
    );

    try {
      await calendarApi.events.insert(event, "primary");
      print("✅ Appointment added to Google Calendar!");
    } catch (e) {
      print("❌ Failed to insert event: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${AppText(context).checkout}'),
        centerTitle: true,
        actions: const [
          LanguageButton(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          key: keyButton[3],
          child: CustomBotton(
            title: AppText(context).placeOrder,
            loading: loading,
            onTap: () {
              // addRequest();
              appProvider.userModel == null
                  ? showDialog(
                      context: context,
                      builder: (context) => WidgetDialog(
                            title: AppText(context, isFunction: true).warning,
                            desc: AppText(context, isFunction: true).pleaselogintocontinue,
                            isError: true,
                            bottonText: AppText(context, isFunction: true).login,
                            onTap: () => Navigator.push(
                              context,
                              downToTop(
                                const LoginScreen(),
                              ),
                            ),
                          ))
                  : subsicripeModel?.status == true
                      ? showConfirmAppointmentDialog(context, () {
                          addRequest();
                        })
                      : showPaymentMethod(context);
              log(appProvider.appoitmentInfo.toString());
              // showUpgradeDialog(context);
            },
          ),
        ),
      ),
      body: loading2 == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : loading5 == true
              ? LinearProgressIndicator(
                  color: AppColors(context).primaryColor,
                  backgroundColor: AppColors.secoundryColor,
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        SvgPicture.asset("assets/icon/background.svg"),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              key: keyButton[0],
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "📍 ${AppText(context).location}",
                                        style: TextStyle(
                                          fontSize: AppSize(context).smallText1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            final a = await Navigator.push(context, downToTop(const AddressScreen()));

                                            if (a) {
                                              makeLoadingFor2Seconds();
                                            }
                                          },
                                          child: Text(
                                            "${AppText(context).change}",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors(context).primaryColor),
                                          ))
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  WidgetAddressCheckout(
                                    addressNameStreet: "",
                                    lat: appProvider.currentLocation?.latitude.toString() ?? "",
                                    long: appProvider.currentLocation?.longitude.toString() ?? "",
                                    addressName: "",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            discountAmount != null
                                ? const SizedBox()
                                : subsicripeModel?.status == true
                                    ? const SizedBox()
                                    : Container(
                                        key: keyButton[1],
                                        child: CouponWidget(
                                          promoCodeController: promoCodeController,
                                          onTap: () {
                                            promoCode();
                                          },
                                          loading: loading3,
                                        ),
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
                                Tooltip(
                                  triggerMode: TooltipTriggerMode.tap,
                                  message: ((subsicripeModel?.numberOnFemalUse ?? 0) > 0)
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
                                  setState(() {
                                    isFemale = value;
                                    appProvider.saveAppoitmentInfo({
                                      "TicketTypeId": appProvider.appoitmentInfo["TicketTypeId"],
                                      "gender": isFemale == false ? "Male" : "Female",
                                      "date": appProvider.selectedDate ?? DateTime.now(),
                                      "time": appProvider.appoitmentInfo["time"],
                                      "services": appProvider.appoitmentInfo["services"],
                                      "totalPrice": appProvider.appoitmentInfo["totalPrice"],
                                      "totalTickets": appProvider.appoitmentInfo["totalTickets"]
                                    });

                                    log(appProvider.appoitmentInfo.toString());
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 24),
                            Container(
                              key: keyButton[2],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "🧾 ${AppText(context).paymentSum}",
                                    style: TextStyle(
                                      fontSize: AppSize(context).smallText1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  PaymentSummaryWidget(
                                      title: AppText(context).subTotal,
                                      value: ((subsicripeModel?.onDemandVisit ?? -1) > 0)
                                          ? " ${appProvider.appoitmentInfo["totalTickets"]} ${AppText(context).ticket}"
                                          : ' ${AppText(context).jod} ${appProvider.appoitmentInfo["totalPrice"]}'),
                                  discountAmount == null
                                      ? const SizedBox()
                                      : PaymentSummaryWidget(
                                          title: ' ${AppText(context).totalAfterDiscount} 🥳',
                                          value: '- ${AppText(context).jod} ${discountAmount?.toStringAsFixed(2)}',
                                          highlight: true),
                                  appProvider.appoitmentInfo["TicketTypeId"] == 1
                                      ? PaymentSummaryWidget(
                                          title: AppText(context).emergency,
                                          value:
                                              ((subsicripeModel?.emergancyVisit ?? -1) > 0) ? "1 ${AppText(context).ticket}" : ' ${AppText(context).jod} 10.00',
                                          highlight: false)
                                      : const SizedBox(),
                                  appProvider.appoitmentInfo["gender"] == "Male"
                                      ? const SizedBox()
                                      : PaymentSummaryWidget(
                                          title: 'Female WeFix',
                                          value: ((subsicripeModel?.status ?? false) && (subsicripeModel?.numberOnFemalUse ?? 0) > 0) == true
                                              ? "1 ${AppText(context).ticket}"
                                              : ' ${AppText(context).jod.toUpperCase()} 10.00',
                                          icon: Icons.info_outline),
                                  ((appProvider.advantages["totalPrice"] != null))
                                      ? appProvider.advantages["totalPrice"] == 0.0
                                          ? const SizedBox()
                                          : PaymentSummaryWidget(
                                              title: AppText(context).services,
                                              value: "${AppText(context).jod.toUpperCase()} ${appProvider.advantages["totalPrice"]}",
                                              highlight: false)
                                      : const SizedBox(),
                                  const SizedBox(height: 20),
                                  PaymentSummaryWidget(
                                    title: AppText(context).total,
                                    value: getPaymentSummaryValue(appProvider.appoitmentInfo, subsicripeModel, totalafterDiscount, context),
                                    bold: true,
                                  ),
                                  const SizedBox(height: 20),
                                  totalafterDiscount == null
                                      ? const SizedBox()
                                      : Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: AppColors(context).primaryColor.withOpacity(.2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors(context).primaryColor)),
                                          child: Row(
                                            children: [
                                              Text(
                                                "🎉",
                                                style: TextStyle(fontSize: AppSize(context).smallText1),
                                              ),
                                              Expanded(
                                                  child: Text(" Awesome! You're saving JOD ${discountAmount?.toStringAsFixed(2)}",
                                                      style: TextStyle(color: AppColors(context).primaryColor))),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),

                            appProvider.isMaterialFromProvider == false
                                ? const SizedBox()
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors(context).primaryColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      AppText(context, isFunction: true)
                                          .sincethematerialcostexceeds100JODanupfrontpaymentof50requiredWetouchwithyoutoconfirmthematerialprice,
                                      style: TextStyle(color: AppColors(context).primaryColor, fontWeight: FontWeight.w600),
                                    ),
                                  ),

                            const SizedBox(
                              height: 20,
                            ),

                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.redColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.redColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    // ✅ prevents overflow, allows wrapping
                                    child: Text(
                                      AppText(context).noteM,
                                      style: const TextStyle(
                                        color: AppColors.redColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // subsicripeModel?.status == false
                            //     ? SizedBox()
                            //     : Container(
                            //         padding: const EdgeInsets.all(12),
                            //         decoration: BoxDecoration(
                            //             color: AppColors(context)
                            //                 .primaryColor
                            //                 .withOpacity(.2),
                            //             borderRadius: BorderRadius.circular(8),
                            //             border: Border.all(
                            //                 color: AppColors(context)
                            //                     .primaryColor)),
                            //         child: Row(
                            //           children: [
                            //             Text(
                            //               "🎉",
                            //               style: TextStyle(
                            //                   fontSize:
                            //                       AppSize(context).smallText1),
                            //             ),
                            //             SizedBox(width: 5),
                            //             Expanded(
                            //                 child: Text(
                            //                     " Awesome! You're saving JOD ${appProvider.appoitmentInfo["totalPrice"]} , This appointment will use 1 ticket from your subscription. No additional payment is required",
                            //                     style: TextStyle(
                            //                         color: AppColors(context)
                            //                             .primaryColor))),
                            //           ],
                            //         ),
                            //       )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  String getPaymentSummaryValue(
    Map<dynamic, dynamic> appointmentInfo,
    SubsicripeModel? subsicripeModel,
    double? totalafterDiscount,
    BuildContext context,
  ) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    bool isSubscribed = subsicripeModel?.status == true;
    bool isFemale = appointmentInfo["gender"] == "Female";
    int numberOnFemaleUse = subsicripeModel?.numberOnFemalUse ?? 0;
    int emergencyVisit = subsicripeModel?.emergancyVisit ?? -1;
    int onDemandVisit = subsicripeModel?.onDemandVisit ?? 0;

    double advantageExtra = 0;
    double femaleExtra = 0;
    double emergencyExtra = 0;
    double onDemandPrice = 0;

    // Advantage price
    if (appProvider.advantages["totalPrice"] != null) {
      advantageExtra += double.tryParse(appProvider.advantages["totalPrice"].toString()) ?? 0;
    }

    // Female fee
    if (isFemale && numberOnFemaleUse <= 0) {
      femaleExtra = 10;
    }

    // Emergency fee (if subscribed only)
    if (emergencyVisit <= 0 && appointmentInfo["TicketTypeId"] == 1) {
      emergencyExtra = 10;
    }

    // On-demand logic: show price instead of ticket
    bool useOnDemandPrice = onDemandVisit <= 0;
    if (useOnDemandPrice) {
      onDemandPrice = appointmentInfo["totalPrice"] ?? 0;
    }

    double totalExtra = advantageExtra + femaleExtra + emergencyExtra;

    // Case: not subscribed
    if (!isSubscribed) {
      double basePrice = calculateTotalPrice(appointmentInfo, totalafterDiscount);

      // ✅ If not subscribed and ticket is emergency, add 10 JOD
      if (appointmentInfo["TicketTypeId"] == 1) {
        basePrice += 10;
      }

      double totalPrice = basePrice + advantageExtra;
      return "${AppText(context).jod} ${totalPrice.toStringAsFixed(2)}";
    }

    // ✅ New Case: requested tickets > onDemandVisit
    if (appointmentInfo["totalTickets"] > onDemandVisit) {
      int allowedTickets = onDemandVisit; // all tickets he has
      int extraTickets = appointmentInfo["totalTickets"] - onDemandVisit;

      // Price for extra tickets (you can change logic if price differs)
      double extraPrice = ((appointmentInfo["totalPrice"] ?? 0) / (appointmentInfo["totalTickets"])) * extraTickets;

      double finalPrice = extraPrice + totalExtra;

      if (finalPrice > 0) {
        return "$allowedTickets ${AppText(context).ticket} + ${AppText(context).jod} ${finalPrice.toStringAsFixed(2)}";
      } else {
        return "$allowedTickets ${AppText(context).ticket}";
      }
    }

    // Case: subscribed but on-demand is exhausted → show price + extras
    if (useOnDemandPrice) {
      double finalPrice = onDemandPrice + totalExtra;
      return "${AppText(context).jod} ${finalPrice.toStringAsFixed(2)}";
    }

    // Case: valid subscription with ticket + possible extras
    int ticketCount = calculateTotalTickets(appointmentInfo, subsicripeModel, isSubscribed);
    if (totalExtra > 0) {
      return "$ticketCount ${AppText(context).ticket} + ${AppText(context).jod} ${totalExtra.toStringAsFixed(2)}";
    }

    return "$ticketCount ${AppText(context).ticket}";
  }

  int calculateTotalTickets(
    Map<dynamic, dynamic> appointmentInfo,
    SubsicripeModel? subsicripeModel,
    bool isSubscribed,
  ) {
    int totalTickets = appointmentInfo["totalTickets"] ?? 0;

    if (appointmentInfo["gender"] == "Female" && (subsicripeModel?.numberOnFemalUse ?? 0) > 0) {
      totalTickets += 1;
    }

    if (isSubscribed && appointmentInfo["TicketTypeId"] == 1 && (subsicripeModel?.emergancyVisit ?? 0) > 0) {
      totalTickets += 1;
    }

    return totalTickets;
  }

  double calculateTotalPrice(Map<dynamic, dynamic> appointmentInfo, double? totalafterDiscount) {
    double basePrice = totalafterDiscount ?? (appointmentInfo["totalPrice"] ?? 0);

    if (appointmentInfo["gender"] == "Female") {
      basePrice += 10;
    }

    return basePrice;
  }

  makeLoadingFor2Seconds() {
    setState(() {
      loading2 = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        loading2 = false;
      });
    });
  }

  showPaymentMethod(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, set) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 10,
              children: [
                Center(
                  child: Text(
                    AppText(context, isFunction: true).selectPaymentMethods,
                    style: TextStyle(fontSize: AppSize(context).smallText1, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _paymentOption("visa", AppText(context, isFunction: true).visa, "assets/icon/bank-card_17727858.svg", set),
                _paymentOption("qlic", AppText(context, isFunction: true).cliq, "assets/icon/final_cliq_logo-02_1.svg", set),
                _paymentOption("wallet", AppText(context, isFunction: true).wallet, "assets/icon/wallet.svg", set),
                _paymentOption("Paybal", AppText(context, isFunction: true).paypal, "assets/icon/paybal.svg", set),
                _paymentOption("later", " ${AppText(context, isFunction: true).paylater}", "assets/icon/delay_3360328.svg", set),
                const Divider(),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    "assets/icon/verified.png",
                    width: 170,
                  ),
                ),
                CustomBotton(
                    title: AppText(context, isFunction: true).continuesss,
                    loading: loading,
                    onTap: () {
                      // set(() {
                      //   loading = true;
                      // });
                      showConfirmAppointmentDialog(context, () {
                        pop(context);
                        addRequest();
                      });
                      // isSubsicribed().then((value) {
                      //   set(() {
                      //     loading5 = false;
                      //   });
                      // });
                    }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _paymentOption(String value, String label, String icon, void Function(void Function()) localSetState) {
    final isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => localSetState(() => selectedPayment = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors(context).primaryColor.withOpacity(0.05) : AppColors.whiteColor1,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 30,
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: AppColors(context).primaryColor),
          ],
        ),
      ),
    );
  }

  void showUpgradeDialog(BuildContext context) {
    Navigator.pop(context);
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
                AppText(context, isFunction: true).subscribenowandsave50JODDonmissoutonthisspecialoffer,
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
                        Navigator.pushAndRemoveUntil(context, downToTop(const HomeLayout()), (route) => false);
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

  Future addRequest() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    // --- Extras ---
    double advantageExtra = double.tryParse(appProvider.advantages["totalPrice"]?.toString() ?? "0") ?? 0;

    bool isFemale = appProvider.appoitmentInfo["gender"] == "Female";
    int numberOnFemaleUse = subsicripeModel?.numberOnFemalUse ?? 0;
    int? emergencyVisit = subsicripeModel?.emergancyVisit;
    int onDemandVisit = subsicripeModel?.onDemandVisit ?? 0;

    bool isSubscribed = subsicripeModel?.status == true;

    double femaleExtra = (isFemale && numberOnFemaleUse <= 0) ? 10 : 0;
    double emergencyExtra = ((emergencyVisit ?? 0) <= 0 && emergencyVisit != null) ? 10 : 0;
    bool useOnDemandPrice = onDemandVisit <= 0;

    // --- Base price ---
    double basePrice = totalafterDiscount ?? (appProvider.appoitmentInfo["totalPrice"] ?? 0).toDouble();

    double totalPrice = basePrice + advantageExtra + femaleExtra + emergencyExtra;

    // --- Tickets ---
    int numberOfTickets = 1;
    int requestedTickets = appProvider.appoitmentInfo["totalTickets"] ?? 0;

    if (isSubscribed && !useOnDemandPrice) {
      // ✅ Handle case: requested tickets > onDemandVisit
      if (requestedTickets > onDemandVisit) {
        int allowedTickets = onDemandVisit;
        int extraTickets = requestedTickets - onDemandVisit;

        // safer price per ticket
        double pricePerTicket = requestedTickets > 0 ? basePrice / requestedTickets : 0;

        double extraPrice = pricePerTicket * extraTickets;
        totalPrice += extraPrice;

        numberOfTickets = allowedTickets; // only allowed tickets sent
      } else {
        numberOfTickets = calculateTotalTickets(
          appProvider.appoitmentInfo,
          subsicripeModel,
          isSubscribed,
        );
      }
    } else if (useOnDemandPrice) {
      numberOfTickets = 0; // or skip sending if your API expects null/empty
    }

    // --- Payload ---
    Map<String, dynamic> data = {
      "TicketTypeId": appProvider.appoitmentInfo["TicketTypeId"],
      "PromoCode": promoCodeController.text,
      "SelectedDate": appProvider.appoitmentInfo["date"].toString().substring(0, 10),
      "SelectedDateTime": appProvider.appoitmentInfo["time"],
      "Description": appProvider.desc.text,
      "Location":
          "${appProvider.places![0].country} ,${appProvider.places![0].locality}, ${appProvider.places![0].name}, ${appProvider.places![0].subAdministrativeArea} ,${appProvider.places![0].subLocality}",
      "Longitude": appProvider.currentLocation?.longitude.toString() ?? "",
      "Latitude": appProvider.currentLocation?.latitude.toString() ?? "",
      "IsWithFemale": isFemale,
      "IsWithMaterial": appProvider.isMaterialFromProvider,
      "CustomerPackageId": subsicripeModel?.objSubscribe?.id,
      "TotalPrice": totalPrice, // ✅ always includes extras
      "ServiceTicket": appProvider.appoitmentInfo["services"],
      "Attachments": appProvider.attachments,
      "RealEstateId": appProvider.realStateId ?? 0,
      "NumberOfTicket": numberOfTickets,
      "AdvantageTicket": appProvider.advantages["advantages"] ?? [],
      "DiscountAmount": totalDiscountAmount ?? 0,
    };

    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    await CreateOrderApi.requestService(
      token: '${appProvider.userModel?.token}',
      data: data,
    ).then((value) {
      appointmentModel = value;
      log(promoCodeController.text);
      appProvider.clearRealState();
      appProvider.deleteAdv();
      addAppointmentToGoogleCalendar(
        date: appProvider.appoitmentInfo["date"].toString().substring(0, 10),
        time: appProvider.appoitmentInfo["time"],
      );

      subsicripeModel?.status == false
          ? showDialog(
              context: context,
              builder: (context) {
                return WidgetDialog(
                  title: AppText(context).successfully,
                  desc: AppText(context).orderSentSuccessfully,
                  isError: false,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, downToTop(const HomeLayout()), (route) => false);
                  },
                );
              },
            )
          : showModalBottomSheet(
              context: context,
              isDismissible: false,
              isScrollControlled: true,
              builder: (context) {
                return SizedBox(
                  width: AppSize(context).width,
                  height: AppSize(context).height * .7,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SvgPicture.asset("assets/icon/success.svg"),
                        const SizedBox(height: 10),
                        Text(
                          AppText(context).orderSentSuccessfully,
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        UsageDetailsWidget(
                            title: AppText(context).recurringVisits,
                            value: appointmentModel?.customerPackages.recurringVist ?? 0,
                            total: appointmentModel?.customerPackages.totalRecurringVist ?? 0,
                            color: Colors.green),
                        UsageDetailsWidget(
                            title: AppText(context).ondemandVisits,
                            value: appointmentModel?.customerPackages.onDemandVisit ?? 0,
                            total: appointmentModel?.customerPackages.totalOnDemandVisit ?? 0,
                            color: Colors.red),
                        UsageDetailsWidget(
                            title: AppText(context).emergencyVisits,
                            value: appointmentModel?.customerPackages.emeregencyVisit ?? 0,
                            total: appointmentModel?.customerPackages.totalEmeregencyVisit ?? 0,
                            color: Colors.orange),
                        UsageDetailsWidget(
                            title: AppText(context).femaleUse,
                            value: appointmentModel?.customerPackages.numberOnFemalUse ?? 0,
                            total: appointmentModel?.customerPackages.totalNumberOnFemalUse ?? 0,
                            color: Colors.purple),
                        UsageDetailsWidget(
                            title: AppText(context).consultations,
                            value: appointmentModel?.customerPackages.conultation ?? 0,
                            total: appointmentModel?.customerPackages.totalConultation ?? 0,
                            color: Colors.blue),
                        UsageDetailsWidget(
                            title: AppText(context).interiorDesign,
                            value: appointmentModel?.customerPackages.interiorDesign ?? 0,
                            total: appointmentModel?.customerPackages.totalInteriorDesign ?? 0,
                            color: Colors.pink),
                        const Spacer(),
                        CustomBotton(
                          title: AppText(context).back,
                          onTap: () {
                            Navigator.pushAndRemoveUntil(context, downToTop(const HomeLayout()), (route) => false);
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            );

      if (value == false) {
        setState(() {
          loading = false;
        });
      } else {
        setState(() {});
        loading = false;
      }
    });
  }

  Future isSubsicribed({isfromPlaceOreder = true}) async {
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
        if (isfromPlaceOreder) {
          addRequest();
        }
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

  Future promoCode() async {
    setState(() {
      loading3 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ProfileApis.promoCode(
        code: promoCodeController.text,
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        setState(() {
          if (value["status"] == true) {
            discountAmount = (appProvider.appoitmentInfo["totalPrice"] * (double.parse(value["percantage"].toString()) / 100));
            totalafterDiscount =
                appProvider.appoitmentInfo["totalPrice"] - (appProvider.appoitmentInfo["totalPrice"] * (double.parse(value["percantage"].toString()) / 100));
            totalDiscountAmount = appProvider.appoitmentInfo["totalPrice"] - totalafterDiscount!;

            const snackBar = SnackBar(
              content: Text('Your promo code has been applied successfully'),
            );
            log("Total discount: $totalDiscountAmount");

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            const snackBar = SnackBar(
              content: Text('The promo code you entered is not valid.'),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          loading3 = false;
        });
        log(value.toString());
      });
    } catch (e) {
      log('promoCode $e');
      setState(() {
        loading3 = false;
      });
    }
  }

  void showConfirmAppointmentDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.whiteColor1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: AppColors(context).primaryColor),
                const SizedBox(height: 16),
                Text(
                  AppText(context, isFunction: true).confirmAppointment,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  AppText(context, isFunction: true).confirmm,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: CustomBotton(
                      title: AppText(context, isFunction: true).no,
                      textColor: AppColors(context).primaryColor,
                      onTap: () {
                        pop(context);
                      },
                      color: Colors.transparent,
                      borderColor: AppColors.greyColor1,
                      border: true,
                      height: AppSize(context).height * .05,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomBotton(
                        title: AppText(context, isFunction: true).confirm,
                        height: AppSize(context).height * .05,
                        radius: 12,
                        onTap: () {
                          pop(context);
                          onConfirm();
                        },
                        loading: loading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   clientId:
//       '1077927200941-bkg5gbdo53o35gmmrh7fthgao26rs3g3.apps.googleusercontent.com',
//   scopes: ['https://www.googleapis.com/auth/calendar'],
// );
