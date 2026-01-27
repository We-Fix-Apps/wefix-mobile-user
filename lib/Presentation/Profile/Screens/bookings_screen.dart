import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/ticket_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Profile/Components/rating_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Map<String, dynamic>> bookings = [
    {'status': 'Accepted', 'color': Colors.blue},
    {'status': 'Pending', 'color': Colors.orange},
    {'status': 'Rejected', 'color': Colors.red},
    {'status': 'Completed', 'color': Colors.green},
  ];

  bool? loading = false;
  bool? loading2 = false;

  TicketModel? ticketModel;

  @override
  void initState() {
    // TODO: implement initState

    getBookingHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).bookings),
        centerTitle: true,
        actions: const [
          LanguageButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => getBookingHistory(),
        child: loading == true
            ? LinearProgressIndicator(
                color: AppColors(context).primaryColor,
                backgroundColor: AppColors.secoundryColor,
              )
            : ((ticketModel?.tickets.isEmpty ?? true) || (ticketModel == null))
                ? const EmptyScreen()
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: ticketModel?.tickets.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              rightToLeft(TicketDetailsScreen(
                                id: ticketModel?.tickets[index].id.toString() ??
                                    "0",
                              )));
                        },
                        child: BookingCard(
                          onValue: () {
                            getBookingHistory();
                          },
                          loading2: loading2 ?? false,
                          onTapCancle: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return WidgetDialog(
                                    title: AppText(context).warning,
                                    bottonText: AppText(context).yes,
                                    onTap: () {
                                      Navigator.pop(context);
                                      cancelBooking(
                                              id: ticketModel
                                                  ?.tickets[index].id)
                                          .then((value) {
                                        getBookingHistory();
                                      });
                                    },
                                    desc:
                                        "Are you sure you want to cancel the appointment ? ",
                                    isError: true);
                              },
                            );
                          },
                          ticket: ticketModel?.tickets[index],
                          status:
                              ticketModel?.tickets[index].status ?? "Pending",
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future getBookingHistory() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.getBookingsHistory(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          ticketModel = value;
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

  Future cancelBooking({int? id}) async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.cancleBooking(
              token: appProvider.userModel?.token ?? "", id: id)
          .then((value) {
        setState(() {
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
}

class BookingCard extends StatefulWidget {
  final String status;
  final bool loading2;

  final Function()? onTapCancle;
  Function? onValue;
  final Ticket? ticket;
  BookingCard(
      {super.key, required this.status,
      this.ticket,
      this.onValue,
      this.onTapCancle,
      required this.loading2});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.backgroundColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "# ${widget.ticket?.id.toString() ?? "123456"}",
                    style: const TextStyle(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.status == "Completed"
                          ? AppColors.greenColor.withOpacity(.2)
                          : widget.status == "Canceled"
                              ? AppColors.redColor.withOpacity(.2)
                              : widget.status == "Pending"
                                  ? AppColors(context)
                                      .primaryColor
                                      .withOpacity(.2)
                                  : AppColors.blueColor.withOpacity(.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      languageProvider.lang == "ar"
                          ? widget.ticket?.statusAr ?? ""
                          : widget.ticket?.status ?? "",
                      style: TextStyle(
                          color: widget.status == "Completed"
                              ? AppColors.greenColor
                              : widget.status == "Canceled"
                                  ? AppColors.redColor
                                  : widget.status == "Pending"
                                      ? AppColors(context).primaryColor
                                      : AppColors.blueColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.lang == "ar"
                    ? widget.ticket?.descriptionAr ??
                        AppText(context).preventivemaintenancevisit
                    : widget.ticket?.description ??
                        AppText(context).preventivemaintenancevisit,
                style: TextStyle(
                    fontSize: AppSize(context).mediumText3,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                      '${widget.ticket?.selectedDate.toString().substring(0, 10)} , ${widget.ticket?.selectedDateTime}',
                      style: TextStyle(
                          fontSize: AppSize(context).smallText3,
                          fontWeight: FontWeight.normal)),
                  const Spacer(),
                  widget.ticket?.ticketTypeId == 4
                      ? const SizedBox()
                      : Text(
                          '${widget.ticket?.totalPrice} ${AppText(context).jod}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize(context).smallText1),
                        ),
                ],
              ),
              const SizedBox(height: 10),
              widget.status == "Rejected"
                  ? const SizedBox()
                  : const Divider(color: AppColors.greyColorback),
              if (widget.status == 'Accepted' || widget.status == 'Completed')
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.backgroundColor,
                      child: widget.ticket?.serviceprovideImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: WidgetCachNetworkImage(
                                  image:
                                      widget.ticket?.serviceprovideImage ?? ""),
                            )
                          : SvgPicture.asset(
                              "assets/icon/smile.svg",
                              color: AppColors(context).primaryColor,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ticket?.serviceprovide ?? "Service Provider",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset('assets/icon/favorite.svg'),
                            Text(' ${widget.ticket?.rating ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (widget.status == 'Completed')
                      widget.ticket?.isRated == true
                          ? const SizedBox()
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: CustomBotton(
                                  height: AppSize(context).height * .04,
                                  width: AppSize(context).width * .15,
                                  title: AppText(context).rate,
                                  border: true,
                                  borderColor: AppColors(context).primaryColor,
                                  color: AppColors.whiteColor1,
                                  textColor: AppColors(context).primaryColor,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      isScrollControlled: true,
                                      builder: (context) => RatingModal(
                                        id: widget.ticket?.id ?? 0,
                                        isRated:
                                            widget.ticket?.isRated ?? false,
                                      ),
                                    ).whenComplete(() {
                                      widget.onValue!();
                                    });
                                  },
                                ),
                              ),
                            ),
                  ],
                ),
              if (widget.status == 'Pending')
                widget.ticket?.cancelButton == true
                    ? const SizedBox()
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CustomBotton(
                            loading: widget.loading2,
                            height: AppSize(context).height * .04,
                            title: AppText(context).cancelBooking,
                            border: true,
                            borderColor: AppColors.redColor,
                            color: AppColors.whiteColor1,
                            textColor: AppColors.redColor,
                            onTap: widget.onTapCancle,
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
