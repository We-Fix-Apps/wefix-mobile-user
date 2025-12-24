import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/buissness_type_model.dart';

import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/mms_user_model.dart';
import 'package:wefix/Data/model/signup_model.dart';
import 'package:wefix/Data/model/user_model.dart';

class Authantication {
  // * Login
  static LoginModel? loginModel;
  static Future<LoginModel?> login({required Map user}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.login,
        data: {
          'Mobile': user['Mobile'],
        },
      );

      log('login() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        loginModel = LoginModel.fromJson(body);
        if (loginModel != null) {
          return loginModel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('login() [ ERROR ] -> $e');
      return null;
    }
  }

  static BusinessTypesModel? businessTypesModel;
  static Future getBusinessType({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.buissnessType,
        token: token,
      );

      log('getBusinessType() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        businessTypesModel = BusinessTypesModel.fromJson(body);

        return businessTypesModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getBusinessType() [ ERROR ] -> $e');
      return [];
    }
  }

  static SignUpModel? signUpModel;
  // * Register
  static Future<SignUpModel?> signUp({
    required String name,
    required String password,
    required String phone,
    required String lastname,
    required int BusinessTypeId,
    required String address,
    String? companyName,
    String? area,
    int? type,
    required double lat,
    required double long,
    String? email,
    String? owner,
    String? website,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.signUp,
        data: {
          "Name": name,
          "Mobile": phone,
          "Email": email,
          "Password": password,
          "Address": address,
          "LastName": lastname,
          "lat": lat,
          "long": long,
          "BusinessTypeId": BusinessTypeId,
          "Type": type,
          "Area": area,
          "Owner": owner,
          "Website": website,
        },
      );

      log('SignUp() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        signUpModel = SignUpModel.fromJson(body);
        if (signUpModel != null) {
          return signUpModel;
        } else {
          return null;
        }
      } else {
        return signUpModel;
      }
    } catch (e) {
      log('SignUp() [ ERROR ] -> $e');
      return signUpModel;
    }
  }

  static UserModel? usermodel;
  // * OTP
  static Future<UserModel?> checkOtp({required String otp, required String phone, required String fcmToken}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.checkOtp,
        data: {"Mobile": phone, "Otp": otp, "ActivationCode": fcmToken},
      );

      log('checkOtp() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        usermodel = UserModel.fromJson(body);
        if (usermodel != null) {
          return usermodel;
        } else {
          return null;
        }
      } else {
        return usermodel;
      }
    } catch (e) {
      log('checkOtp() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Forget Password
  static Future updatePassword({
    required String userName,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.forgetPassword,
        data: {
          "Email": userName,
        },
      );

      log('updatePassword() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        if (body['status'] == "Success") {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      log('updatePassword() [ ERROR ] -> $e');
      return false;
    }
  }

  // * MMS Login (Company Personnel)
  static MmsUserModel? mmsUserModel;
  static Future<MmsUserModel?> mmsLogin({
    required String email,
    required String password,
    required String deviceId,
    required String fcmToken,
  }) async {
    try {
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsLogin,
        data: {
          'email': email,
          'password': password,
          'deviceId': deviceId,
          'fcmToken': fcmToken,
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        mmsUserModel = MmsUserModel.fromJson(body);
        if (mmsUserModel != null) {
          return mmsUserModel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('mmsLogin() [ ERROR ] -> $e');
      return null;
    }
  }

  // * MMS Logout (Company Personnel)
  static Future<bool> mmsLogout({required String token}) async {
    try {
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsLogout,
        token: token,
        data: {},
        headers: {'x-client-type': 'mobile'}, // Indicate this is from mobile client
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // * MMS Refresh Token (Company Personnel)
  static Future<Map<String, dynamic>?> mmsRefreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsRefreshToken,
        data: {
          'token': refreshToken,
        },
      );

      log('mmsRefreshToken() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'accessToken': body['accessToken'],
          'refreshToken': body['refreshToken'],
          'tokenType': body['tokenType'] ?? 'Bearer',
          'expiresIn': body['expiresIn'],
        };
      } else {
        return null;
      }
    } catch (e) {
      log('mmsRefreshToken() [ ERROR ] -> $e');
      return null;
    }
  }
}
