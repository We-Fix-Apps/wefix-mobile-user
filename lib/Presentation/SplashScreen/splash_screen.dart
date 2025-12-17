// ignore_for_file: void_checks

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Category/category_apis.dart';
import 'package:wefix/Business/language/language_api.dart';

import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';

import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/layout_screen.dart';

class SplashScreen extends StatefulWidget {
  final UserModel? userModel;

  const SplashScreen({Key? key, this.userModel}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.asset("assets/video/wefix_logo_motion.mp4")
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _controller.play();
          });

    // Skip the video after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        navigatorToFirstPage();
      }
    });

    getAppLanguage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isVideoInitialized
            ? Center(
                child: SizedBox(
                  width: double.infinity,
                  height: AppSize(context).height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  navigatorToFirstPage() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    if (widget.userModel != null) {
      appProvider.addUser(user: widget.userModel);
      // Load tokens from cache when restoring user data
      appProvider.loadTokensFromCache();
      getAppLanguage().whenComplete(() {
        return Navigator.pushReplacement(
          context,
          downToTop(const HomeLayout()),
        );
      });
    } else {
      getAppLanguage().whenComplete(() {
        return Navigator.pushReplacement(
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
      await LanguageApis.getAppLang(lang: 'ar').then((value) {
        if (value.isNotEmpty) {
          List<String> allGlobal = [];
          log('Success Get Lang Apis');
          languageProvider.addLang(value);
          for (var element in languageProvider.allLanguage) {
            if (!allGlobal.contains(element.key)) {
              allGlobal.add(element.key ?? '');
            }
          }
          languageProvider.addGlobal(allGlobal);
        }
      });
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
      if (mounted) setState(() {});
    }
  }
}
