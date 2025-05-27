import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/notofications_model.dart';

class NoyificationApis {
  static NotoModel? notificationModel;
  static List<Notification?> notificationList = [];

  static Future<List<Notification?>> getNotification(
      {required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.notifications,
        token: token,
      );

      log('getNotification() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        notificationModel = NotoModel.fromJson(body);
        if (notificationModel?.notifications.isNotEmpty ?? false) {
          notificationList = notificationModel!.notifications;
          return notificationList;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('getNotification() [ ERROR ] -> $e');
      return [];
    }
  }
}
