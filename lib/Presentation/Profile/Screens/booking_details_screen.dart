import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/auth_helper.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/booking_details_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Components/rating_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/Chat/messages_screen.dart';
import '../../appointment/Components/attachments_widget.dart';
import '../../B2B/ticket/create_update_ticket_screen_v2.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String id;

  const TicketDetailsScreen({super.key, required this.id});
  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  bool? loading = false;
  BookingDetailsModel? bookingDetailsModel;
  Map<String, dynamic>? fullTicketData; // Full ticket data from MMS API

  @override
  void initState() {
    getBookingDetails();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Check if user can edit tickets
    // Allowed roles:
    //   - roleId 18: Admin (مدير) - Company Admin - Can edit all fields
    //   - roleId 20: Team Leader (قائد الفريق) - Can edit all fields
    //   - roleId 21: Technician (فني) - Can ONLY change ticket status
    //   - roleId 22: Sub-Technician (فني مساعد) - Can ONLY change ticket status
    //   - roleId 26: Super User - Can edit all fields
    // Restricted roles (cannot edit at all):
    //   - roleId 23: (Restricted - cannot edit)
    final currentUserRoleId = appProvider.userModel?.customer.roleId;
    
    // Parse roleId to integer - handle int, String, or null
    int? roleIdInt;
    if (currentUserRoleId == null) {
      roleIdInt = null;
    } else if (currentUserRoleId is int) {
      roleIdInt = currentUserRoleId;
    } else if (currentUserRoleId is String) {
      roleIdInt = int.tryParse(currentUserRoleId);
    } else {
      // Try to convert to string then parse
      roleIdInt = int.tryParse(currentUserRoleId.toString());
    }
    
    // Define role-based permissions
    // Technicians (21, 22) can only change status
    final isTechnician = roleIdInt != null && (roleIdInt == 21 || roleIdInt == 22);
    // Admin (18), Team Leader (20), and Super User (26) can edit all fields
    final canEditAllFields = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 26);
    // Show edit button for Admin, Team Leader, Super User, and Technicians (but Technicians are limited to status changes)
    // Role 23 will not see the edit button (completely restricted)
    final canEditTicket = canEditAllFields || isTechnician;
    
    String _formatTime(String? time) {
  if (time == null || time.isEmpty) return '';
  // Remove seconds if present (e.g., "16:00:00" -> "16:00")
  if (time.length >= 5) {
    return time.substring(0, 5);
  }
  return time;
}
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors(context).primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ticket #${bookingDetailsModel?.objTickets.id ?? ""}',
        ),
        actions: [
          // Edit button - show for Admin (18), Team Leader (20), Technicians (21), and Sub-Technicians (22)
          // Technicians can only edit ticket status, while Admin/Team Leader can edit all fields
          if (canEditTicket && bookingDetailsModel != null)
            IconButton(
              icon: Icon(Icons.edit, color: AppColors(context).primaryColor),
              onPressed: () async {
                // Get full ticket data from MMS API for editing
                await _navigateToEditTicket(context, isTechnician: isTechnician);
              },
              tooltip: isTechnician ? 'Change Status' : 'Edit Ticket',
            ),
          const LanguageButton(),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      bottomNavigationBar: bookingDetailsModel?.objTickets.status == "Completed"
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomBotton(
                        title: "View Invoice",
                        onTap: () {
                          _launchUrl(
                              bookingDetailsModel?.objTickets.reportLink ?? "");
                        }),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  bookingDetailsModel?.objTickets.isRated == true
                      ? const SizedBox()
                      : CustomBotton(
                          width: AppSize(context).width * 0.2,
                          title: AppText(context).rate,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              isScrollControlled: true,
                              builder: (context) => RatingModal(
                                id: bookingDetailsModel?.objTickets.id ?? 0,
                                isRated:
                                    bookingDetailsModel?.objTickets.isRated ??
                                        false,
                              ),
                            ).whenComplete(() => getBookingDetails());
                          })
                ],
              ),
            )
          : const SizedBox(),
      floatingActionButton: bookingDetailsModel?.objTickets.status ==
              "Completed"
          ? const SizedBox()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      downToTop(
                        CommentsScreenById(
                            ticketId: bookingDetailsModel?.objTickets.id ?? 0,
                            toUserId:
                                bookingDetailsModel?.objTickets.userId ?? 0),
                      ),
                    );
                  },
                  backgroundColor: AppColors(context).primaryColor,
                  child: const Icon(Icons.chat_bubble),
                ),
              ],
            ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛠️ ${AppText(context).maintenanceTicketDetails}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize(context).smallText1)),
                  SizedBox(height: AppSize(context).smallText1),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        _buildRow(
                            AppText(context).title, AppText(context).status,
                            rightValue: bookingDetailsModel?.objTickets.status,
                            leftValue: bookingDetailsModel?.objTickets.type ==
                                    "preventive"
                                ? AppText(context).preventivemaintenancevisit
                                : bookingDetailsModel?.objTickets.title),
                        _buildRow(
                            AppText(context).type, AppText(context).createdDate,
                            leftValue: bookingDetailsModel?.objTickets.type,
                            rightValue: bookingDetailsModel?.objTickets.date
                                .toString()
                                .substring(0, 10)),
                        bookingDetailsModel?.objTickets.type == "preventive"
                            ? const SizedBox()
                            : bookingDetailsModel?.objTickets.totalPrice == null
                                ? const SizedBox()
                                : _buildRow(
                                    AppText(context).price,
                                    "",
                                    leftValue:
                                        "${bookingDetailsModel?.objTickets.totalPrice} ${AppText(context).jod}",
                                  ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  bookingDetailsModel?.objTickets.servcieTickets.isEmpty == true
                      ? const SizedBox()
                      : _buildSection(
                          '👷‍♂️ ${AppText(context).services}',
                          bookingDetailsModel
                                      ?.objTickets.servcieTickets.isEmpty ==
                                  true
                              ? const SizedBox()
                              : ListView.builder(
                                  itemCount: bookingDetailsModel
                                      ?.objTickets.servcieTickets.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "${languageProvider.lang == "ar" ? bookingDetailsModel?.objTickets.servcieTickets[index].nameAr : bookingDetailsModel?.objTickets.servcieTickets[index].name} ${bookingDetailsModel?.objTickets.servcieTickets[index].quantity != null ? " x ${bookingDetailsModel?.objTickets.servcieTickets[index].quantity}" : ""}"),
                                        Text(
                                            "${bookingDetailsModel?.objTickets.servcieTickets[index].price} ${AppText(context).jod}"),
                                      ],
                                    );
                                  },
                                )),
                  bookingDetailsModel?.objTickets.advantagesTickets.isEmpty ==
                          true
                      ? const SizedBox()
                      : _buildSection(
                          '🛠️ ${AppText(context).technicianGender}',
                          bookingDetailsModel
                                      ?.objTickets.advantagesTickets.isEmpty ==
                                  true
                              ? const SizedBox()
                              : ListView.builder(
                                  itemCount: bookingDetailsModel
                                      ?.objTickets.advantagesTickets.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Text(
                                        "${languageProvider.lang == "ar" ? bookingDetailsModel?.objTickets.advantagesTickets[index].name : bookingDetailsModel?.objTickets.advantagesTickets[index].nameAr} ${bookingDetailsModel?.objTickets.advantagesTickets[index].price} ${AppText(context).jod} ");
                                  },
                                )),
                  _buildSection(
                      '📝 ${AppText(context).issueDescription}',
                      Text(bookingDetailsModel?.objTickets.description ?? "",
                          style: const TextStyle(color: Colors.grey))),
                  _buildSection(
                      '🛠️ ${AppText(context).serviceProviderActions}',
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("🕑 ${AppText(context).estimatedTime} : ",
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontSize: AppSize(context).smallText2)),
                              Text(
                                  _calculateEstimatedTime(),
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSize(context).smallText2)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          bookingDetailsModel?.objTickets.type.toLowerCase() ==
                                  "preventive"
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "🔩 ${AppText(context).partsrequired} : ",
                                        style: TextStyle(
                                            color: AppColors.blackColor1,
                                            fontSize:
                                                AppSize(context).smallText2)),
                                    Text(
                                        _getPartsRequired(),
                                        style: TextStyle(
                                            color: AppColors.blackColor1,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                AppSize(context).smallText2)),
                                  ],
                                ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("👷‍♀️ ${AppText(context).isWithFemale} : ",
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontSize: AppSize(context).smallText2)),
                              Text(
                                  _getHavingFemaleEngineer(),
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSize(context).smallText2)),
                            ],
                          ),
                        ],
                      )),
                  // Additional B2B Ticket Information (if available)
                  if (fullTicketData != null) ...[
                  const Divider(
                    color: AppColors.backgroundColor,
                  ),
                  const SizedBox(height: 8),
                    // Ticket Code & Basic Info
                    _buildSection(
                      '🎫 ${languageProvider.lang == "ar" ? "معلومات التذكرة" : "Ticket Information"}',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          if (fullTicketData!['ticketCodeId'] != null)
                            _buildInfoRow(
                              '${languageProvider.lang == "ar" ? "رمز التذكرة" : "Ticket Code"}:',
                              fullTicketData!['ticketCodeId'],
                            ),
                          if (fullTicketData!['ticketDate'] != null)
                            _buildInfoRow(
                              '${languageProvider.lang == "ar" ? "تاريخ التذكرة" : "Ticket Date"}:',
                              _formatDate(fullTicketData!['ticketDate']),
                            ),
                          if (fullTicketData!['ticketTimeFrom'] != null && fullTicketData!['ticketTimeTo'] != null)
                            _buildInfoRow(
                              '${languageProvider.lang == "ar" ? "وقت التذكرة" : "Time Slot"}:',
                              '${_formatTime(fullTicketData!['ticketTimeFrom'])} - ${_formatTime(fullTicketData!['ticketTimeTo'])}',
                            ),
                          if (fullTicketData!['source'] != null)
                            _buildInfoRow(
                              '${languageProvider.lang == "ar" ? "المصدر" : "Source"}:',
                              fullTicketData!['source'] == 'Web' 
                                ? (languageProvider.lang == "ar" ? "نظام الويب" : "Web Admin")
                                : (languageProvider.lang == "ar" ? "التطبيق المحمول" : "Mobile App"),
                      ),
                    ],
                  ),
                    ),
                    // Contract, Branch, Zone Information
                    if (fullTicketData!['contract'] != null || fullTicketData!['branch'] != null || fullTicketData!['zone'] != null)
                      _buildSection(
                        '🏢 ${languageProvider.lang == "ar" ? "معلومات الشركة" : "Company Information"}',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (fullTicketData!['contract'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "العقد" : "Contract"}:',
                                fullTicketData!['contract']['title'] ?? '',
                              ),
                            if (fullTicketData!['branch'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "الفرع" : "Branch"}:',
                                fullTicketData!['branch']['title'] ?? '',
                              ),
                            if (fullTicketData!['zone'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "المنطقة" : "Zone"}:',
                                fullTicketData!['zone']['title'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    // Team Leader & Technician Information
                    if (fullTicketData!['teamLeader'] != null || fullTicketData!['technician'] != null)
                      _buildSection(
                        '👥 ${languageProvider.lang == "ar" ? "معلومات الفريق" : "Team Information"}',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (fullTicketData!['teamLeader'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "قائد الفريق" : "Team Leader"}:',
                                '${fullTicketData!['teamLeader']['name'] ?? ''} (${fullTicketData!['teamLeader']['userNumber'] ?? ''})',
                              ),
                            if (fullTicketData!['technician'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "الفني" : "Technician"}:',
                                '${fullTicketData!['technician']['name'] ?? ''} (${fullTicketData!['technician']['userNumber'] ?? ''})',
                              ),
                          ],
                        ),
                      ),
                    // Service Description
                    if (fullTicketData!['serviceDescription'] != null && fullTicketData!['serviceDescription'].toString().isNotEmpty)
                      _buildSection(
                        '📋 ${languageProvider.lang == "ar" ? "وصف الخدمة" : "Service Description"}',
                        Text(
                          fullTicketData!['serviceDescription'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    // Technician Attachments (for completed tickets)
                    if (fullTicketData!['technicianAttachments'] != null && 
                        (fullTicketData!['technicianAttachments'] as List).isNotEmpty)
                      _buildSection(
                        '📎 ${languageProvider.lang == "ar" ? "مرفقات الفني" : "Technician Attachments"}',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (fullTicketData!['technicianAttachments'] as List).map<Widget>((attachment) {
                            final filePath = attachment is Map 
                                ? (attachment['filePath'] ?? attachment['file_path'] ?? '').toString()
                                : attachment.toString();
                            final fileName = attachment is Map
                                ? (attachment['fileName'] ?? attachment['file_name'] ?? attachment['filename'] ?? '').toString()
                                : filePath.split('/').last;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _launchUrl(filePath),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.attach_file, color: AppColors(context).primaryColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          fileName.isNotEmpty ? fileName : 'Attachment',
                                          style: TextStyle(
                                            fontSize: AppSize(context).smallText2,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(Icons.visibility, color: AppColors(context).primaryColor, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    // Signature (for completed tickets)
                    if (fullTicketData!['signature'] != null && 
                        fullTicketData!['signature'].toString().isNotEmpty)
                      _buildSection(
                        '✍️ ${languageProvider.lang == "ar" ? "التوقيع" : "Signature"}',
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => _launchUrl(fullTicketData!['signature'].toString()),
                              child: Image.network(
                                fullTicketData!['signature'].toString(),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text(
                                          languageProvider.lang == "ar" ? "خطأ في تحميل الصورة" : "Error loading image",
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Also check reportLink for backward compatibility (signature might be in reportLink)
                    if ((fullTicketData!['signature'] == null || fullTicketData!['signature'].toString().isEmpty) &&
                        bookingDetailsModel?.objTickets.reportLink != null && 
                        bookingDetailsModel?.objTickets.reportLink?.isNotEmpty == true &&
                        (bookingDetailsModel?.objTickets.status?.toLowerCase() == 'completed' || 
                         bookingDetailsModel?.objTickets.status?.toLowerCase() == 'ended'))
                      _buildSection(
                        '✍️ ${languageProvider.lang == "ar" ? "التوقيع" : "Signature"}',
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () => _launchUrl(bookingDetailsModel?.objTickets.reportLink ?? ''),
                              child: Image.network(
                                bookingDetailsModel?.objTickets.reportLink ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text(
                                          languageProvider.lang == "ar" ? "خطأ في تحميل الصورة" : "Error loading image",
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Audit Information
                    if (fullTicketData!['createdAt'] != null || fullTicketData!['updatedAt'] != null || fullTicketData!['creator'] != null || fullTicketData!['updater'] != null)
                      _buildSection(
                        '📊 ${languageProvider.lang == "ar" ? "معلومات السجل" : "Audit Information"}',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (fullTicketData!['createdAt'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "تاريخ الإنشاء" : "Created At"}:',
                                _formatDateTime(fullTicketData!['createdAt']),
                              ),
                            if (fullTicketData!['creator'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "أنشأ بواسطة" : "Created By"}:',
                                '${fullTicketData!['creator']['name'] ?? ''} (${fullTicketData!['creator']['userNumber'] ?? ''})',
                              ),
                            if (fullTicketData!['updatedAt'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "تاريخ التحديث" : "Updated At"}:',
                                _formatDateTime(fullTicketData!['updatedAt']),
                              ),
                            if (fullTicketData!['updater'] != null)
                              _buildInfoRow(
                                '${languageProvider.lang == "ar" ? "حدث بواسطة" : "Updated By"}:',
                                '${fullTicketData!['updater']['name'] ?? ''} (${fullTicketData!['updater']['userNumber'] ?? ''})',
                              ),
                          ],
                        ),
                      ),
                  ],
                  bookingDetailsModel?.objTickets.ticketTools.isEmpty == true
                      ? const SizedBox()
                      : _buildSection(
                          '🔨 ${AppText(context).requiredTools}',
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (bookingDetailsModel?.objTickets.ticketTools ?? [])
                                        .map((tool) => Chip(
                                              label: Text(tool["title"] ?? ""),
                                              backgroundColor:
                                                  AppColors(context)
                                                      .primaryColor
                                                      .withOpacity(.3),
                                            ))
                                        .toList() ??
                                    [],
                          )),
                  bookingDetailsModel?.objTickets.ticketMaterials.isEmpty ==
                          true
                      ? const SizedBox()
                      : _buildSection(
                          '🧰 ${AppText(context).ticketM}',
                          Wrap(
                            spacing: 3,
                            runSpacing: 3,
                            children: bookingDetailsModel
                                    ?.objTickets.ticketMaterials
                                    .map((tool) => Chip(
                                          label: Text(
                                              "${tool["title"]}  x ${tool["quantity"]}"),
                                          backgroundColor: tool["status"] ==
                                                  "Pending"
                                              ? AppColors(context)
                                                  .primaryColor
                                                  .withOpacity(.3)
                                              : tool["status"] == "Rejected"
                                                  ? Colors.red.withOpacity(.3)
                                                  : Colors.green
                                                      .withOpacity(.3),
                                        ))
                                    .toList() ??
                                [],
                          )),
                  bookingDetailsModel?.objTickets.ticketMaterials.isEmpty ==
                          true
                      ? const SizedBox()
                      : const Divider(
                          color: AppColors.backgroundColor,
                        ),
                  bookingDetailsModel?.objTickets.type.toLowerCase() ==
                          "preventive"
                      ? _buildCompletionChecklist()
                      : const SizedBox(),
                  // Attachments section at the end after Audit Information
                  // Always show attachments section
                  Builder(
                    builder: (context) {
                      // Check if there are attachments
                      final hasAttachments = (fullTicketData != null && 
                          fullTicketData!['files'] != null && 
                          (fullTicketData!['files'] as List).isNotEmpty) ||
                          (bookingDetailsModel?.objTickets.ticketAttatchments.isNotEmpty == true);
                      
                      return Column(
                        children: [
                          const Divider(
                            color: AppColors.backgroundColor,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    color: AppColors(context).primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "📎 ${AppText(context).attachments}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize(context).smallText1,
                                        color: AppColors(context).primaryColor),
                                  ),
                                ],
                              ),
                              if (hasAttachments)
                                InkWell(
                                  onTap: () => showAttachmentBottomSheet(context),
                                  child: Text(
                                    AppText(context).viewAll,
                                    style: TextStyle(
                                        color: AppColors.secoundryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize(context).smallText2),
                                  ),
                                )
                              else
                                Text(
                                  'No attachments',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: AppSize(context).smallText2),
                                ),
                            ],
                          ),
                          if (hasAttachments) ...[
                            const SizedBox(height: 8),
                            // Show preview of first few attachments
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[600],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_getAttachmentsCount()} ${_getAttachmentsCount() == 1 ? 'file' : 'files'} attached',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(
                            color: AppColors.backgroundColor,
                            height: 30,
                          ),
                        ],
                      );
                    },
                  ),
                  // Note: Technician attachments are now shown in the completed ticket info section above
                  // This section is kept for backward compatibility with old ticket images
                  if (bookingDetailsModel?.objTickets.type != "previntive" && bookingDetailsModel?.objTickets.type?.toLowerCase() != "preventive")
                    Builder(
                      builder: (context) {
                        // Get professional attachments (images) from fullTicketData (B2B) or bookingDetailsModel
                        // Only show if technicianAttachments is not available (for backward compatibility)
                        if (fullTicketData != null && fullTicketData!['technicianAttachments'] != null) {
                          // Technician attachments are already shown above, skip this section
                          return const SizedBox();
                        }
                        
                        List<dynamic> ticketImages = [];
                        
                        if (fullTicketData != null && fullTicketData!['files'] != null) {
                          final allFiles = fullTicketData!['files'] as List;
                          ticketImages = allFiles.where((file) {
                            final category = file is Map 
                                ? (file['category'] ?? '').toString().toLowerCase()
                                : '';
                            return category == 'image';
                          }).toList();
                        } else if (bookingDetailsModel?.objTickets.ticketImages != null) {
                          ticketImages = bookingDetailsModel!.objTickets.ticketImages;
                        }
                        
                        // Only show if there are image attachments
                        if (ticketImages.isEmpty) {
                          return const SizedBox();
                        }
                        
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("📎 ${languageProvider.lang == "ar" ? "مرفقات الفني" : "Technician Attachments"}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize(context).smallText1)),
                            InkWell(
                              onTap: () =>
                                  showAttachmentTicketBottomSheet(context),
                              child: Text(
                                AppText(context).viewAll,
                                style: TextStyle(
                                    color: AppColors.secoundryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize(context).smallText2),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  // Add space at the end to prevent content from being hidden by floating action button
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showAttachmentBottomSheet(BuildContext context) {
    // Get attachments from fullTicketData (B2B) or bookingDetailsModel
    List<dynamic> attachments = [];
    
    if (fullTicketData != null && fullTicketData!['files'] != null) {
      // Use files from fullTicketData for B2B users
      attachments = fullTicketData!['files'] as List;
    } else if (bookingDetailsModel?.objTickets.ticketAttatchments != null) {
      // Use ticketAttatchments from bookingDetailsModel for regular users
      attachments = bookingDetailsModel!.objTickets.ticketAttatchments;
    }
    
    if (attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No attachments available'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppText(context, isFunction: true).attachmentPreview,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final file = attachments[index];
                    String filePath = '';
                    String fileName = '';
                    
                    if (file is Map) {
                      // Handle fullTicketData format
                      filePath = file['filePath']?.toString() ?? '';
                      fileName = file['fileName']?.toString() ?? filePath.split("/").last.split("-").last;
                    } else if (file is String) {
                      // Handle bookingDetailsModel format
                      filePath = file;
                      fileName = filePath.split("/").last.split("-").last;
                    } else if (file is Map && file.containsKey('filePath')) {
                      // Handle nested map format
                      filePath = file['filePath']?.toString() ?? '';
                      fileName = file['fileName']?.toString() ?? filePath.split("/").last.split("-").last;
                    }
                    
                    // Build full URL from relative path
                    final fullUrl = _buildFullUrl(filePath);
                    
                    return AttachmentsWidget(
                      image: fileName.isNotEmpty ? fileName : filePath.split("/").last.split("-").last,
                      url: fullUrl,
                    );
                  },
                  itemCount: attachments.length,
                  shrinkWrap: true),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Build full URL from relative path
  String _buildFullUrl(String filePath) {
    if (filePath.isEmpty) return '';
    
    // If already a full URL, return as is
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    
    // Build full URL using MMS base URL
    // MMS base URL: https://wefix-backend-mms.ngrok.app/api/v1/
    // Remove /api/v1/ to get base URL
    String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
    
    // If path already starts with /WeFixFiles, use it directly (correct path for ticket attachments)
    if (filePath.startsWith('/WeFixFiles')) {
      return '$baseUrl$filePath';
    }
    
    // If path starts with WeFixFiles (without leading slash), add it
    if (filePath.startsWith('WeFixFiles')) {
      return '$baseUrl/$filePath';
    }
    
    // Legacy support: If path already starts with /uploads, convert to WeFixFiles
    if (filePath.startsWith('/uploads')) {
      // Extract filename and assume it's in WeFixFiles/Contracts/ (legacy location)
      final filename = filePath.replaceFirst('/uploads/', '');
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Legacy support: If path starts with uploads (without leading slash)
    if (filePath.startsWith('uploads')) {
      final filename = filePath.replaceFirst('uploads/', '');
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Legacy support: If path contains 'app/uploads', extract just the filename
    if (filePath.contains('app/uploads') || filePath.contains('/uploads/')) {
      final filename = filePath.split('/').last;
      return '$baseUrl/WeFixFiles/Contracts/$filename';
    }
    
    // Otherwise, assume it's a filename and use WeFixFiles/Contracts/ (legacy location)
    final filename = filePath.split('/').last;
    return '$baseUrl/WeFixFiles/Contracts/$filename';
  }

  Future<void> _shareAllAttachments(List<dynamic> attachments) async {
    try {
      final List<String> fileUrls = [];
      
      for (final file in attachments) {
        final filePath = file is Map 
            ? (file['filePath'] ?? file['path'] ?? '').toString()
            : file.toString();
        
        if (filePath.isNotEmpty) {
          // Build full URL from relative path
          final fullUrl = _buildFullUrl(filePath);
          fileUrls.add(fullUrl);
        }
      }
      
      if (fileUrls.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No attachments to share'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Share all URLs via WhatsApp or general share
      final shareText = fileUrls.join('\n');
      
      // Try WhatsApp first
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareText)}';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to general share
        await _shareText(shareText);
      }
    } catch (e) {
      log('Error sharing attachments: $e');
      // Fallback to general share
      final shareText = attachments.map((file) {
        final filePath = file is Map 
            ? (file['filePath'] ?? file['path'] ?? '').toString()
            : file.toString();
        return _buildFullUrl(filePath);
      }).where((path) => path.isNotEmpty).join('\n');
      
      await _shareText(shareText);
    }
  }

  /// Share text using share_plus with fallback to url_launcher
  Future<void> _shareText(String text) async {
    try {
      await Share.share(text);
    } catch (e) {
      log('share_plus failed, trying url_launcher: $e');
      // Fallback: try to open WhatsApp directly
      try {
        final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
        }
      } catch (e2) {
        log('Error sharing via WhatsApp: $e2');
      }
    }
  }

  void showAttachmentTicketBottomSheet(BuildContext context) {
    // Get professional attachments (images) from fullTicketData (B2B) or bookingDetailsModel
    List<dynamic> ticketImages = [];
    
    if (fullTicketData != null && fullTicketData!['files'] != null) {
      // Filter only image files
      final allFiles = fullTicketData!['files'] as List;
      ticketImages = allFiles.where((file) {
        final category = file is Map 
            ? (file['category'] ?? '').toString().toLowerCase()
            : '';
        return category == 'image';
      }).toList();
    } else if (bookingDetailsModel?.objTickets.ticketImages != null) {
      ticketImages = bookingDetailsModel!.objTickets.ticketImages;
    }
    
    if (ticketImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No professional attachments available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppText(context, isFunction: true).attachmentPreview,
                    style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Share all button
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Share all attachments',
                      onPressed: () {
                        _shareAllAttachments(ticketImages);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final file = ticketImages[index];
                      final filePath = file is Map 
                          ? (file['filePath'] ?? file['path'] ?? '').toString()
                          : file.toString();
                      
                      // Build full URL from relative path
                      final fullUrl = _buildFullUrl(filePath);
                      
                      return AttachmentsWidget(
                        image: filePath.split("/").last.split("-").last,
                        url: fullUrl,
                      );
                    },
                    itemCount: ticketImages.length,
                    shrinkWrap: true),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String left, String right,
      {String? leftValue, String? rightValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                child: Text("${left} : ",
                    style: TextStyle(
                        color: AppColors.greyColor5,
                        fontSize: AppSize(context).smallText2)),
              ),
              if (leftValue != null) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: AppSize(context).width * 0.4,
                  child: Text(leftValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSize(context).smallText2)),
                ),
              ],
            ],
          ),
          rightValue == null
              ? const SizedBox()
              : Row(
                  children: [
                    SizedBox(
                      child: Text("${right}  ${":"} ",
                          style: TextStyle(
                              color: AppColors.greyColor5,
                              fontSize: AppSize(context).smallText2)),
                    ),
                    if (rightValue != null) ...[
                      const SizedBox(width: 4),
                      Text(rightValue,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSize(context).smallText2)),
                    ],
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.whiteColor1,
        child: bookingDetailsModel?.objTickets.customerImage == null
            ? SvgPicture.asset(
                "assets/icon/smile.svg",
                color: AppColors(context).primaryColor,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                    imageUrl:
                        bookingDetailsModel?.objTickets.customerImage ?? ""),
              ),
      ),
      title: Text(bookingDetailsModel?.objTickets.customerName ?? "",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSize(context).smallText1)),
      trailing: const SizedBox(
        width: 100, // ✅ Fixed here (gives constraints)
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chat, color: AppColors.secoundryColor),
            Icon(Icons.settings, color: AppColors.secoundryColor),
            Icon(Icons.phone, color: AppColors.secoundryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 0.8, color: AppColors.backgroundColor),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSize(context).smallText1),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildCompletionChecklist() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text('✅ ${AppText(context).completionChecklist}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSize(context).smallText1)),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                bookingDetailsModel?.objTickets.maintenanceTickets?.length ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: AppColors(context).primaryColor.withOpacity(0.3),
                      width: 1),
                ),
                contentPadding: EdgeInsets.zero,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.diamond,
                      color: AppColors(context).primaryColor),
                ),
                title: Text(
                  bookingDetailsModel?.objTickets.maintenanceTickets?[index]
                          ["name"] ??
                      "",
                  style: TextStyle(
                      fontSize: AppSize(context).smallText2,
                      color: AppColors.blackColor1),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future getBookingDetails() async {
    if (!mounted) return;
    
    setState(() {
      loading = true;
    });
    
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Check if user is B2B user (MMS users: Admin 18, Team Leader 20, Technician 21, Sub-Technician 22)
      final currentUserRoleId = appProvider.userModel?.customer.roleId;
      final roleIdInt = currentUserRoleId is int 
          ? currentUserRoleId 
          : (currentUserRoleId is String 
              ? int.tryParse(currentUserRoleId.toString()) 
              : null);
      final isCompanyAdmin = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22);
      
      // Get booking details from OMS/MMS API (single call - HttpHelper handles token refresh)
      BookingDetailsModel? bookingDetails;
      try {
        bookingDetails = await BookingApi.getBookingDetails(
          token: appProvider.accessToken ?? appProvider.userModel?.token ?? "",
              id: widget.id,
          isCompanyAdmin: isCompanyAdmin,
        ).timeout(
          const Duration(seconds: 15), // Increased timeout for token refresh
          onTimeout: () {
            return null;
          },
        ).catchError((e) {
          return null;
        });
      } catch (e) {
        bookingDetails = null;
      }
      
      if (!mounted) {
        return;
      }
      
      // For B2B users, extract fullTicketData from bookingDetails response
      if (isCompanyAdmin && bookingDetails != null) {
        try {
          // Fetch full ticket data from MMS API using HttpHelper (with token refresh)
          final mmsUrl = '${EndPoints.mmsBaseUrl}tickets/${widget.id}';
          
          final mmsResponse = await HttpHelper.getData2(
            query: mmsUrl,
            token: appProvider.accessToken ?? appProvider.userModel?.token ?? "",
            context: context,
          );
          
          if (mmsResponse.statusCode == 200) {
            try {
              final body = json.decode(mmsResponse.body);
              if (body['success'] == true && body['data'] != null) {
                if (mounted) {
        setState(() {
                    fullTicketData = body['data'];
                    bookingDetailsModel = bookingDetails;
          loading = false;
        });
                }
              } else {
                if (mounted) {
                  setState(() {
                    bookingDetailsModel = bookingDetails;
                    loading = false;
                  });
                }
              }
    } catch (e) {
              if (mounted) {
      setState(() {
                  bookingDetailsModel = bookingDetails;
        loading = false;
      });
              }
            }
          } else if (mmsResponse.statusCode == 404) {
            if (mounted) {
              setState(() {
                loading = false;
                fullTicketData = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket not found or not assigned to you. You can only view tickets assigned to you.'),
                  backgroundColor: Colors.red[600],
                  duration: const Duration(seconds: 5),
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              });
              return;
            }
          } else if (mmsResponse.statusCode == 401 || mmsResponse.statusCode == 403) {
            if (mounted) {
              setState(() {
                loading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Authentication error. Please login again.'),
                  backgroundColor: Colors.red[600],
                  duration: const Duration(seconds: 5),
                ),
              );
              return;
            }
          } else {
            // Continue with bookingDetails even if fullTicketData failed
            if (mounted) {
              setState(() {
                bookingDetailsModel = bookingDetails;
                loading = false;
              });
            }
          }
        } catch (e) {
          // Continue with bookingDetails even if fullTicketData failed
          if (mounted) {
            setState(() {
              bookingDetailsModel = bookingDetails;
              loading = false;
            });
          }
        }
      } else {
        // For OMS users or if bookingDetails is null
        if (mounted) {
          setState(() {
            bookingDetailsModel = bookingDetails;
            loading = false;
          });
        }
      }
      
      // Safety check: ensure loading is always set to false
      if (mounted && loading == true) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ticket details: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always ensure loading is false
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _navigateToEditTicket(BuildContext context, {bool isTechnician = false}) async {
    try {
      AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
      
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get full ticket data from MMS API
      final response = await http.get(
        Uri.parse('${EndPoints.mmsBaseUrl}tickets/${widget.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authorization': 'Bearer $token',
          'x-client-type': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final ticketData = body['data'];
          
          // Navigate to edit screen with ticket data
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUpdateTicketScreenV2(
                ticketData: ticketData,
                isTechnician: isTechnician,
              ),
            ),
          );
          
          // Refresh ticket details if update was successful
          if (result == true) {
            getBookingDetails();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load ticket data for editing'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthHelper.handleAuthError(context, isMMS: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ticket: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('_navigateToEditTicket error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.greyColor5,
                fontSize: AppSize(context).smallText2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.blackColor1,
                fontSize: AppSize(context).smallText2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      } else if (date is DateTime) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  String _formatDateTime(dynamic dateTime) {
    try {
      if (dateTime is String) {
        final parsed = DateTime.parse(dateTime);
        return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      } else if (dateTime is DateTime) {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      return dateTime.toString();
    } catch (e) {
      return dateTime.toString();
    }
  }


  // Calculate estimated time from time slot (ticketTimeFrom and ticketTimeTo)
  String _calculateEstimatedTime() {
    // Try to get from fullTicketData first (B2B), then from bookingDetailsModel
    String? timeFrom;
    String? timeTo;
    
    if (fullTicketData != null) {
      timeFrom = fullTicketData!['ticketTimeFrom']?.toString();
      timeTo = fullTicketData!['ticketTimeTo']?.toString();
    }
    // Note: bookingDetailsModel doesn't have timeFrom/timeTo fields directly
    // Estimated time is already calculated in bookings_apis.dart from time slot
    
    if (timeFrom != null && timeTo != null) {
      try {
        // Parse time strings (format: "HH:MM:SS" or "HH:MM")
        final fromParts = timeFrom.split(':');
        final toParts = timeTo.split(':');
        
        if (fromParts.length >= 2 && toParts.length >= 2) {
          final fromHour = int.tryParse(fromParts[0]) ?? 0;
          final fromMinute = int.tryParse(fromParts[1]) ?? 0;
          final toHour = int.tryParse(toParts[0]) ?? 0;
          final toMinute = int.tryParse(toParts[1]) ?? 0;
          
          // Calculate difference in minutes
          final fromTotalMinutes = fromHour * 60 + fromMinute;
          final toTotalMinutes = toHour * 60 + toMinute;
          final diffMinutes = toTotalMinutes - fromTotalMinutes;
          
          if (diffMinutes > 0) {
            // Convert to hours
            if (diffMinutes >= 60) {
              final hours = diffMinutes ~/ 60;
              final minutes = diffMinutes % 60;
              if (minutes > 0) {
                final hoursDecimal = hours + (minutes / 60);
                return '${hoursDecimal.toStringAsFixed(1)} ${AppText(context).hours}';
              } else {
                return '$hours ${AppText(context).hours}';
              }
            } else {
              return '${(diffMinutes / 60).toStringAsFixed(1)} ${AppText(context).hours}';
            }
          }
        }
      } catch (e) {
        log('Error calculating estimated time: $e');
      }
    }
    
    // Fallback to esitmatedTime from bookingDetailsModel or default
    final estimatedTime = bookingDetailsModel?.objTickets.esitmatedTime;
    if (estimatedTime != null && estimatedTime.isNotEmpty) {
      return '$estimatedTime ${AppText(context).hours}';
    }
    
    return '2 ${AppText(context).hours}'; // Default to 2 hours
  }

  // Get parts required from table (withMaterial)
  String _getPartsRequired() {
    // Try to get from fullTicketData first (B2B), then from bookingDetailsModel
    bool? withMaterial;
    
    if (fullTicketData != null && fullTicketData!['withMaterial'] != null) {
      withMaterial = fullTicketData!['withMaterial'] as bool?;
    } else if (bookingDetailsModel?.objTickets.isWithMaterial != null) {
      withMaterial = bookingDetailsModel!.objTickets.isWithMaterial;
    }
    
    return (withMaterial == true) ? AppText(context).yes : AppText(context).no;
  }

  // Get having female engineer from table (havingFemaleEngineer)
  int _getAttachmentsCount() {
    // Get attachments count from fullTicketData (B2B) or bookingDetailsModel
    if (fullTicketData != null && fullTicketData!['files'] != null) {
      final files = fullTicketData!['files'] as List;
      return files.length;
    } else if (bookingDetailsModel?.objTickets.ticketAttatchments != null) {
      return bookingDetailsModel!.objTickets.ticketAttatchments.length;
    }
    return 0;
  }

  String _getHavingFemaleEngineer() {
    // Try to get from fullTicketData first (B2B), then from bookingDetailsModel
    bool? havingFemale;
    
    if (fullTicketData != null && fullTicketData!['havingFemaleEngineer'] != null) {
      havingFemale = fullTicketData!['havingFemaleEngineer'] as bool?;
    } else if (bookingDetailsModel?.objTickets.isWithFemale != null) {
      havingFemale = bookingDetailsModel!.objTickets.isWithFemale;
    }
    
    return (havingFemale == true) ? AppText(context).yes : AppText(context).no;
  }
}

// Widget for displaying ticket location on Google Maps (read-only)
class _TicketLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationDescription;
  final String locationMap;

  const _TicketLocationMap({
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.locationMap,
  });

  @override
  State<_TicketLocationMap> createState() => _TicketLocationMapState();
}

class _TicketLocationMapState extends State<_TicketLocationMap> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Validate location coordinates before creating LatLng
    if (widget.latitude.isNaN || widget.longitude.isNaN ||
        widget.latitude.isInfinite || widget.longitude.isInfinite ||
        (widget.latitude == 0.0 && widget.longitude == 0.0) ||
        widget.latitude < -90 || widget.latitude > 90 ||
        widget.longitude < -180 || widget.longitude > 180) {
      return;
    }
    
    // Clamp coordinates to valid ranges
    final clampedLat = widget.latitude.clamp(-90.0, 90.0);
    final clampedLng = widget.longitude.clamp(-180.0, 180.0);
    final validLocation = LatLng(clampedLat, clampedLng);
    
    // Create marker for ticket location
    _markers.add(
      Marker(
        markerId: const MarkerId('ticket_location'),
        position: validLocation,
        infoWindow: InfoWindow(
          title: 'Ticket Location',
          snippet: widget.locationDescription.isNotEmpty 
              ? widget.locationDescription 
              : '${widget.latitude}, ${widget.longitude}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // STRICT validation: Do not create GoogleMap if coordinates are invalid
    // This prevents FormatException: It was not possible to obtain target position (Target 0)
    final hasValidLat = !widget.latitude.isNaN && 
                       !widget.latitude.isInfinite &&
                       widget.latitude != 0.0 &&
                       widget.latitude >= -90 && 
                       widget.latitude <= 90;
    
    final hasValidLng = !widget.longitude.isNaN && 
                       !widget.longitude.isInfinite &&
                       widget.longitude != 0.0 &&
                       widget.longitude >= -180 && 
                       widget.longitude <= 180;
    
    if (!hasValidLat || !hasValidLng) {
      log('_TicketLocationMap: Invalid coordinates - lat=${widget.latitude}, lng=${widget.longitude}, hasValidLat=$hasValidLat, hasValidLng=$hasValidLng');
      return Container(
        height: AppSize(context).height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Invalid location coordinates',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    // Clamp coordinates to valid ranges to prevent FormatException
    final clampedLat = widget.latitude.clamp(-90.0, 90.0);
    final clampedLng = widget.longitude.clamp(-180.0, 180.0);
    
    // Final safety check before creating LatLng
    if (clampedLat == 0.0 && clampedLng == 0.0) {
      log('_TicketLocationMap: Clamped coordinates are (0,0) - rejecting');
      return Container(
        height: AppSize(context).height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Invalid location coordinates',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    final location = LatLng(clampedLat, clampedLng);
    
    return Container(
      height: AppSize(context).height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                // Final safety check: ensure location is never (0,0)
                target: (location.latitude == 0.0 && location.longitude == 0.0)
                    ? const LatLng(31.915079, 35.883758) // Default location (Amman, Jordan)
                    : location,
                zoom: 15.0,
              ),
              markers: _markers,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  // Animate to location after map is created (with delay to ensure map is ready)
                  // Only animate if location is valid
                  if (location.latitude != 0.0 && location.longitude != 0.0 &&
                      !location.latitude.isNaN && !location.longitude.isNaN &&
                      !location.latitude.isInfinite && !location.longitude.isInfinite) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _animateToLocation(location);
                      }
                    });
                  } else {
                    log('Skipping camera animation - invalid location: ${location.latitude}, ${location.longitude}');
                  }
                }
              },
            ),
          ),
          // Button to open in Google Maps
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.extended(
              onPressed: () => _openInGoogleMaps(),
              backgroundColor: AppColors(context).primaryColor,
              icon: const Icon(Icons.map, color: Colors.white),
              label: Text(
                'Open in Maps',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _animateToLocation(LatLng location) async {
    try {
      // Validate location coordinates before animating
      if (location.latitude.isNaN || location.longitude.isNaN ||
          location.latitude.isInfinite || location.longitude.isInfinite ||
          (location.latitude == 0.0 && location.longitude == 0.0) ||
          location.latitude < -90 || location.latitude > 90 ||
          location.longitude < -180 || location.longitude > 180) {
        log('Invalid location coordinates: lat=${location.latitude}, lng=${location.longitude}');
        return;
      }
      
      // Clamp coordinates to valid ranges
      final clampedLat = location.latitude.clamp(-90.0, 90.0);
      final clampedLng = location.longitude.clamp(-180.0, 180.0);
      final validLocation = LatLng(clampedLat, clampedLng);
      
      // Check if controller is ready
      if (!_controller.isCompleted) {
        log('Controller not ready yet, waiting...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final GoogleMapController controller = await _controller.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('Timeout waiting for map controller');
          throw TimeoutException('Map controller timeout');
        },
      );
      
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: validLocation,
            zoom: 15.0,
          ),
        ),
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          log('Timeout animating camera');
        },
      );
    } catch (e) {
      log('Error animating camera: $e');
    }
  }

  Future<void> _openInGoogleMaps() async {
    try {
      // Try multiple methods to open Google Maps
      // Method 1: Use google.navigation: scheme (Android - most reliable)
      final googleNavUrl = 'google.navigation:q=${widget.latitude},${widget.longitude}';
      final googleNavUri = Uri.parse(googleNavUrl);
      
      // Method 2: Use geo: scheme (works on Android and iOS)
      final geoUrl = 'geo:${widget.latitude},${widget.longitude}?q=${widget.latitude},${widget.longitude}';
      final geoUri = Uri.parse(geoUrl);
      
      // Method 3: Use https://maps.google.com (fallback - opens in browser)
      final mapsUrl = 'https://maps.google.com/?q=${widget.latitude},${widget.longitude}';
      final mapsUri = Uri.parse(mapsUrl);
      
      // Try google.navigation: scheme first (Android - opens Google Maps app directly)
      try {
        if (await canLaunchUrl(googleNavUri)) {
          await launchUrl(googleNavUri, mode: LaunchMode.externalNonBrowserApplication);
          log('Opened Google Maps using google.navigation: scheme');
          return;
        }
      } catch (e) {
        log('Failed to launch google.navigation: scheme: $e');
      }
      
      // Try geo: scheme (works on both Android and iOS)
      try {
        if (await canLaunchUrl(geoUri)) {
          await launchUrl(geoUri, mode: LaunchMode.externalNonBrowserApplication);
          log('Opened Google Maps using geo: scheme');
          return;
        }
      } catch (e) {
        log('Failed to launch geo: scheme: $e');
      }
      
      // Fallback to https://maps.google.com (opens in browser or app)
      try {
        if (await canLaunchUrl(mapsUri)) {
          await launchUrl(mapsUri, mode: LaunchMode.platformDefault);
          log('Opened Google Maps using https://maps.google.com');
          return;
        }
      } catch (e) {
        log('Failed to launch maps.google.com: $e');
      }
      
      // If all methods fail, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps. Please install Google Maps app.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      log('Error opening Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
