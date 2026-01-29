import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Data/model/sub_cat_model.dart';

class HomeApis {
  static HomeModel? homeModel;
  static Future<HomeModel?> allHomeApis({String? token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.home,
        token: token,
      );

      log('allHomeApis() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        // Check if response has status field and it's false (error response)
        if (body is Map && body.containsKey('status') && body['status'] == false) {
          // API returned error message even with 200 status
          log('allHomeApis() [ ERROR ] -> ${body['message'] ?? "Unknown error"}');
          // For guest users or when status is false, return empty model
          log('API returned status: false - returning empty HomeModel');
          // Return empty HomeModel
          homeModel = HomeModel(
            sliders: [],
            categories: [],
            serviceOffers: [],
            servicePopular: [],
            tickets: null,
            roleId: 0, // Use 0 as default roleId
          );
          return homeModel;
        }
        
        // Valid response - parse HomeModel
        try {
          homeModel = HomeModel.fromJson(body);
          return homeModel;
        } catch (e) {
          log('allHomeApis() [ PARSE ERROR ] -> $e');
          // For guest users, return empty model on parse error
          log('Parse error - returning empty HomeModel');
          homeModel = HomeModel(
            sliders: [],
            categories: [],
            serviceOffers: [],
            servicePopular: [],
            tickets: null,
            roleId: 0, // Use 0 as default roleId
          );
          return homeModel;
        }
      } else if (response.statusCode == 401 && token == null) {
        // Guest user - try to return empty model or handle gracefully
        log('Guest user accessing home - status 401, returning empty model');
        homeModel = HomeModel(
          sliders: [],
          categories: [],
          serviceOffers: [],
          servicePopular: [],
          tickets: null,
          roleId: 0, // Use 0 as default roleId
        );
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
  static Future<SubServiceModel?> getSubCatService({required String token, required String id, int? roleId}) async {
    try {
      final response = await HttpHelper.getData(
        query: roleId == 1 ? EndPoints.subCategory + id : EndPoints.serviceCompany,
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

  static Future<bool> beforExpiredSubscription({required String token}) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.notifySubscription, token: token);
      log('beforExpiredSubscription() [ STATUS ] -> ${response.statusCode}');
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body['status'];
      } else {
        return false;
      }
    } catch (e) {
      log('beforExpiredSubscription() [ ERROR ] -> $e');
      return false;
    }
  }
}
