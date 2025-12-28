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
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TicketsScreen extends StatefulWidget {
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  bool loading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 5; // 5 tickets per scroll
  List<Ticket> allTickets = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getTickets();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls to 80% of the list
      if (!isLoadingMore && hasMore) {
        loadMoreTickets();
      }
    }
  }

  Future getTickets({bool refresh = false}) async {
    if (!mounted) return;
    
    if (refresh) {
      setState(() {
        currentPage = 1;
        allTickets = [];
        hasMore = true;
        loading = true;
      });
    } else {
      setState(() {
        loading = true;
      });
    }

    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Use accessToken for MMS APIs
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
      final ticketsData = await BookingApi.getCompanyTicketsFromMMS(
        token: token,
        page: currentPage,
        limit: limit,
      );

      if (!mounted) return;

      if (ticketsData != null) {
        // Convert MMS tickets format to Ticket format
        final allTicketsData = ticketsData['all']?['tickets'] ?? [];
        final newTickets = allTicketsData.map<Ticket>((ticket) {
          final ticketDate = ticket['ticketDate'] != null 
              ? DateTime.parse(ticket['ticketDate']) 
              : DateTime.now();

          return Ticket(
            id: ticket['id'] ?? 0,
            customerId: 0,
            statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
            ticketTypeId: ticket['ticketType']?['id'] ?? 0,
            rating: null,
            icon: ticket['mainService']?['image'] ?? ticket['mainService']?['icon'] ?? null,
            cancelButton: null,
            isRated: null,
            type: ticket['ticketType']?['name'],
            ticketCodeId: ticket['ticketCodeId']?.toString() ?? null,
            promoCode: null,
            requestedDate: ticketDate,
            selectedDate: ticketDate,
            selectedDateTime: ticket['ticketTimeFrom'] != null && ticket['ticketTimeTo'] != null 
                ? '${ticket['ticketTimeFrom']} - ${ticket['ticketTimeTo']}' 
                : null,
            timeFrom: ticket['ticketTimeFrom'],
            timeTo: ticket['ticketTimeTo'],
            teamNo: null,
            status: ticket['ticketStatus']?['name'] ?? 'Pending',
            location: ticket['ticketTitle'] ?? '',
            longitude: null,
            latitude: null,
            gender: null,
            isWithMaterial: ticket['withMaterial'] ?? false,
            priority: null,
            createdBy: 0,
            customerPackageId: null,
            totalPrice: 0.0,
            serviceprovide: ticket['technician']?['name'] ?? null,
            serviceprovideImage: ticket['technician']?['profileImage'] ?? null,
            description: ticket['ticketDescription'] ?? '',
            descriptionAr: ticket['ticketDescription'] ?? '',
          );
        }).toList();

        setState(() {
          if (refresh) {
            allTickets = newTickets;
          } else {
            allTickets.addAll(newTickets);
          }
          
          // Check if there are more tickets to load
          hasMore = newTickets.length >= limit;
          loading = false;
        });
      } else {
        setState(() {
          hasMore = false;
          loading = false;
        });
      }
    } catch (e) {
      log(e.toString());
      if (!mounted) return;
      setState(() {
        loading = false;
        hasMore = false;
      });
    }
  }

  Future loadMoreTickets() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
      final ticketsData = await BookingApi.getCompanyTicketsFromMMS(
        token: token,
        page: currentPage,
        limit: limit,
      );

      if (!mounted) return;

      if (ticketsData != null) {
        final allTicketsData = ticketsData['all']?['tickets'] ?? [];
        final newTickets = allTicketsData.map<Ticket>((ticket) {
          final ticketDate = ticket['ticketDate'] != null 
              ? DateTime.parse(ticket['ticketDate']) 
              : DateTime.now();

          return Ticket(
            id: ticket['id'] ?? 0,
            customerId: 0,
            statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
            ticketTypeId: ticket['ticketType']?['id'] ?? 0,
            rating: null,
            icon: ticket['mainService']?['image'] ?? ticket['mainService']?['icon'] ?? null,
            cancelButton: null,
            isRated: null,
            type: ticket['ticketType']?['name'],
            ticketCodeId: ticket['ticketCodeId']?.toString() ?? null,
            promoCode: null,
            requestedDate: ticketDate,
            selectedDate: ticketDate,
            selectedDateTime: ticket['ticketTimeFrom'] != null && ticket['ticketTimeTo'] != null 
                ? '${ticket['ticketTimeFrom']} - ${ticket['ticketTimeTo']}' 
                : null,
            timeFrom: ticket['ticketTimeFrom'],
            timeTo: ticket['ticketTimeTo'],
            teamNo: null,
            status: ticket['ticketStatus']?['name'] ?? 'Pending',
            location: ticket['ticketTitle'] ?? '',
            longitude: null,
            latitude: null,
            gender: null,
            isWithMaterial: ticket['withMaterial'] ?? false,
            priority: null,
            createdBy: 0,
            customerPackageId: null,
            totalPrice: 0.0,
            serviceprovide: ticket['technician']?['name'] ?? null,
            serviceprovideImage: ticket['technician']?['profileImage'] ?? null,
            description: ticket['ticketDescription'] ?? '',
            descriptionAr: ticket['ticketDescription'] ?? '',
          );
        }).toList();

        setState(() {
          allTickets.addAll(newTickets);
          hasMore = newTickets.length >= limit;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          hasMore = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      log(e.toString());
      if (!mounted) return;
      setState(() {
        isLoadingMore = false;
        hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppText(context).tickets}'),
        centerTitle: true,
        actions: [
          const LanguageButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => getTickets(refresh: true),
        child: loading && allTickets.isEmpty
            ? LinearProgressIndicator(
                color: AppColors(context).primaryColor,
                backgroundColor: AppColors.secoundryColor,
              )
            : allTickets.isEmpty
                ? const EmptyScreen()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: allTickets.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == allTickets.length) {
                        // Loading indicator at the bottom
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors(context).primaryColor,
                            ),
                          ),
                        );
                      }
                      
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            rightToLeft(
                              TicketDetailsScreen(
                                id: allTickets[index].id.toString(),
                              ),
                            ),
                          );
                        },
                        child: TicketCard(
                          ticket: allTickets[index],
                          status: allTickets[index].status ?? "Pending",
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class TicketCard extends StatefulWidget {
  final String status;
  final Ticket? ticket;
  
  TicketCard({
    required this.status,
    this.ticket,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  // Helper function to check if image URL is valid
  bool _isValidImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    if (imageUrl.toLowerCase() == "null") return false;
    if (imageUrl.trim().isEmpty) return false;
    return true;
  }

  // Helper function to build full URL for technician image from backend-mms
  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    
    // If already a full URL (http/https), return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Build base URL from backend-mms
    String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
    
    // Normalize path - backend-mms now stores images in /WeFixFiles/Images/ to match backend-oms
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    
    // If path already starts with /WeFixFiles, use it as is
    if (cleanPath.startsWith('/WeFixFiles')) {
      return '$baseUrl$cleanPath';
    }
    
    // For backward compatibility: if path is /uploads/filename, convert to /WeFixFiles/Images/filename
    if (cleanPath.startsWith('/uploads/')) {
      String filename = cleanPath.replaceFirst('/uploads/', '');
      return '$baseUrl/WeFixFiles/Images/$filename';
    }
    
    // If just a filename, assume it's in /WeFixFiles/Images/
    return '$baseUrl/WeFixFiles/Images/$cleanPath';
  }

  // Helper function to format time without milliseconds
  String _formatTimeWithoutMs(String? time) {
    if (time == null || time.isEmpty) return '';
    // Remove milliseconds if present (format: HH:mm:ss or HH:mm:ss.SSS or HH:mm:ss.SSSSSS)
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        // Remove seconds if they contain milliseconds
        String minutes = parts[1];
        if (minutes.contains('.')) {
          minutes = minutes.split('.')[0];
        }
        return '${parts[0]}:$minutes';
      }
    }
    return time;
  }

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
                    widget.ticket?.ticketCodeId != null
                        ? widget.ticket!.ticketCodeId!
                        : "# ${widget.ticket?.id.toString() ?? "123456"}",
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
              Text(
                () {
                  String dateTimeText = '';
                  if (widget.ticket?.selectedDate != null) {
                    dateTimeText = widget.ticket!.selectedDate.toString().substring(0, 10);
                  }
                  if (widget.ticket?.selectedDateTime != null) {
                    // Format time without milliseconds
                    String timeText = _formatTimeWithoutMs(widget.ticket!.selectedDateTime);
                    // If time contains dash (format: "HH:mm - HH:mm"), format both parts
                    if (timeText.contains(' - ')) {
                      final parts = timeText.split(' - ');
                      if (parts.length == 2) {
                        timeText = '${_formatTimeWithoutMs(parts[0])} - ${_formatTimeWithoutMs(parts[1])}';
                      }
                    }
                    dateTimeText += dateTimeText.isNotEmpty ? ' , $timeText' : timeText;
                  }
                  return dateTimeText;
                }(),
                style: TextStyle(
                    fontSize: AppSize(context).smallText3,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 10),
              // Show technician info if technician is assigned
              if (widget.ticket?.serviceprovide != null && 
                  widget.ticket!.serviceprovide.toString().trim().isNotEmpty)
                Row(
                  children: [
                    _isValidImage(widget.ticket?.serviceprovideImage)
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _buildImageUrl(widget.ticket?.serviceprovideImage),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircleAvatar(
                                backgroundColor: AppColors.backgroundColor,
                                radius: 20,
                                child: SvgPicture.asset(
                                  "assets/icon/smile.svg",
                                  color: AppColors(context).primaryColor,
                                ),
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                backgroundColor: AppColors.backgroundColor,
                                radius: 20,
                                child: SvgPicture.asset(
                                  "assets/icon/smile.svg",
                                  color: AppColors(context).primaryColor,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: AppColors.backgroundColor,
                            radius: 20,
                            child: SvgPicture.asset(
                              "assets/icon/smile.svg",
                              color: AppColors(context).primaryColor,
                            ),
                          ),
                    const SizedBox(width: 10),
                    Text(
                      widget.ticket?.serviceprovide?.toString() ?? "Service Provider",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

