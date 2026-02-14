import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Notification/globale.dart';
import 'package:wefix/Data/Notification/model/notification_channel_model.dart';
import 'package:wefix/Data/Notification/fcm_setup.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';
 
import '../../../../main.dart';

class NotificationsController {
  static ReceivedAction? initialAction;

  // ***************************************************************
  //    INITIALIZATIONS
  // ***************************************************************
  static Future<void> initializeLocalNotifications() async {
    await initializeIsolateReceivePort();
    await AwesomeNotifications().initialize(
        "resource://mipmap/launcher_icon", // Match AndroidManifest.xml icon
        [
          NotificationChannel(
              channelGroupKey: NotificationChannelKey.basicChannel.groupKey,
              channelKey: NotificationChannelKey.basicChannel.key,
              channelName: NotificationChannelKey.basicChannel.name,
              channelDescription: NotificationChannelKey.basicChannel.description,
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.white,
              // soundSource: "resource://raw/noti_sound",
              importance: NotificationImportance.High),
          NotificationChannel(
              channelGroupKey: NotificationChannelKey.basicChannel.groupKey,
              channelKey: NotificationChannelKey.basicChannel.key,
              channelName: 'Badge indicator notifications',
              channelDescription: 'Notification channel to activate badge indicator',
              channelShowBadge: true,
              // soundSource: "resource://raw/noti_sound",
              defaultColor: const Color(0xFF9D50DD),
              ledColor: Colors.yellow),
          NotificationChannel(
              channelGroupKey: NotificationChannelKey.categoryChannel.groupKey,
              channelKey: NotificationChannelKey.categoryChannel.key,
              channelName: NotificationChannelKey.categoryChannel.name,
              channelDescription: NotificationChannelKey.categoryChannel.description,
              // soundSource: "resource://raw/noti_sound",
              defaultColor: const Color(0xFF9D50DD),
              importance: NotificationImportance.Max,
              ledColor: Colors.white,
              channelShowBadge: true,
              locked: true,
              defaultRingtoneType: DefaultRingtoneType.Ringtone),
          NotificationChannel(
              channelGroupKey: NotificationChannelKey.categoryChannel.groupKey,
              channelKey: NotificationChannelKey.alarmChannel,
              channelName: 'Alarms Channel',
              // soundSource: "resource://raw/noti_sound",
              channelDescription: 'Channel with alarm ringtone',
              defaultColor: const Color(0xFF9D50DD),
              importance: NotificationImportance.Max,
              ledColor: Colors.white,
              channelShowBadge: true,
              locked: true,
              defaultRingtoneType: DefaultRingtoneType.Alarm),
          NotificationChannel(
            channelGroupKey: NotificationChannelKey.scheduleChannel.groupKey,
            channelKey: NotificationChannelKey.scheduleChannel.key,
            channelName: NotificationChannelKey.scheduleChannel.name,
            // soundSource: "resource://raw/noti_sound",
            channelDescription: NotificationChannelKey.scheduleChannel.description,
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            vibrationPattern: lowVibrationPattern,
            importance: NotificationImportance.High,
            defaultRingtoneType: DefaultRingtoneType.Alarm,
            criticalAlerts: true,
          ),
        ],
        channelGroups: [
          NotificationChannelGroup(channelGroupKey: 'basic', channelGroupName: 'Basic'),
          NotificationChannelGroup(channelGroupKey: 'category', channelGroupName: 'Category'),
          NotificationChannelGroup(channelGroupKey: 'schedule', channelGroupName: 'Schedule'),
        ],
        debug: true);
    // Get initial notification action is optional
    initialAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> initializeNotificationsEventListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationsController.onActionReceivedMethod,
        onNotificationCreatedMethod: NotificationsController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod: NotificationsController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: NotificationsController.onDismissActionReceivedMethod);
  }

  // ***************************************************************
  //    ON ACTION EVENT REDIRECTION TO MAIN ISOLATE
  // ***************************************************************

  static ReceivePort? receivePort;

  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate');
    receivePort!.listen((serializedData) {
      final receivedAction = ReceivedAction().fromMap(serializedData);
      onActionReceivedMethodImpl(receivedAction);
    });

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(receivePort!.sendPort, 'notification_action_port');
  }

  // ***************************************************************
  //    NOTIFICATIONS EVENT LISTENERS
  // ***************************************************************
  ///  Notifications events are only delivered after call this method
  // static Future<void> startListeningNotificationEvents() async {
  //   AwesomeNotifications()
  //       .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  // }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    var message = 'Notification created on ${receivedNotification.createdLifeCycle?.name}';
    log(message);
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    var message1 = 'Notification displayed on ${receivedNotification.displayedLifeCycle?.name}';
    var message2 = 'Notification displayed at ${receivedNotification.displayedDate}';

    log(message1);
    log(message2);
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    var message = 'Notification dismissed on ${receivedAction.dismissedLifeCycle?.name}';
    log(message);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivePort != null) {
      await onActionReceivedMethodImpl(receivedAction);
    } else {
      log('onActionReceivedMethod was called inside a parallel dart isolate, where receivePort was never initialized.');
      SendPort? sendPort = IsolateNameServer.lookupPortByName('notification_action_port');

      log('Redirecting the execution to main isolate process in listening...');
      dynamic serializedData = receivedAction.toMap();
      sendPort?.send(serializedData);
    }
  }

  static Future<void> onActionReceivedMethodImpl(ReceivedAction receivedAction) async {
    // Always ensure that all plugins was initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Handle navigation when notification is clicked
    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      final payload = receivedAction.payload!;
      final ticketId = payload['ticketId']?.toString();
      
      if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
        // Check if app is already running (splash completed)
        final isSplashCompleted = FcmHelper.isSplashScreenCompleted();
        
        if (isSplashCompleted) {
          // App is already running - navigate directly to TicketDetailsScreen (no loader needed)
          await Future.delayed(const Duration(milliseconds: 100));
          try {
            final context = navigatorKey.currentState?.context;
            if (context != null && context.mounted) {
              Navigator.push(
                context,
                rightToLeft(TicketDetailsScreen(id: ticketId)),
              );
            } else {
              // Context not ready, store and let retry logic handle it
              await FcmHelper.storePendingNotification(payload.cast<String, dynamic>());
            }
          } catch (e) {
            // Error navigating, store and let retry logic handle it
            await FcmHelper.storePendingNotification(payload.cast<String, dynamic>());
          }
        } else {
          // App is starting from cold start - store and wait for splash gate
          // The splash gate (_onSplashExit) will handle navigation after splash completes
          // This ensures the flow is: Splash → Home → TicketDetailsLoader → TicketDetailsScreen
          await FcmHelper.storePendingNotification(payload.cast<String, dynamic>());
        }
      } else {
        // For non-ticket notifications, wait for context and navigate directly
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          final context = navigatorKey.currentState?.context;
          if (context != null && context.mounted) {
            Navigator.push(context, downToTop(NotificationsScreen()));
          }
        } catch (e) {
          // Error navigating to notifications screen
        }
      }
    }
  }

  // ***************************************************************
  ///   NOTIFICATIONS HANDLING METHODS
  // ***************************************************************

  static Future<void> interceptInitialCallActionRequest() async {
    ReceivedAction? receivedAction = await AwesomeNotifications().getInitialNotificationAction();

    if (receivedAction?.channelKey == 'call_channel') {
      initialAction = receivedAction;
    } else if (receivedAction != null) {
      // Handle ticket notifications when app is opened from terminated state
      // Only store notification data if it doesn't already exist
      // Navigation is handled by the splash gate (_onSplashExit)
      // This ensures the flow is always: Splash → Home → TicketDetailsLoader → TicketDetailsScreen
      if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
        final payload = receivedAction.payload!;
        final ticketId = payload['ticketId']?.toString();
        
        if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
          // Store notification data - storePendingNotification() already has duplicate check
          // This prevents duplicate storage after navigation has already started
          await FcmHelper.storePendingNotification(payload.cast<String, dynamic>());
          // Don't call navigateFromPendingNotification() here
          // The splash gate (_onSplashExit) already calls it after delays
        }
      }
    }
  }

  //  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification({
    required String title,
    required String body,
    String? bigPicture,
    NotificationChannelModel? channel,
    required Map<String, String?> payload,
    int? notificationId,
  }) async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        handleNotificationPayload(navigatorKey.currentState!.context, payload.cast());

        // Use provided notificationId or -1 (random) to prevent duplicates
        // If notificationId is provided, it will replace any existing notification with the same ID
        final id = notificationId ?? -1;
        
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              // If id is -1, it's replaced by a random number
              // If id is provided, it will replace any existing notification with the same ID
              channelKey: channel?.key ?? NotificationChannelKey.basicChannel.key,
              title: title,
              body: body,
              bigPicture: bigPicture,
              // 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
              largeIcon: bigPicture?.isNotEmpty == true ? bigPicture : null,
              notificationLayout: bigPicture?.isNotEmpty == true ? NotificationLayout.BigPicture : NotificationLayout.Default,
              payload: payload),
        );
      }
    });
  }

  static scheduleNotification({
    required String title,
    required String body,
    required int id,
    required DateTime date,
    Map<String, String?>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        title: title,
        body: body,
        wakeUpScreen: true,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        groupKey: NotificationChannelKey.scheduleChannel.groupKey,
        channelKey: NotificationChannelKey.scheduleChannel.key,
        payload: payload,
      ),
      schedule: NotificationCalendar
          // .fromDate(
          // date: date, allowWhileIdle: true, preciseAlarm: true));
          (
        year: date.year,
        month: date.month,
        day: date.day,
        hour: date.hour,
        minute: date.minute,
        second: date.second,
        allowWhileIdle: true,
        preciseAlarm: true,
        repeats: true,
      ),
      actionButtons: [
        // NotificationActionButton(
        //   key: AppStrings.navigateToStore,
        //   label: AppStrings.navigateToStore,
        // ),
        // NotificationActionButton(
        //   key: AppStrings.call,
        //   label: AppStrings.call,
        //   color: Colors.green,
        // ),
      ],
    );
  }

  static void handleNotificationPayload(BuildContext context, Map<String, dynamic> payload) {
    // Handle navigation when notification is created (for foreground notifications)
    try {
      final ticketId = payload['ticketId']?.toString();
      if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
        log('Notification payload contains ticketId: $ticketId');
        // Navigation will be handled by onActionReceivedMethodImpl when user taps
      }
    } catch (e) {
      log('Error handling notification payload: $e');
    }
  }

  static cancelScheduleNotification({required int id}) async {
    await AwesomeNotifications().cancelSchedule(id);
  }

  static cancelAllScheduleNotification() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  static Future<void> getAllScheduleNotifications() async {
    List<NotificationModel> allScheduleNotifications = await AwesomeNotifications().listScheduledNotifications();
    log(allScheduleNotifications.length.toString());
    log("Scheduled Notifications :$allScheduleNotifications");
  }
}
