import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/Contact/contact_apis.dart';
import 'package:wefix/Business/Reviews/reviews_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/contact_model.dart';
import 'package:wefix/Data/model/questions_model.dart';
import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Profile/Components/rateSheet_widget.dart';
import 'package:wefix/Presentation/Profile/Components/rate_sheet_step_three_widget.dart';
import 'package:wefix/Presentation/Profile/Components/rate_sheet_step_tow_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/Chat/messages_screen.dart';

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

  QuestionsModel? questionsModel;
  ContactModel? infoContactModel;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController type = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController details = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getContactInfo();
    getQuestionsReviews();
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(
        actions: [const LanguageButton()],
        leading: InkWell(
          onTap: () => showRateSheet(context),
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
        title: Text(AppText(context).contactUs),
        centerTitle: true,
        elevation: 1,
      ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionContainer(
                    title: AppText(context).emergency,
                    children: [
                      _listTile(AppText(context).callforemergency, Icons.call,
                          AppText(context).call, Colors.red),
                      _listTile(
                          "${infoContactModel?.languages.emegancyPhone}",
                          Icons.support_agent,
                          AppText(context).call,
                          Colors.green),
                    ],
                  ),
                  spacing,
                  _sectionContainer(
                    title: AppText(context).askQuestion,
                    children: [
                      _optionRow([
                        _actionItem("assets/icon/email.svg",
                            AppText(context).email, "Send", () {
                          _launchUrl(
                              "mailto:${infoContactModel?.languages.email}");
                        }),
                        _actionItem("assets/icon/faq.svg", "FAQ", "Open", () {
                          _launchUrl("https://wefix.com/faq");
                        }),
                        _actionItem("assets/icon/chat.svg",
                            AppText(context).caht, "Open", () {
                          Navigator.push(
                            context,
                            rightToLeft(
                              const CommentsScreenById(
                                chatId: "1",
                                image: "assets/image/icon_logo.png",
                                name: "WeFix Support",
                                contactId: "32",
                                index: 0,
                                reqId: 1,
                              ),
                            ),
                          );
                        }),
                      ]),
                    ],
                  ),
                  spacing,
                  _sectionContainer(
                    title: AppText(context).caht,
                    children: [
                      Text(AppText(context).welcomePleaseenteryourdetailsbelow),
                      spacing,
                      _textField(AppText(context).fullName, name),
                      _textField(AppText(context).email, email),
                      const SizedBox(height: 8),
                      Text(AppText(context).supportType,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      spacing,
                      Wrap(
                        spacing: 10,
                        children: [
                          _chip("Complaint", "Complaint"),
                          _chip("Suggestion", "Suggestion"),
                          _chip("Remark", "Remark"),
                        ],
                      )
                    ],
                  ),
                  spacing,
                  _sectionContainer(
                    title: AppText(context).weFixStations,
                    children: [
                      WidgewtGoogleMaps(
                        isFromCheckOut: true,
                        isHaveRadius: true,
                        lat: double.parse(
                            infoContactModel?.languages.latitude ?? "0"),
                        loang: double.parse(
                            infoContactModel?.languages.longitude ?? "0"),
                      )
                    ],
                  ),
                  spacing,
                  _sectionContainer(
                    title: AppText(context).socialMedia,
                    children: [
                      _optionRow([
                        _actionItem(
                            "assets/icon/facebook.svg", "Facebook", "Like", () {
                          _launchUrl(
                              infoContactModel?.languages.facebook ?? "0");
                        }),
                        _actionItem(
                            "assets/icon/instagram.svg", "Instagram", "Follow",
                            () {
                          _launchUrl(
                              infoContactModel?.languages.instagram ?? "0");
                        }),
                        _actionItem("assets/icon/x.svg", "X", "Follow", () {
                          _launchUrl(
                              infoContactModel?.languages.twitter ?? "0");
                        }),
                        _actionItem(
                            "assets/icon/youtube.svg", "YouTube", "Subscribe",
                            () {
                          _launchUrl(
                              infoContactModel?.languages.youtube ?? "0");
                        }),
                      ]),
                    ],
                  ),
                  spacing,
                  _sectionContainer(
                    title: AppText(context).submit,
                    children: [
                      _textField(
                        AppText(context).fullName,
                        name,
                      ),
                      _textField(AppText(context).phone, phoneNumber),
                      _textField(AppText(context).email, email),
                      _dropdownField(AppText(context).type,
                          ["Suggestion", "Complaint", "Remarks"]),
                      _textField(AppText(context).subject, subject),
                      _textField(
                          AppText(context).details, maxLines: 4, details),
                      spacing,
                      CustomBotton(
                        title: AppText(context).submit,
                        loading: loading3,
                        onTap: () {
                          addContactInfo();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Future getContactInfo() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ContactsApis.getContactInfo(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          infoContactModel = value;
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
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => loading3 = true);
    await ContactsApis.contactUsForm(
      phone: phoneNumber.text ?? "",
      name: name.text,
      details: details.text,
      subject: subject.text,
      type: selectedSupportType ?? "Suggestion",
      email: email.text,
      context: context,
    ).then((value) async {
      if (value != null) {
        setState(() => loading3 = false);
        name.clear();
        phoneNumber.clear();
        details.clear();
        email.clear();
        subject.clear();
        email.clear();
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

  Widget _listTile(String text, IconData icon, String action, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: TextButton(
        onPressed: () => _launchUrl("tel:$text"),
        child: Text(action,
            style: TextStyle(color: AppColors(context).primaryColor)),
      ),
    );
  }

  Widget _actionItem(
      String icon, String label, String action, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
              radius: 28,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(icon),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize(context).smallText3)),
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

  Widget _textField(String label, TextEditingController? controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WidgetTextField(label, controller: controller),
    );
  }

  Widget _dropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: AppSize(context).width,
        height: AppSize(context).height * 0.06,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.greyColor3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedSupportType,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(label),
              ),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSupportType = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionContainer(
      {required String title, String? desc, required List<Widget> children}) {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (desc != null) ...[
            const SizedBox(height: 12),
            Text(desc),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final isSelected = selectedSupportType == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSupportType = value;
        });
      },
      child: Chip(
        side: BorderSide(
          color: isSelected
              ? AppColors(context).primaryColor
              : AppColors.whiteColor1,
        ),
        label: Text(label),
        backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: AppColors(context).primaryColor),
        shape: StadiumBorder(
          side: BorderSide(color: AppColors(context).primaryColor),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showRateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, set) {
          return MultiRateSheet(
            questionsModel: questionsModel,
          );
        });
      },
    );
  }

  // void showRateSheetStepTow(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return RateSheetStepTow(
  //         onTap: () {
  //           pop(context);
  //           showRateSheetStepThree(context);
  //         },
  //       );
  //     },
  //   );
  // }

  // void showRateSheetStepThree(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return RateSheetStepThree();
  //     },
  //   );
  // }

  Future getQuestionsReviews() async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ReviewsApi.getQuestionsReviews(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          questionsModel = value;
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
