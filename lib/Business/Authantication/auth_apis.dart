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
  static Future<Map<String, dynamic>> checkOtp({required String otp, required String phone, required String fcmToken}) async {
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
          return {'success': true, 'data': usermodel};
        } else {
          return {'success': false, 'data': null, 'message': 'Failed to parse user data'};
        }
      } else {
        String errorMessage = body['message'] ?? 
                              body['error'] ?? 
                              'Invalid OTP';
        String? errorMessageAr = body['messageAr'];
        return {
          'success': false, 
          'data': null, 
          'message': errorMessage,
          if (errorMessageAr != null) 'messageAr': errorMessageAr,
        };
      }
    } catch (e) {
      log('checkOtp() [ ERROR ] -> $e');
      return {
        'success': false, 
        'data': null, 
        'message': 'Service is currently unavailable', 
        'messageAr': 'الخدمة غير متوفرة حاليا'
      };
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

  // * MMS Request OTP (Business Services - Phone-based login)
  static Future<Map<String, dynamic>> mmsRequestOTP({
    required String mobile,
    required String deviceId,
    required String fcmToken,
  }) async {
    try {
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsRequestOTP,
        data: {
          'mobile': mobile,
          'deviceId': deviceId,
          'fcmToken': fcmToken,
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'OTP sent successfully',
          'otp': body['otp'], // Only in development
        };
      } else {
        String errorMessage = body['message'] ?? 
                              body['error'] ?? 
                              'Failed to send OTP';
        String? errorMessageAr = body['messageAr'];
        return {
          'success': false, 
          'message': errorMessage,
          if (errorMessageAr != null) 'messageAr': errorMessageAr,
        };
      }
    } catch (e) {
      log('mmsRequestOTP() [ ERROR ] -> $e');
      // Network error - message will be localized in UI based on user language
      return {'success': false, 'message': 'Service is currently unavailable', 'messageAr': 'الخدمة غير متوفرة حاليا'};
    }
  }

  // * MMS Verify OTP (Business Services - Phone-based login)
  static Future<Map<String, dynamic>> mmsVerifyOTP({
    required String mobile,
    required String otp,
    required String deviceId,
    required String fcmToken,
  }) async {
    try {
      // Trim OTP to remove any whitespace
      final trimmedOTP = otp.trim();
      
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsVerifyOTP,
        data: {
          'mobile': mobile,
          'otp': trimmedOTP,
          'deviceId': deviceId,
          'fcmToken': fcmToken,
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        mmsUserModel = MmsUserModel.fromJson(body);
        if (mmsUserModel != null) {
          return {'success': true, 'data': mmsUserModel, 'message': null};
        } else {
          return {'success': false, 'data': null, 'message': 'Failed to parse user data'};
        }
      } else {
        String errorMessage = body['message'] ?? 
                              body['error'] ?? 
                              'Invalid OTP';
        String? errorMessageAr = body['messageAr'];
        return {
          'success': false, 
          'data': null, 
          'message': errorMessage,
          if (errorMessageAr != null) 'messageAr': errorMessageAr,
        };
      }
    } catch (e) {
      log('mmsVerifyOTP() [ ERROR ] -> $e');
      // Network error - message will be localized in UI based on user language
      return {
        'success': false, 
        'data': null, 
        'message': 'Service is currently unavailable', 
        'messageAr': 'الخدمة غير متوفرة حاليا'
      };
    }
  }

  // * MMS Login (Company Personnel) - DEPRECATED: Use mmsRequestOTP and mmsVerifyOTP instead
  static MmsUserModel? mmsUserModel;
  static Future<Map<String, dynamic>> mmsLogin({
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

      // Email/password login is deprecated
      if (response.statusCode == 400) {
        return {
          'success': false,
          'data': null,
          'message': body['message'] ?? 'Email/password login is no longer supported. Please use phone number and OTP.',
        };
      }

      if (response.statusCode == 200 && body['success'] == true) {
        mmsUserModel = MmsUserModel.fromJson(body);
        if (mmsUserModel != null) {
          return {'success': true, 'data': mmsUserModel, 'message': null};
        } else {
          return {'success': false, 'data': null, 'message': 'Failed to parse user data'};
        }
      } else {
        // Extract error message from response
        String errorMessage = body['message'] ?? 
                              body['error'] ?? 
                              'Invalid login credentials';
        return {'success': false, 'data': null, 'message': errorMessage};
      }
    } catch (e) {
      log('mmsLogin() [ ERROR ] -> $e');
      // Network error - message will be localized in UI based on user language
      return {
        'success': false, 
        'data': null, 
        'message': 'Service is currently unavailable', 
        'messageAr': 'الخدمة غير متوفرة حاليا'
      };
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
