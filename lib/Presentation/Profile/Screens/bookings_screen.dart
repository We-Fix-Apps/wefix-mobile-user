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
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                                id: ticketModel?.tickets[index].id.toString() ?? "0",
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
                                      cancelBooking(id: ticketModel?.tickets[index].id).then((value) {
                                        getBookingHistory();
                                      });
                                    },
                                    desc: "Are you sure you want to cancel the appointment ? ",
                                    isError: true);
                              },
                            );
                          },
                          ticket: ticketModel?.tickets[index],
                          status: ticketModel?.tickets[index].status ?? "Pending",
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future getBookingHistory() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Check if user is B2B user (Admin, Team Leader, Technician, or Sub-Technician)
      // These users should use MMS API which filters tickets based on role
      final currentUserRoleId = appProvider.userModel?.customer.roleId;
      int? roleIdInt;
      if (currentUserRoleId is int) {
        roleIdInt = currentUserRoleId;
      } else if (currentUserRoleId is String) {
        roleIdInt = int.tryParse(currentUserRoleId);
      } else if (currentUserRoleId != null) {
        roleIdInt = int.tryParse(currentUserRoleId.toString());
      }
      
      // Use MMS API for B2B users (roleId 18, 20, 21, 22)
      // MMS API will automatically filter tickets based on role:
      // - Technicians (21) and Sub-Technicians (22) see only their assigned tickets
      // - Admins (18) and Team Leaders (20) see all company tickets
      final isB2BUser = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22);
      
      // Use accessToken for MMS APIs, userModel.token for OMS APIs
      final token = isB2BUser 
          ? (appProvider.accessToken ?? appProvider.userModel?.token ?? "")
          : (appProvider.userModel?.token ?? "");
      
      BookingApi.getBookingsHistory(
        token: token,
        isCompanyAdmin: isB2BUser, // Use MMS API for all B2B users
      ).then((value) {
        if (!mounted) return;
        setState(() {
          ticketModel = value;
          loading = false;
        });
      });
    } catch (e) {
      log(e.toString());
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future cancelBooking({int? id}) async {
    if (!mounted) return;
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.cancleBooking(
              token: appProvider.userModel?.token ?? "", id: id)
          .then((value) {
        if (!mounted) return;
        setState(() {
          loading2 = false;
        });
      });
    } catch (e) {
      log(e.toString());
      if (!mounted) return;
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
  BookingCard({super.key, required this.status, this.ticket, this.onValue, this.onTapCancle, required this.loading2});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
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
    // mmsBaseUrl format: https://wefix-backend-mms.ngrok.app/api/v1/
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
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: false);
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.status == "Completed"
                          ? AppColors.greenColor.withOpacity(.2)
                          : widget.status == "Canceled"
                              ? AppColors.redColor.withOpacity(.2)
                              : widget.status == "Pending"
                                  ? AppColors(context).primaryColor.withOpacity(.2)
                                  : AppColors.blueColor.withOpacity(.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      languageProvider.lang == "ar" ? widget.ticket?.statusAr ?? "" : widget.ticket?.status ?? "",
                      style: TextStyle(
                          color: widget.status == "Completed"
                              ? AppColors.greenColor
                              : widget.status == "Canceled"
                                  ? AppColors.redColor
                                  : widget.status == "Pending"
                                      ? AppColors(context).primaryColor
                                      : AppColors.blueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.lang == "ar" ? widget.ticket?.descriptionAr ?? AppText(context).preventivemaintenancevisit : widget.ticket?.description ?? AppText(context).preventivemaintenancevisit,
                style: TextStyle(fontSize: AppSize(context).smallText1, fontWeight: FontWeight.bold),
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
                  fontWeight: FontWeight.normal
                        ),
              ),
              const SizedBox(height: 10),
              widget.status == "Rejected"
                  ? const SizedBox()
                  : const Divider(color: AppColors.greyColorback),
              // Show technician info if technician is assigned (regardless of status)
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
