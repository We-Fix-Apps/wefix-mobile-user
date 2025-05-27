import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/Model/bannar_model.dart';

class BannarsAois {
  // * Get All Banars
  static BannarModel? bannarModel;

  static Future<List<String>> allBanars({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.bannar,
        token: token,
      );

      log('allBanars() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        bannarModel = BannarModel.fromJson(body);
        if (bannarModel?.banners?.isNotEmpty ?? false) {
          return bannarModel!.banners!;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('allBanars() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future<String> getSplash({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.splashScreen,
        token: token,
      );

      log('getSplash() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["banners"];
      } else {
        return "";
      }
    } catch (e) {
      log('getSplash() [ ERROR ] -> $e');
      return "";
    }
  }
}
