import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:wefix/Data/Notification/awesome_notification.service.dart';
import 'package:wefix/Data/Notification/fcm_setup.dart';
import 'package:wefix/Data/services/crashlytics_service.dart';
import 'package:wefix/firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //======================== Api Services ======================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Crashlytics
  await CrashlyticsService.initialize();
  await FcmHelper.initFcm();
  sl.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  await FcmHelper.initFcm();
  await NotificationsController.initializeLocalNotifications();
  await NotificationsController.initializeIsolateReceivePort();
}
