import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Loading/loading_about.dart';

class ContentScreen extends StatefulWidget {
  final bool? isTerms;
  final bool? isAbout;
  final bool? isPrivacy;
  const ContentScreen({
    super.key,
    this.isTerms = false,
    this.isAbout = false,
    this.isPrivacy = false,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  bool loading = false;
  String? html;
  String? htmlAr;

  String? title;

  @override
  void initState() {
    if (widget.isAbout == true) {
      getAbout();
    } else if (widget.isPrivacy == true) {
      getPrivacy();
    } else {
      getTerms();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: const [
          LanguageButton(),
        ],
        centerTitle: true,
        title: Text(
          title ?? '',
          style: TextStyle(
            fontSize: AppSize(context).mediumText3,
            color: AppColors.whiteColor1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: AppSize(context).width * 0.05,
            vertical: AppSize(context).height * 0.02),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            loading == true
                ? const LoadingAbouUs()
                : languageProvider.lang == "ar"
                    ? HtmlWidget(html ?? '')
                    : HtmlWidget(htmlAr ?? ''),
          ],
        ),
      ),
    );
  }

  Future getAbout() async {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.getAboutUs().then((value) {
      if (mounted) {
        setState(() {
          html =
              languageProvider.lang == "ar" ? value["aboutAr"] : value["about"];

          htmlAr = value["aboutAr"];
          title = value[0];
          loading = false;
        });
      }
    });
  }

  Future getPrivacy() async {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.getAboutUs().then((value) {
      if (mounted) {
        setState(() {
          html = languageProvider.lang == "ar"
              ? value["privacyPolicyAr"]
              : value["privacyPolicy"];
          htmlAr = value["privacyPolicyAr"];
          title = value[0];
          loading = false;
        });
      }
    });
  }

  Future getTerms() async {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.getAboutUs().then((value) {
      if (mounted) {
        setState(() {
          htmlAr = value["termsAndConditionsAr"];
          html = languageProvider.lang == "ar"
              ? value["termsAndConditionsAr"]
              : value["termsAndConditions"];
          title = value[0];
          loading = false;
        });
      }
    });
  }
}
