// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:developer';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Functions/navigation.dart';

import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';

import 'package:wefix/Presentation/Profile/profile_screen.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';

import 'package:wefix/layout_screen.dart';

class MainManagements {
  // ! Start Home Layout

  BuildContext? context;

  // * Handel Language
  static void handelLanguage({required BuildContext context}) {
    LanguageProvider language =
        Provider.of<LanguageProvider>(context, listen: false);
    if (language.lang == '' || CacheHelper.getData(key: LANG_CACHE) == null) {
      language.lang = 'en';

      CacheHelper.saveData(key: LANG_CACHE, value: 'en');
    } else {
      language.lang = CacheHelper.getData(key: LANG_CACHE);
    }
  }

  // * Handel User Data
  static UserModel? handelUserData() {
    UserModel? user;

    final String? userData = CacheHelper.getData(key: CacheHelper.userData);
    if (userData != null &&
        userData != 'null' &&
        userData != 'CLEAR_USER_DATA') {
      final body = json.decode(userData);
      user = UserModel.fromJson(body);
      log(user.token ?? '');
      return user;
    } else {
      return null;
    }
  }

  // * Handel Notification
  static void handelToken(
      {required BuildContext context, required String token}) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.fcmToken = token;
    log('Fcm Token :- ${appProvider.fcmToken}');
  }

  static void handelNotification(
      {required Future<void> Function(RemoteMessage) handler,
      required GlobalKey<NavigatorState> navigatorKey,
      required BuildContext context}) {
    // Todo : Start Notifications

    // * If Application is open , then it will work
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        BotToast.showNotification(
            onTap: () {
              Navigator.push(navigatorKey.currentState!.context,
                  downToTop(NotificationsScreen()));
            },
            contentPadding: EdgeInsets.all(8.0),
            align: Alignment.topCenter,
            title: (w) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: AppColors(context).primaryColor,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          message.notification?.title ?? ' ',
                          style: TextStyle(
                            fontSize: AppSize(context).smallText2,
                            color: AppColors(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
            subtitle: (w) => Text(
                  message.notification?.body ?? ' ',
                  style: TextStyle(
                    color: AppColors.greyColor2,
                    fontWeight: FontWeight.normal,
                    fontSize: AppSize(context).smallText3,
                  ),
                ),
            duration: const Duration(seconds: 5));
      }
    });

    // * If Application is in backGround , then it will work
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage remoteMessage) async {
      log('onMessageOpenedApp : $remoteMessage');
      if (remoteMessage.notification != null) {
        BotToast.showNotification(
            onTap: () {
              Navigator.push(navigatorKey.currentState!.context,
                  downToTop(NotificationsScreen()));
            },
            contentPadding: const EdgeInsets.all(8.0),
            align: Alignment.topCenter,
            title: (w) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: AppColors(context).primaryColor,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          remoteMessage.notification?.title ?? ' ',
                          style: TextStyle(
                            color: AppColors(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
            subtitle: (w) => Text(
                  remoteMessage.notification?.body ?? ' ',
                  style: const TextStyle(
                    color: AppColors.greyColor2,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
            duration: const Duration(seconds: 5));
      }
    });

    // * If Application is in Closed or Terminiated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage?.notification != null) {
        BotToast.showNotification(
            onTap: () {
              // Navigator.pushNamed(
              //   navigatorKey.currentState!.context,
              //   '/home',
              //   arguments: {'message': json.encode(remoteMessage?.data)},
              // );
              Navigator.push(navigatorKey.currentState!.context,
                  downToTop(NotificationsScreen()));
            },
            contentPadding: const EdgeInsets.all(8.0),
            align: Alignment.topCenter,
            title: (w) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: AppColors(context).primaryColor,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          remoteMessage?.notification?.title ?? ' ',
                          style: TextStyle(
                            color: AppColors(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
            subtitle: (w) => Text(
                  remoteMessage?.notification?.body ?? ' ',
                  style: const TextStyle(
                    color: AppColors.greyColor2,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
            duration: const Duration(seconds: 5));
      }
    });

    FirebaseMessaging.onBackgroundMessage(handler);
  }
}
