import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/booking_details_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Components/rating_widget.dart';

import '../../appointment/Components/attachments_widget.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String id;

  const TicketDetailsScreen({super.key, required this.id});
  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  bool? loading = false;
  BookingDetailsModel? bookingDetailsModel;

  @override
  void initState() {
    getBookingDetails();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
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
                  bookingDetailsModel?.objTickets.isReated == true
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
                                    bookingDetailsModel?.objTickets.isReated ??
                                        false,
                              ),
                            ).whenComplete(() => getBookingDetails());
                          })
                ],
              ),
            )
          : const SizedBox(),
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
                  WidgetCachNetworkImage(
                    image: "${bookingDetailsModel?.objTickets.qrCodePath}",
                    height: AppSize(context).height * 0.4,
                    width: AppSize(context).width,
                  ),
                  const Divider(
                    color: AppColors.backgroundColor,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                            leftValue: bookingDetailsModel?.objTickets.title),
                        _buildRow(
                            AppText(context).type, AppText(context).createdDate,
                            leftValue: bookingDetailsModel?.objTickets.type,
                            rightValue: bookingDetailsModel?.objTickets.date
                                .toString()
                                .substring(0, 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // _buildSection('👤 ${AppText(context).customerDetails}',
                  //     _buildCustomerDetails()),
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
                                  "${bookingDetailsModel?.objTickets.esitmatedTime} ${AppText(context).hours}",
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSize(context).smallText2)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("🔩 ${AppText(context).partsrequired} : ",
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontSize: AppSize(context).smallText2)),
                              Text(
                                  bookingDetailsModel
                                              ?.objTickets.isWithMaterial ==
                                          true
                                      ? AppText(context).yes
                                      : AppText(context).no,
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSize(context).smallText2)),
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
                                  bookingDetailsModel
                                              ?.objTickets.isWithFemale ==
                                          true
                                      ? AppText(context).yes
                                      : AppText(context).no,
                                  style: TextStyle(
                                      color: AppColors.blackColor1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSize(context).smallText2)),
                            ],
                          ),
                        ],
                      )),
                  const Divider(
                    color: AppColors.backgroundColor,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("📎 ${AppText(context).attachments}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize(context).smallText1)),
                      InkWell(
                        onTap: () => showAttachmentBottomSheet(context),
                        child: Text(
                          AppText(context).viewAll,
                          style: TextStyle(
                              color: AppColors.secoundryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize(context).smallText2),
                        ),
                      ),
                    ],
                  ),
                  _buildSection(
                      '🔨 ${AppText(context).requiredTools}',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bookingDetailsModel?.objTickets.ticketTools
                                ?.map((tool) => Chip(
                                      label: Text(tool.title ?? ""),
                                      backgroundColor: AppColors(context)
                                          .primaryColor
                                          .withOpacity(.3),
                                    ))
                                .toList() ??
                            [],
                      )),
                  const Divider(
                    color: AppColors.backgroundColor,
                  ),
                  bookingDetailsModel?.objTickets.type.toLowerCase() ==
                          "preventive"
                      ? _buildCompletionChecklist()
                      : const SizedBox(),
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
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
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
                    return AttachmentsWidget(
                      image: bookingDetailsModel
                          ?.objTickets.ticketAttatchments?[index].filePath
                          .toString()
                          .split("-")
                          .last,
                      url: bookingDetailsModel
                          ?.objTickets.ticketAttatchments?[index].filePath,
                    );
                  },
                  itemCount: bookingDetailsModel
                      ?.objTickets.ticketAttatchments?.length,
                  shrinkWrap: true),
              const SizedBox(height: 10),
            ],
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
          Row(
            children: [
              SizedBox(
                child: Text("${right} : ",
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
                  bookingDetailsModel
                          ?.objTickets.maintenanceTickets?[index].name ??
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
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.getBookingDetails(
              token: appProvider.userModel?.token ?? "", id: widget.id)
          .then((value) {
        setState(() {
          bookingDetailsModel = value;
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
