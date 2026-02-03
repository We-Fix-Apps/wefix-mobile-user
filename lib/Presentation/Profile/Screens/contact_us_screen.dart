import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Contact/contact_apis.dart';
import 'package:wefix/Business/Reviews/reviews_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/contact_model.dart';
import 'package:wefix/Data/model/questions_model.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/Profile/Components/rateSheet_widget.dart';
import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String? selectedSupportType;
  bool loading = false;
  bool loading2 = false;
  bool loading3 = false;
  ContactModel? infoContactModel;
  QuestionsModel? questionsModel;

  TextEditingController type = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController details = TextEditingController();

  @override
  void initState() {
    Future.wait([getContactInfo(), getQuestions()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText(context);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: const [LanguageButton()],
        leading: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return MultiRateSheet(
                  questionsModel: questionsModel,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              "assets/icon/smile.svg",
              color: AppColors(context).primaryColor,
              width: 20,
              height: 20,
            ),
          ),
        ),
        title: Text(text.contactUs),
        centerTitle: true,
        elevation: 1,
      ),
      body: loading
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  /// Call Us
                  _sectionContainer(
                    title: text.callUs,
                    children: [
                      listTile(
                        text: text.forEmergencies,
                        lead: const Text(
                          '911',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.redColor,
                          ),
                        ),
                        action: text.call,
                        onTap: () => _launchUrl(
                          "tel:${infoContactModel?.languages.emegancyPhone}",
                        ),
                      ),
                      listTile(
                        text: text.callCenter,
                        lead: const Text(
                          '911',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.redColor,
                          ),
                        ),
                        action: text.call,
                        onTap: () => _launchUrl(
                          "tel:${infoContactModel?.languages.phone}",
                        ),
                      ),
                      listTile(
                        text: text.whatsapp,
                        lead: SvgPicture.asset(
                          "assets/icon/whatsapp.svg",
                          height: 30,
                          width: 30,
                        ),
                        action: text.send,
                        onTap: () => callUsWhatsApp(),
                      ),
                    ],
                  ),

                  /// Ask Question
                  _sectionContainer(
                    title: text.askQuestion,
                    children: [
                      _optionRow([
                        _actionItem(
                          "assets/icon/email.svg",
                          text.email,
                          () => _launchUrl(
                            "mailto:${infoContactModel?.languages.email}",
                          ),
                        ),
                        _actionItem(
                          "assets/icon/faq.svg",
                          text.faq,
                          () => _launchUrl("https://wefixjo.com/#faq"),
                        ),
                        _actionItem(
                          "assets/icon/chat.svg",
                          text.chat,
                          () => _launchUrl(
                            "https://wefixjo.com/Contact/Index",
                          ),
                        ),
                      ]),
                    ],
                  ),

                  /// Social Media
                  _sectionContainer(
                    title: text.socialMedia,
                    children: [
                      const SizedBox(height: 5),
                      _optionRow([
                        _actionItem(
                          "assets/icon/facebook.svg",
                          text.facebook,
                          () => _launchUrl(
                            infoContactModel?.languages.facebook ?? "",
                          ),
                        ),
                        _actionItem(
                          "assets/icon/instagram-svgrepo-com.svg",
                          text.instgram,
                          () => _launchUrl(
                            infoContactModel?.languages.instagram ?? "",
                          ),
                        ),
                        _actionItem(
                          "assets/icon/linkedin-svgrepo-com.svg",
                          text.linkedIn,
                          () => _launchUrl(
                            infoContactModel?.languages.twitter ?? "",
                          ),
                        ),
                        _actionItem(
                          "assets/icon/youtube.svg",
                          text.youtube,
                          () => _launchUrl(
                            infoContactModel?.languages.youtube ?? "",
                          ),
                        ),
                      ]),
                    ],
                  ),

                  /// Contact Form
                  if (appProvider.userModel != null)
                    _sectionContainer(
                      title: text.submitFeedback,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            SvgPicture.asset(
                              "assets/icon/chat.svg",
                              height: 30,
                              width: 30,
                              color: AppColors.greyColor4,
                            ),
                            Expanded(
                              child: Text(
                                text.weValueYourTime,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSupportType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.blackColor1,
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          hint: Text(
                            text.type,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.greyColor2,
                            ),
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: AppColors.greyColor3,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: AppColors.greyColor3,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: AppColors.greyColor3,
                              ),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: "Suggestion",
                              child: Text(text.suggestion),
                            ),
                            DropdownMenuItem(
                              value: "Complaint",
                              child: Text(text.complaint),
                            ),
                            DropdownMenuItem(
                              value: "Remarks",
                              child: Text(text.remarks),
                            ),
                          ],
                          onChanged: (value) => setState(() => selectedSupportType = value),
                        ),
                        WidgetTextField(
                          text.details,
                          controller: details,
                          maxLines: 3,
                          fillColor: AppColors.whiteColor1,
                        ),
                        const SizedBox(height: 5),
                        CustomBotton(
                          height: 40,
                          title: text.send,
                          loading: loading3,
                          onTap: () => addContactInfo(),
                        ),
                      ],
                    ),

                  /// Location
                  _sectionContainer(
                    title: text.wefixLocation,
                    children: [
                      if (loading)
                        LoadingText(
                          width: AppSize(context).width,
                          height: 200,
                        )
                      else
                        InkWell(
                          onTap: () => openGoogleMap(),
                          child: WidgewtGoogleMaps(
                            isConntactUs: true,
                            lat: double.parse(
                              infoContactModel?.languages.latitude ?? "0",
                            ),
                            loang: double.parse(
                              infoContactModel?.languages.longitude ?? "0",
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future getContactInfo() async {
    setState(() => loading = true);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ContactsApis.getContactInfo(token: appProvider.userModel?.token ?? "").then((value) {
        setState(() {
          infoContactModel = value;
          loading = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() => loading = false);
    }
  }

  Future getQuestions() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ReviewsApi.getQuestionsReviews(token: appProvider.userModel?.token ?? "").then((value) {
        setState(() {
          questionsModel = value;
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

  Future addContactInfo() async {
    setState(() => loading3 = true);
    await ContactsApis.contactUsForm(details: details.text, subject: subject.text, type: selectedSupportType ?? "Suggestion", context: context).then((value) async {
      if (value != null) {
        setState(() => loading3 = false);
        details.clear();
        subject.clear();
        selectedSupportType = null;
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).successfully,
            desc: AppText(context, isFunction: true).sucessSendYourMessage,
            isError: false,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).warning,
            desc: AppText(context, isFunction: true).someThingError,
            isError: true,
          ),
        );
        setState(() => loading3 = false);
      }
    });
  }

  Widget listTile({required String text, required Widget lead, required String action, VoidCallback? onTap}) {
    return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: lead,
        title: Text(text, textAlign: TextAlign.start, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.blackColor1)),
        trailing: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
             width: 80,
             alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(border: Border.all(color: AppColors(context).primaryColor), borderRadius: BorderRadius.circular(7)),
            child: Text(action, style: const TextStyle(color: Colors.black, fontSize: 13)),
          ),
        ));
  }

  Widget _actionItem(String icon, String label, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          spacing: 5,
          children: [
            SvgPicture.asset(icon, height: 35, width: 35),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSize(context).smallText3)),
          ],
        ),
      ),
    );
  }

  Widget _optionRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Widget _sectionContainer({required String title, required List<Widget> children}) {
    return Container(
      width: AppSize(context).width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...children,
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> callUsWhatsApp() async {
    final phone = (infoContactModel?.languages.whatsapp ?? "962798100944").replaceAll("+", "");
    final message = Uri.encodeComponent("مرحباً بك 👋\n"
        "يسعدنا تواصلك مع خدمة عملاء WeFix 😊\n"
        "خبرنا كيف نقدر نساعدك؟");
    final url = "https://wa.me/$phone?text=$message";
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openGoogleMap() async {
    final lat = double.parse(infoContactModel?.languages.latitude ?? "0");
    final lng = double.parse(infoContactModel?.languages.longitude ?? "0");
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }
}
