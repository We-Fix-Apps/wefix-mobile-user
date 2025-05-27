import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bannars/banars.apis.dart';
import 'package:wefix/Business/Category/category_apis.dart';
import 'package:wefix/Business/language/language_api.dart';
import 'package:wefix/Data/Constant/Image/app_image.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';

import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/Auth/login_screen.dart';
import 'package:wefix/layout_screen.dart';

class SplashScreen extends StatefulWidget {
  final UserModel? userModel;

  const SplashScreen({Key? key, this.userModel}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? loadingBannar;
  String? splash;
  String? appcolor;
  @override
  void initState() {
    // navigatorToFirstPage();
    getAppLanguage();
    // getSpalsh();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
              fit: BoxFit.cover,
              height: AppSize(context).height * 0.7,
              repeat: ImageRepeat.noRepeat,
              image: AssetImage("assets/image/Pre-comp 3.gif")),
        ),
      ),
    );
  }

  Future getSpalsh() async {
    try {
      if (mounted) {
        setState(() {
          loadingBannar = true;
        });
      }
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await BannarsAois.getSplash(token: appProvider.userModel?.token ?? '')
          .then(
        (value) {
          if (value.isNotEmpty) {
            if (mounted) {
              setState(() {
                splash = value;
                loadingBannar = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                loadingBannar = false;
              });
            }
          }
        },
      );
    } catch (e) {
      log('Bannar Error -> $e');
      if (mounted) {
        setState(() {
          loadingBannar = false;
        });
      }
    }
  }

  navigatorToFirstPage() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    if (widget.userModel != null) {
      appProvider.addUser(user: widget.userModel);
      await Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.pushReplacement(
          context,
          downToTop(const HomeLayout()),
        );
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 3000), () {
        // appProvider.addUser(user: widget.userModel);

        Navigator.pushReplacement(
          context,
          downToTop(const LoginScreen()),
        );
      });
    }
  }

  Future getAppLanguage() async {
    AppProvider languageProvider =
        Provider.of<AppProvider>(context, listen: false);
    try {
      await LanguageApis.getAppLang(lang: 'ar').then(
        (value) {
          if (value.isNotEmpty) {
            List<String> allGlobal = [];
            log('Success Get Lang Apis');
            languageProvider.addLang(value);
            for (var element in languageProvider.allLanguage) {
              if (allGlobal.contains(element.key)) {
              } else {
                if (mounted) {
                  setState(() => allGlobal.add(element.key ?? ''));
                  log(allGlobal.toString());
                }
              }
            }
            languageProvider.addGlobal(allGlobal);
            navigatorToFirstPage();

            // getColors();
          }
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future getColors() async {
    try {
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await CategoryApis.getColor(token: appProvider.userModel?.token ?? '')
          .then((value) {
        appProvider.addColor(value);
        navigatorToFirstPage();
      });
    } catch (e) {
      log('getColors Error -> $e');
      if (mounted) {
        setState(() {});
      }
    }
  }
}
