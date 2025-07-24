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
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/contact_model.dart';
import 'package:wefix/Data/model/questions_model.dart';
import 'package:wefix/Presentation/Profile/Components/rateSheet_widget.dart';
import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

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

  ContactModel? infoContactModel;
  QuestionsModel? questionsModel;

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
    getQuestions();
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(
        actions: [const LanguageButton()],
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
                      _listTile(
                          infoContactModel?.languages.emegancyPhone
                                  .toString() ??
                              "",
                          const Icon(
                            Icons.call,
                            color: AppColors.redColor,
                          ),
                          AppText(context).call,
                          Colors.red,
                          "tel:"),
                      _listTile(
                          "${infoContactModel?.languages.email}",
                          Icon(
                            Icons.mail,
                            color: AppColors(context).primaryColor,
                          ),
                          AppText(context).send,
                          Colors.green,
                          "mailto:"),
                      _listTile(
                          infoContactModel?.languages.whatsapp ?? "0798100944",
                          SvgPicture.asset(
                            "assets/icon/whatsapp.svg",
                            height: 20,
                            width: 20,
                          ),
                          AppText(context).send,
                          Colors.green,
                          "https://wa.me/${infoContactModel?.languages.whatsapp ?? "+962798100944"}?text=مرحبااا ، أنا حاب أعرف أكتر عن خدمات الصيانة اللي بتقدموها. ممكن تحكولي شو العروض المتوفرة عندكم؟"),
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
                          // Navigator.push(
                          //   context,
                          //   rightToLeft(
                          //     const CommentsScreenById(
                          //       chatId: "1",
                          //       image: "assets/image/icon_logo.png",
                          //       name: "WeFix Support",
                          //       contactId: "32",
                          //       index: 0,
                          //       reqId: 1,
                          //     ),
                          //   ),
                          // );
                        }),
                      ]),
                    ],
                  ),
                  // spacing,
                  // _sectionContainer(
                  //   title: AppText(context).caht,
                  //   children: [
                  //     Text(AppText(context).welcomePleaseenteryourdetailsbelow),
                  //     spacing,
                  //     _textField(AppText(context).fullName, name),
                  //     _textField(AppText(context).email, email),
                  //     const SizedBox(height: 8),
                  //     Text(AppText(context).supportType,
                  //         style: const TextStyle(fontWeight: FontWeight.w500)),
                  //     spacing,
                  //     Wrap(
                  //       spacing: 10,
                  //       children: [
                  //         _chip("Complaint", "Complaint"),
                  //         _chip("Suggestion", "Suggestion"),
                  //         _chip("Remark", "Remark"),
                  //       ],
                  //     )
                  //   ],
                  // ),
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
                        _actionItem("assets/icon/instagram-svgrepo-com.svg",
                            "Instagram", "Follow", () {
                          _launchUrl(
                              infoContactModel?.languages.instagram ?? "0");
                        }),
                        _actionItem("assets/icon/linkedin-svgrepo-com.svg",
                            "linkedin", "Follow", () {
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
                    title: AppText(context).contactUs,
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

  Future getQuestions() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ReviewsApi.getQuestionsReviews(token: appProvider.userModel?.token ?? "")
          .then((value) {
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

  Widget _listTile(
      String text, Widget icon, String action, Color color, String? type) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: icon,
        title: Text(
          text,
          textAlign: TextAlign.start,
        ),
        trailing: TextButton(
          onPressed: () => _launchUrl("${type ?? "tel:"}$text"),
          child: Text(action,
              style: TextStyle(color: AppColors(context).primaryColor)),
        ),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                icon,
                height: AppSize(context).height * .05,
                width: AppSize(context).height * .05,
              ),
            ),
            const SizedBox(height: 5),
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
}
