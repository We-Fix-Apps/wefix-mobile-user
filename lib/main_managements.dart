// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:developer';
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
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
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
      log(user.token);
      return user;
    } else {
      return null;
    }
  }

  // * Handel Notification
  static void handelToken({required BuildContext context, required String token}) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.fcmToken = token;
    log('Fcm Token :- ${appProvider.fcmToken}');
  }

  // Helper function to navigate to ticket details or notifications screen
  static void _navigateFromNotification(BuildContext context, Map<String, dynamic> data) {
    try {
      final ticketId = data['ticketId']?.toString();
      if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
        log('Navigating to ticket details: $ticketId');
        Navigator.push(
          context,
          rightToLeft(TicketDetailsScreen(id: ticketId)),
        );
      } else {
        log('No ticketId found, navigating to notifications screen');
        Navigator.push(context, downToTop(NotificationsScreen()));
      }
    } catch (e) {
      log('Error navigating from notification: $e');
      // Fallback to notifications screen on error
      try {
        Navigator.push(context, downToTop(NotificationsScreen()));
      } catch (e2) {
        log('Error navigating to notifications screen: $e2');
      }
    }
  }

  // Helper function to get localized notification text
  static String _getLocalizedNotificationText(
    Map<String, dynamic> data,
    String defaultText,
    String enKey,
    String arKey,
  ) {
    try {
      // Get user's language preference
      final langCode = CacheHelper.getData(key: LANG_CACHE);
      log('Language code from cache: $langCode');
      
      // Handle both string and dynamic types
      String? langString;
      if (langCode is String) {
        langString = langCode;
      } else if (langCode != null) {
        langString = langCode.toString();
      }
      
      final isArabic = langString != null && langString.toLowerCase().trim() == 'ar';
      log('Is Arabic: $isArabic (langString: $langString)');

      // Check if localized data exists in message.data
      log('Checking for keys: $enKey, $arKey in data: ${data.keys.toList()}');
      if (data.containsKey(enKey) || data.containsKey(arKey)) {
        final enValue = data[enKey]?.toString().trim() ?? '';
        final arValue = data[arKey]?.toString().trim() ?? '';
        
        log('English value: $enValue, Arabic value: $arValue');
        
        if (isArabic) {
          // Prefer Arabic, fallback to English, then default
          final result = arValue.isNotEmpty 
              ? arValue 
              : (enValue.isNotEmpty ? enValue : defaultText);
          log('Selected Arabic text: $result');
          return result;
        } else {
          // Prefer English, fallback to Arabic, then default
          final result = enValue.isNotEmpty 
              ? enValue 
              : (arValue.isNotEmpty ? arValue : defaultText);
          log('Selected English text: $result');
          return result;
        }
      }

      // Fallback to default notification text
      log('No localized keys found, using default: $defaultText');
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    } catch (e) {
      log('Error getting localized notification text: $e');
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    }
  }

  static void handelNotification({required Future<void> Function(RemoteMessage) handler, required GlobalKey<NavigatorState> navigatorKey, required BuildContext context}) {
    // Todo : Start Notifications

    // * If Application is open (foreground), notifications are handled by FcmHelper._fcmForegroundHandler
    // which creates localized system notifications using Awesome Notifications
    // No need to handle here to avoid duplicates

    // * If Application is in backGround or Terminated
    // Handle navigation when app is opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) async {
      log('onMessageOpenedApp : $remoteMessage');
      log('onMessageOpenedApp data: ${remoteMessage.data}');
      // Navigate to ticket details if ticketId is present
      if (remoteMessage.data.containsKey('ticketId')) {
        FcmHelper.navigateFromFirebaseMessage(remoteMessage.data);
      }
    });

    // * If Application is in Closed or Terminated
    // Handle navigation when app is opened from terminated state via notification tap
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        log('getInitialMessage: $remoteMessage');
        log('getInitialMessage data: ${remoteMessage.data}');
        // Navigate to ticket details if ticketId is present
        if (remoteMessage.data.containsKey('ticketId')) {
          // Use a longer delay for terminated state to ensure app is fully initialized
          Future.delayed(const Duration(milliseconds: 2000), () {
            FcmHelper.navigateFromFirebaseMessage(remoteMessage.data);
          });
        }
      }
    });

    // Background handler is already registered in FcmHelper.initFcm() in injection_container.dart
    // No need to register here to avoid overriding the localized handler
    // FirebaseMessaging.onBackgroundMessage(handler);
  }
}
