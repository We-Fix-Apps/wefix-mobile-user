import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class NotificationApis {
  static void requestNotificationPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      _showPermissionDialog(_navigatorKey.currentContext!);
      log('User declined or has not accepted permission');
    }
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permissions'),
          content: const Text(
              'Please enable all notification permissions to get the best experience.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                NotificationSettings settings =
                    await FirebaseMessaging.instance.requestPermission(
                  alert: true,
                  announcement: true,
                  badge: true,
                  carPlay: true,
                  criticalAlert: true,
                  provisional: true,
                  sound: true,
                );
                if (settings.authorizationStatus ==
                    AuthorizationStatus.authorized) {
                  log('User granted permission');
                } else {
                  log('User declined or has not accepted permission');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
