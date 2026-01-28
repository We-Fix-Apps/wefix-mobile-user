import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'awesome_notification.service.dart';

class FcmHelper {
  // prevent making instance
  FcmHelper._();

  // FCM Messaging
  static late FirebaseMessaging messaging;

  /// this function will initialize firebase and fcm instance
  static Future<void> initFcm() async {
    try {
      messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();
      await messaging.setAutoInitEnabled(true);
      // String? token;
      if (Platform.isIOS) {
         await messaging.getAPNSToken();
      } else if (Platform.isAndroid) {
         await messaging.getToken();
      }
      await _setupFcmNotificationSettings();
       

      // background and foreground handlers
      FirebaseMessaging.onMessage.listen(_fcmForegroundHandler);
      FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    } catch (error) {
      log("FCM Error : ${error.toString()}");
    }
  }

  ///handle fcm notification settings (sound,badge..etc)
  static Future<void> _setupFcmNotificationSettings() async {
    //show notification with sound and badge
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );

    //NotificationSettings settings
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
  }

  /// generate and save fcm token if its not already generated (generate only for 1 time)
  // static Future<void> _generateFcmToken() async {
  //   try {
  //     var token = await messaging.getToken();
  //     if (token != null) {
  //       Get.put(AppServices()).appBox.put(BoxKey.firebaseToken, token);
  //
  //       _sendFcmTokenToServer();
  //     } else {
  //       // retry generating token
  //       await Future.delayed(const Duration(seconds: 5));
  //       _generateFcmToken();
  //     }
  //   } catch (error) {
  //     log(error);
  //   }
  // }

  // static _sendFcmTokenToServer() {
  //   Get.find<AppServices>().appBox.get(BoxKey.firebaseToken);
  // }

  @pragma('vm:entry-point')
  static Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
    // var finalId = UniqueKey().hashCode;
    // AwesomeNotificationsHelper.showNotification(
    //   id: finalId,
    //   title: message.notification!.title!,
    //   body: message.notification!.body!,
    //   summary: message.notification?.title,
    //   payload: message.data
    //       .cast(), // pass payload to the notification card so you can use it (when user click on notification)
    // );
    log(message.data.cast().toString());
    NotificationsController.createNewNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        bigPicture: '',
        payload: message.data.cast());
  }

  //handle fcm notification when app is open
  static Future<void> _fcmForegroundHandler(RemoteMessage message) async {
    //
    // if (message.data['pageId'] == "replacement" &&
    //     message.data['pageName'] == "/coupon") {
    //   Get.find<CouponController>().getCoupon();
    // }
    // var finalId = UniqueKey().hashCode;
    // AwesomeNotificationsHelper.showNotification(
    //   id: finalId,
    //   summary: message.notification!.title!,
    //   title: message.notification!.title!,
    //   body: message.notification!.body!,
    //   payload: message.data
    //       .cast(), // pass payload to the notification card so you can use it (when user click on notification)
    // );
    log(message.data.cast().toString());
    NotificationsController.createNewNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        bigPicture: '',
        payload: message.data.cast());
  }
}