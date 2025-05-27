import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';

class FacebookApi {
  static Future getFacebookStatus({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.facebook,
        token: token,
      );

      log('getFacebookStatus() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return [];
      }
    } catch (e) {
      log('getFacebookStatus() [ ERROR ] -> $e');
      return [];
    }
  }
}
