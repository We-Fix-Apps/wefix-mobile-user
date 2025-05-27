import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';

import 'package:wefix/Data/model/login_model.dart';
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

  static SignUpModel? signUpModel;
  // * Register
  static Future<SignUpModel?> signUp({
    required String name,
    required String password,
    required String phone,
    required String address,
    String? email,
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
  static Future<UserModel?> checkOtp(
      {required String otp,
      required String phone,
      required String fcmToken}) async {
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
}
