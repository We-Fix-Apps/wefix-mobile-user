import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/branch_model.dart';

class B2bApi {
// * Create Branch
  static Future createBranch({
    required String name,
    required String token,
    required String nameAr,
    required String phone,
    required String city,
    required String address,
    required String latitude,
    required String longitude,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.createBranch,
        token: token,
        data: {
          "Name": name,
          "NameAr": nameAr,
          "Phone": phone,
          "City": city,
          "Address": address,
          "Latitude": latitude,
          "Longitude": longitude,
        },
      );

      log('createBranch() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('createBranch() [ ERROR ] -> $e');
      return false;
    }
  }

  static BranchesModel? branchesModel;
  static Future getBranches({required String token}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.getAllBranch,
        token: token,
      );

      log('getBranches() [ STATUS ] -> ${response.statusCode}');
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        branchesModel = BranchesModel.fromJson(body);
        return branchesModel!;
      } else {
        return [];
      }
    } catch (e) {
      log('getBranches() [ ERROR ] -> $e');
      return [];
    }
  }
}
