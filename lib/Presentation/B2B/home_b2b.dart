import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/bookings_screen.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';

class B2BHome extends StatefulWidget {
  final SubsicripeModel? subsicripeModel;

  const B2BHome({super.key, this.subsicripeModel});

  @override
  State<B2BHome> createState() => _B2BHomeState();
}

class _B2BHomeState extends State<B2BHome> {
  bool? loading = false;
  TicketModel? ticketModel;
  Map<String, dynamic>? ticketStatistics;

  @override
  void initState() {
    getCompanyTickets();
    getTicketStatistics();
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
              const SizedBox(height: 4),
              _TicketSummarySection(
                subsicripeModel: widget.subsicripeModel,
                ticketStatistics: ticketStatistics,
              ),
              const SizedBox(height: 10),
              loading == true
                  ? LinearProgressIndicator(
                      backgroundColor: AppColors.secoundryColor,
                      color: AppColors(context).primaryColor,
                    )
                  : _LastTicketsSection(
                      ticketModel: ticketModel,
                    ),
              const SizedBox(height: 4),
              CustomBotton(
                title: AppLocalizations.of(context)!.addTicket,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubServicesScreen(title: AppLocalizations.of(context)!.addTicket, catId: 0),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future getCompanyTickets() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      final ticketsData = await BookingApi.getCompanyTicketsFromMMS(
        token: appProvider.userModel?.token ?? "",
      );

      if (ticketsData != null) {
        // Convert MMS tickets format to TicketModel format
        final allTickets = ticketsData['all']?['tickets'] ?? [];
        final tickets = allTickets.map<Ticket>((ticket) {
          final ticketDate = ticket['ticketDate'] != null ? DateTime.parse(ticket['ticketDate']) : DateTime.now();

          return Ticket(
            id: ticket['id'] ?? 0,
            customerId: 0, // Not available from MMS
            statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
            ticketTypeId: ticket['ticketType']?['id'] ?? 0,
            rating: null,
            icon: null,
            cancelButton: null,
            isRated: null,
            type: ticket['ticketType']?['name'],
            serviceprovideImage: null,
            promoCode: null,
            requestedDate: ticketDate,
            selectedDate: ticketDate,
            selectedDateTime: ticket['ticketTimeFrom'] != null && ticket['ticketTimeTo'] != null ? '${ticket['ticketTimeFrom']} - ${ticket['ticketTimeTo']}' : null,
            timeFrom: ticket['ticketTimeFrom'],
            timeTo: ticket['ticketTimeTo'],
            teamNo: null,
            status: ticket['ticketStatus']?['name'] ?? 'Pending',
            location: ticket['locationDescription'] ?? '',
            longitude: null,
            latitude: null,
            gender: null,
            isWithMaterial: ticket['withMaterial'] ?? false,
            priority: null,
            createdBy: 0,
            customerPackageId: null,
            totalPrice: 0.0,
            serviceprovide: ticket['technician']?['name'] ?? null,
            description: ticket['ticketDescription'] ?? '',
            descriptionAr: ticket['ticketDescription'] ?? '',
          );
        }).toList();

        setState(() {
          ticketModel = TicketModel(tickets: tickets);
          loading = false;
        });
      } else {
        setState(() {
          ticketModel = TicketModel(tickets: []);
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future getTicketStatistics() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      final stats = await BookingApi.getTicketStatisticsFromMMS(
        token: appProvider.userModel?.token ?? "",
      );

      if (stats != null) {
        setState(() {
          ticketStatistics = stats;
        });
      }
    } catch (e) {}
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
              "${AppLocalizations.of(context)!.hello} ${appProvider.userModel?.customer.name ?? ""}",
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
  final Map<String, dynamic>? ticketStatistics;

  const _TicketSummarySection({
    this.subsicripeModel,
    this.ticketStatistics,
  });

  @override
  State<_TicketSummarySection> createState() => _TicketSummarySectionState();
}

class _TicketSummarySectionState extends State<_TicketSummarySection> {
  @override
  Widget build(BuildContext context) {
    // Get ticket counts from MMS statistics
    // New format: {corrective: {total: X, completed: Y}, ...}
    // Old format (fallback): {corrective: X, ...}
    final correctiveData = widget.ticketStatistics?['byType']?['corrective'];
    final correctiveCompleted = (correctiveData is Map) ? (correctiveData['completed'] ?? 0).toString() : (correctiveData?.toString() ?? "0");
    final correctiveTotal =
        (correctiveData is Map) ? (correctiveData['total'] ?? 0).toString() : (correctiveData?.toString() ?? widget.subsicripeModel?.objSubscribe?.onDemandVisit.toString() ?? "0");

    final emergencyData = widget.ticketStatistics?['byType']?['emergency'];
    final emergencyCompleted = (emergencyData is Map) ? (emergencyData['completed'] ?? 0).toString() : (emergencyData?.toString() ?? "0");
    final emergencyTotal =
        (emergencyData is Map) ? (emergencyData['total'] ?? 0).toString() : (emergencyData?.toString() ?? widget.subsicripeModel?.objSubscribe?.emeregencyVisit.toString() ?? "0");

    return Column(
      children: [
        _CorrectiveTicketCard(
          used: correctiveCompleted,
          total: correctiveTotal,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _SmallTicketCard(
            title: AppLocalizations.of(context)!.emergencyTickets,
            imagePath: 'assets/icon/image.png',
            used: emergencyCompleted,
            total: emergencyTotal,
          ),
        ),
      ],
    );
  }
}

class _CorrectiveTicketCard extends StatefulWidget {
  final String? used;
  final String? total;

  const _CorrectiveTicketCard({this.used, this.total});

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
          Text(
            AppLocalizations.of(context)!.correctiveTickets,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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

  const _SmallTicketCard({required this.title, required this.imagePath, this.used, this.total});

  @override
  State<_SmallTicketCard> createState() => _SmallTicketCardState();
}

class _SmallTicketCardState extends State<_SmallTicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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

// ---------------- Last Tickets ----------------
class _LastTicketsSection extends StatelessWidget {
  final TicketModel? ticketModel;
  const _LastTicketsSection({this.ticketModel});

  @override
  Widget build(BuildContext context) {
    // حساب الارتفاع المتاح للـ Tickets
    double screenHeight = MediaQuery.of(context).size.height;
    double safeAreaTop = MediaQuery.of(context).padding.top;
    double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // العناصر الثابتة:
    // Header ≈ 70
    // Ticket Summary ≈ 200
    // "Last Tickets" Row ≈ 40
    // Add Ticket Button ≈ 60
    // Spacing (16+16+25+4+16) ≈ 77
    double fixedHeight = 125 + 200 + 40 + 60 + 77 + safeAreaTop + safeAreaBottom;
    
    // الارتفاع المتبقي للـ PageView
    double availableHeight = screenHeight - fixedHeight;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.lastTickets, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  rightToLeft(BookingScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)!.viewAll, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: availableHeight.clamp(300, 500), // حد أدنى 300 وأقصى 500
          child: PageView.builder(
            itemCount: (ticketModel?.tickets.length ?? 0) > 0 ? ((ticketModel!.tickets.length / 4).ceil()) : 0,
            itemBuilder: (context, pageIndex) {
              int startIndex = pageIndex * 4;
              int endIndex = (startIndex + 4).clamp(0, ticketModel?.tickets.length ?? 0);
              
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: endIndex - startIndex,
                itemBuilder: (context, index) {
                  int ticketIndex = startIndex + index;
                  
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailsScreen(
                            id: ticketModel?.tickets[ticketIndex].id.toString() ?? "",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors(context).primaryColor.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: ticketModel?.tickets[ticketIndex].icon == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  "assets/image/icon_logo.png",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ))
                            : WidgetCachNetworkImage(
                                image: ticketModel?.tickets[ticketIndex].icon ?? "",
                                width: 40,
                                height: 40,
                              ),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "#${ticketModel?.tickets[ticketIndex].id}",
                              style: TextStyle(fontSize: 12, color: AppColors(context).primaryColor),
                            ),
                            Text(
                                ticketModel?.tickets[ticketIndex].description == null
                                    ? AppLocalizations.of(context)!.preventivevisits
                                    : ticketModel?.tickets[ticketIndex].description ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                DateFormat('MMM d, yyyy').format(
                                    ticketModel?.tickets[ticketIndex].selectedDate ?? DateTime.now()),
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (ticketModel?.tickets[ticketIndex].serviceprovide != null)
                              Text(
                                ticketModel?.tickets[ticketIndex].serviceprovide ?? "",
                                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ticketModel?.tickets[ticketIndex].status == "Pending"
                                ? AppColors(context).primaryColor.withOpacity(.2)
                                : ticketModel?.tickets[ticketIndex].status == "Cancelled"
                                    ? Colors.red.withOpacity(.2)
                                    : Colors.green.withOpacity(.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticketModel?.tickets[ticketIndex].status ?? "",
                            style: TextStyle(
                                color: ticketModel?.tickets[ticketIndex].status == "Pending"
                                    ? AppColors(context).primaryColor
                                    : ticketModel?.tickets[ticketIndex].status == "Cancelled"
                                        ? Colors.red
                                        : Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
