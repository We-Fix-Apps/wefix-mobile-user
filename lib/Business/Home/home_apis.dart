import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Data/model/sub_cat_model.dart';

class HomeApis {
  static HomeModel? homeModel;
  static Future<HomeModel?> allHomeApis({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.home,
        token: token,
      );

      log('allHomeApis() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        homeModel = HomeModel.fromJson(body);
        return homeModel;
      } else {
        return null;
      }
    } catch (e) {
      log('allHomeApis() [ ERROR ] -> $e');
      return null;
    }
  }

  static SubServiceModel? subServiceModel;
  static Future<SubServiceModel?> getSubCatService(
      {required String token, required String id, int? roleId}) async {
    try {
      final response = await HttpHelper.getData(
        query:
            roleId == 1 ? EndPoints.subCategory + id : EndPoints.serviceCompany,
        token: token,
      );
      

      log('getSubCatService() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        subServiceModel = SubServiceModel.fromJson(body);
        return subServiceModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getSubCatService() [ ERROR ] -> $e');
      return null;
    }
  }
}
