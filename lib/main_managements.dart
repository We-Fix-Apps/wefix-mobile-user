// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/ticket_details_loader.dart';
import 'package:wefix/Data/Notification/fcm_setup.dart';

class MainManagements {
  // ! Start Home Layout

  BuildContext? context;

  // * Handel Language
  static void handelLanguage({required BuildContext context}) {
    LanguageProvider language = Provider.of<LanguageProvider>(context, listen: false);
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
    if (userData != null && userData != 'null' && userData != 'CLEAR_USER_DATA') {
      final body = json.decode(userData);
      user = UserModel.fromJson(body);
      return user;
    } else {
      return null;
    }
  }

  // * Handel Notification
  static void handelToken({required BuildContext context, required String token}) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.fcmToken = token;
  }

  static void handelNotification({required Future<void> Function(RemoteMessage) handler, required GlobalKey<NavigatorState> navigatorKey, required BuildContext context}) {
    // Todo : Start Notifications

    // * If Application is open (foreground), notifications are handled by FcmHelper._fcmForegroundHandler
    // which creates localized system notifications using Awesome Notifications
    // No need to handle here to avoid duplicates

    // * If Application is in backGround (not terminated)
    // Handle navigation when app is opened from background via notification tap
    // This is safe to navigate immediately since app is already initialized
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) async {
      // Navigate immediately since app is already running
      if (remoteMessage.data.containsKey('ticketId')) {
        final ticketId = remoteMessage.data['ticketId']?.toString();
        
        // Wait a bit to ensure context is ready
        await Future.delayed(const Duration(milliseconds: 100));
        
        final context = navigatorKey.currentState?.context;
        if (context != null && context.mounted) {
          if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
            Navigator.push(
              context,
              rightToLeft(TicketDetailsLoader(ticketId: ticketId)),
            );
          } else {
            Navigator.push(context, downToTop(NotificationsScreen()));
          }
        }
      }
    });

    // * If Application is in Closed or Terminated
    // getInitialMessage() is now called in main() right after Firebase initialization
    // This ensures it's called as early as possible and only once per app launch
    // The notification data will be stored and navigation will happen AFTER splash screen completes

    // Background handler is already registered in FcmHelper.initFcm() in injection_container.dart
    // No need to register here to avoid overriding the localized handler
    // FirebaseMessaging.onBackgroundMessage(handler);
  }
}
