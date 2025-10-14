import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/color.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/bookings_screen.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';
import 'package:wefix/layout_screen.dart';

class B2BHome extends StatefulWidget {
  final SubsicripeModel? subsicripeModel;

  const B2BHome({super.key, this.subsicripeModel});

  @override
  State<B2BHome> createState() => _B2BHomeState();
}

class _B2BHomeState extends State<B2BHome> {
  bool? loading = false;
  TicketModel? ticketModel;

  @override
  void initState() {
    getBookingHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 20),
              _TicketSummarySection(subsicripeModel: widget.subsicripeModel),
              const SizedBox(height: 25),
              loading == true
                  ? LinearProgressIndicator(
                      backgroundColor: AppColors.secoundryColor,
                      color: AppColors(context).primaryColor,
                    )
                  : _LastTicketsSection(
                      ticketModel: ticketModel,
                    ),
              const SizedBox(height: 25),
              CustomBotton(
                title: "Add Ticket",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubServicesScreen(
                          title: "Add Ticket", catId: 0),
                    ),
                  );
                },
              ),
              SizedBox(height: 25),
            ],
          ),
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
}

// ---------------- Header ----------------
class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          radius: 24,
          child: Icon(Icons.business_center, color: Colors.orange.shade700),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello ${appProvider.userModel?.customer.name ?? ""}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.notifications_none_rounded, color: Colors.grey[600]),
      ],
    );
  }
}

// ---------------- Ticket Summary ----------------
class _TicketSummarySection extends StatefulWidget {
  final SubsicripeModel? subsicripeModel;

  const _TicketSummarySection({this.subsicripeModel});

  @override
  State<_TicketSummarySection> createState() => _TicketSummarySectionState();
}

class _TicketSummarySectionState extends State<_TicketSummarySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CorrectiveTicketCard(
          used: widget.subsicripeModel?.onDemandVisit.toString() ?? "0",
          total: widget.subsicripeModel?.objSubscribe?.onDemandVisit.toString(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _SmallTicketCard(
              title: "Preventive Tickets",
              imagePath: 'assets/icon/image copy 2.png',
              used: widget.subsicripeModel?.recurringVistUse.toString() ?? "0",
              total: widget.subsicripeModel?.objSubscribe?.recurringVist
                  .toString(),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _SmallTicketCard(
              title: "Emergency Tickets",
              imagePath: 'assets/icon/image.png',
              used: widget.subsicripeModel?.emergancyVisit.toString() ?? "0",
              total: widget.subsicripeModel?.objSubscribe?.emeregencyVisit
                  .toString(),
            )),
          ],
        ),
      ],
    );
  }
}

class _CorrectiveTicketCard extends StatefulWidget {
  final String? used;
  final String? total;

  const _CorrectiveTicketCard({super.key, this.used, this.total});

  @override
  State<_CorrectiveTicketCard> createState() => _CorrectiveTicketCardState();
}

class _CorrectiveTicketCardState extends State<_CorrectiveTicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/icon/image copy.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Corrective Tickets",
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 6,
                  percent: (() {
                    final used = double.tryParse(widget.used ?? "0") ?? 0;
                    final total = double.tryParse(widget.total ?? "1") ?? 1;
                    if (total == 0) return 0.0; // avoid division by zero
                    final ratio = used / total;
                    return ratio.clamp(0.0, 1.0); // ensure between 0 and 1
                  })(),
                  animation: true,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.4),
                  barRadius: const Radius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.used} / ${widget.total ?? 0}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _SmallTicketCard extends StatefulWidget {
  final String title;

  final String? used;
  final String? total;
  final String imagePath;

  const _SmallTicketCard(
      {required this.title, required this.imagePath, this.used, this.total});

  @override
  State<_SmallTicketCard> createState() => _SmallTicketCardState();
}

class _SmallTicketCardState extends State<_SmallTicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 7),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 6,
            animation: true,
            arcType: ArcType.HALF,
            percent: (() {
              final used = double.tryParse(widget.used ?? "0") ?? 0;
              final total = double.tryParse(widget.total ?? "1") ?? 1;
              if (total == 0) return 0.0; // avoid division by zero
              final ratio = used / total;
              return ratio.clamp(0.0, 1.0); // ensure between 0 and 1
            })(),
            arcBackgroundColor: Colors.grey.withOpacity(0.3),
            // startAngle: 270,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Theme.of(context).primaryColor,
            center: Text("${widget.used} / ${widget.total ?? 0}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ---------------- Last Tickets ----------------
class _LastTicketsSection extends StatelessWidget {
  final TicketModel? ticketModel;
  const _LastTicketsSection({this.ticketModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Last Tickets",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  rightToLeft(BookingScreen()),
                );
              },
              child: const Text("View All",
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: ((ticketModel?.tickets.length ?? 0) >= 3)
                ? 3
                : ticketModel?.tickets.length ?? 0,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsScreen(
                        id: ticketModel?.tickets[index].id.toString() ?? "",
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color:
                            AppColors(context).primaryColor.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    leading: ticketModel?.tickets[index].icon == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "assets/image/icon_logo.png",
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ))
                        : WidgetCachNetworkImage(
                            image: ticketModel?.tickets[index].icon ?? "",
                            width: 60,
                            height: 60,
                          ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#${ticketModel?.tickets[index].id}",
                          style: TextStyle(
                              fontSize: AppSize(context).smallText3,
                              color: AppColors(context).primaryColor),
                        ),
                        Text(
                            ticketModel?.tickets[index].description == null
                                ? AppText(context).preventivevisits
                                : ticketModel?.tickets[index].description ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppSize(context).smallText1)),
                      ],
                    ),
                    subtitle: Text(
                        DateFormat('MMM d, yyyy').format(
                            ticketModel?.tickets[index].selectedDate ??
                                DateTime.now()),
                        style: TextStyle(
                            fontSize: AppSize(context).smallText2,
                            color: Colors.grey[600])),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ticketModel?.tickets[index].status == "Pending"
                            ? AppColors(context).primaryColor.withOpacity(.2)
                            : ticketModel?.tickets[index].status == "Cancelled"
                                ? Colors.red.withOpacity(.2)
                                : Colors.green.withOpacity(.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticketModel?.tickets[index].status ?? "",
                        style: TextStyle(
                            color:
                                ticketModel?.tickets[index].status == "Pending"
                                    ? AppColors(context).primaryColor
                                    : ticketModel?.tickets[index].status ==
                                            "Cancelled"
                                        ? Colors.red
                                        : Colors.green,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ]),
      ],
    );
  }
}

// ---------------- Shortcuts ----------------
class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      {"icon": Icons.add_circle_outline, "label": "Add Ticket"},
      {"icon": Icons.attach_money, "label": "Subscriptions"},
      {"icon": Icons.account_tree, "label": "Add Branch"},
      {"icon": Icons.person_add_alt, "label": "Add Employee"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Shortcuts",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: shortcuts.map((s) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(s["icon"] as IconData,
                      color: Colors.orange, size: 28),
                ),
                const SizedBox(height: 6),
                Text(s["label"].toString(),
                    style: const TextStyle(fontSize: 13)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
