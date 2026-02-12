import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/holiday_model.dart';
import 'package:wefix/main.dart' show navigatorKey;
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/Data/Functions/navigation.dart';

import 'package:wefix/Data/model/profile_model.dart';
import 'package:wefix/Data/model/realstate_model.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/time_appointment_model.dart';

class ProfileApis {
  // Force logout when server is down (502 Bad Gateway)
  static void _forceLogoutOnServerDown() {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        appProvider.clearUser();
        Navigator.of(context).pushAndRemoveUntil(
          rightToLeft(const LoginScreen()),
          (route) => true,
        );
        log('Force logout: Server is down (502 Bad Gateway)');
      }
    } catch (e) {
      log('Error during force logout: $e');
    }
  }

  static Future getAddress({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.address,
        token: token,
      );

      log('getAddress() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('getAddress() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future addReviewTech({
    required String token,
    required String comment,
    required int id,
    required double rate,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.rate,
        data: {
          "TicketId": id,
          "Rating": rate,
          "Comment": comment,
        },
        token: token,
      );

      log('addReviewTech() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('addReviewTech() [ ERROR ] -> $e');
      return null;
    }
  }

  static SubsicripeModel? subsicripeModel;

  static Future isSubsicribe({
    required String token,
    bool? isCompany,
  }) async {
    try {
      final response = await HttpHelper.getData(query: isCompany == true ? EndPoints.isSubscribeCompany : EndPoints.isSubsicribe, token: token);
      log('isSubsicribe() [ STATUS ] -> ${response.statusCode}');
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final body = json.decode(response.body);
          subsicripeModel = SubsicripeModel.fromJson(body);
          return subsicripeModel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('isSubsicribe() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future chaeckAvalable({
    required String token,
    String? date,
  }) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.checkAvilabel, token: token, data: {
        "SelectedDatestr": date,
      });

      log('chaeckAvalable() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return false;
      }
    } catch (e) {
      log('chaeckAvalable() [ ERROR ] -> $e');
      return null;
    }
  }

  static HolidayModel? holidayModel;
  static Future getHoliday({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.holiday,
        token: token,
      );

      log('getHoliday() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        holidayModel = HolidayModel.fromJson(body);
        return holidayModel;
      } else {
        return false;
      }
    } catch (e) {
      log('getHoliday() [ ERROR ] -> $e');
      return null;
    }
  }

  static TimeAppoitmentModel? timeAppoitmentModel;
  static Future getAppitmentTime({
    required String token,
    required String date,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.appoitmentTime,
        data: {
          "SelectedDate": date,
        },
        token: token,
      );

      log('getAppitmentTime() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        timeAppoitmentModel = TimeAppoitmentModel.fromJson(body);
        return timeAppoitmentModel;
      } else {
        return false;
      }
    } catch (e) {
      log('getAppitmentTime() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future renew({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.renew,
        token: token,
      );

      log('renew() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body['status'];
      } else {
        return false;
      }
    } catch (e) {
      log('renew() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future calculateSubPrice({
    required String token,
    String? age,
    String? area,
    String? packageId,
  }) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.calculateSubPrice, token: token, data: {
        "Age": 0,
        "Area": area,
        "PackageId": packageId,
      });

      log('calculateSubPrice() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body['contractAmount'];
      } else if (response.statusCode == 400) {
        return body["status"];
      } else {
        return false;
      }
    } catch (e) {
      log('calculateSubPrice() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Products By Id
  static RealEstatesModel? realEstatesModel;
  static Future getRealState({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getRealState,
        token: token,
      );

      log('getRealState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        realEstatesModel = RealEstatesModel.fromJson(body);
        return realEstatesModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getRealState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future createRealeState({
    required String token,
    required String title,
    required String? area,
    required String? apartmentNo,
    required String? address,
    required String? latitude,
    required String? longitude,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.createRealState,
        data: {
          "Title": title,
          "Area": area,
          "ApartmentNo": apartmentNo,
          "Address": address,
          "Latitude": latitude,
          "Longitude": longitude,
        },
        token: token,
      );

      log('createRealeState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('createRealeState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editRealState({
    required String token,
    required int id,
    required String title,
    required String? area,
    required String? apartmentNo,
    required String? address,
    required String? latitude,
    required String? longitude,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.editRealState,
        data: {
          "Id": id,
          "Title": title,
          "Area": area,
          "ApartmentNo": apartmentNo,
          "Address": address,
          "Latitude": latitude,
          "Longitude": longitude,
        },
        token: token,
      );

      log('editRealState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('editRealState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future promoCode({
    required String token,
    required String code,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.promoCode,
        data: {
          "Code": code,
        },
        token: token,
      );

      log('promoCode() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        return null;
      }
    } catch (e) {
      log('promoCode() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Products By Id
  static ProfileModel? profileModel;
  static Future<ProfileModel?> getProfileData({
    required String token,
    bool? isCompany,
  }) async {
    try {
      // Use backend-mms endpoint only if user is company personnel (roleId == 2)
      final bool useMMS = isCompany == true;

      final url = useMMS ? Uri.parse('${EndPoints.mmsBaseUrl}${EndPoints.getProfile}') : Uri.parse('${EndPoints.baseUrl}${EndPoints.getProfile}');

      var headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      // Check status code before parsing JSON
      if (response.statusCode == 200) {
        // Check if response body is not empty
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          log('getProfileData() [ WARNING ] -> Empty response body');
          return null;
        }

        try {
          final body = json.decode(response.body);
          profileModel = ProfileModel.fromJson(body);
          return profileModel;
        } catch (parseError) {
          log('getProfileData() [ PARSE ERROR ] -> $parseError');
          return null;
        }
      } else {
        // For non-200 status codes, don't try to parse JSON
        log('getProfileData() [ ERROR ] -> Status ${response.statusCode}, body: ${response.body.isNotEmpty ? response.body.substring(0, response.body.length > 100 ? 100 : response.body.length) : "empty"}');

        // Force logout if server is down (502 Bad Gateway)
        if (response.statusCode == 502) {
          _forceLogoutOnServerDown();
        }

        return null;
      }
    } catch (e) {
      log('getProfileData() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String image,
    required String email,
  }) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.editProfile, token: token, data: {
        "email": email,
        "firstname": firstName,
        "lastname": lastName,
        "profileImage": image,
      });

      log('editProfile() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
    } catch (e) {
      log('editProfile() [ ERROR ] -> $e');
      return null;
    }
  }

  // Update profile using backend-mms (with file upload support)
  static Future<ProfileModel?> updateProfileMMS({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    try {
      final url = Uri.parse('${EndPoints.mmsBaseUrl}${EndPoints.updateProfile}');

      var request = http.MultipartRequest('PUT', url);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['email'] = email;
      request.fields['firstname'] = firstName;
      request.fields['lastname'] = lastName;

      // Add image file if provided
      if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('profileImage', imageFile.path),
        );
      } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        // If no new image but existing image URL, send it as a field
        request.fields['profileImage'] = existingImageUrl;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('updateProfileMMS() [ STATUS ] -> ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['profile'] != null) {
          profileModel = ProfileModel.fromJson(body);
          return profileModel;
        }
      } else {
        log('updateProfileMMS() [ ERROR ] -> Status ${response.statusCode}, body: ${response.body}');
      }

      return null;
    } catch (e) {
      log('updateProfileMMS() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.changedPassword, token: token, data: {
        "OldPassword": oldPassword,
        "Password": newPassword,
      });

      log('changePassword() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
    } catch (e) {
      log('changePassword() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editPhone({
    required String token,
    required String phone,
  }) async {
    try {
      final response = await HttpHelper.postData(query: EndPoints.changedPhone, token: token, data: {
        "phone": phone,
      });

      log('editProfile() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (body['status'] == true) {
        return true;
      } else if (body['message'] == 'exist') {
        return false;
      } else {
        return 'The Phone Number is Exist';
      }
    } catch (e) {
      log('editProfile() [ ERROR ] -> $e');
      return false;
    }
  }

  static Future deleteAccount({
    required String token,
    required bool isB2B, // true for B2B (backend-mms), false for B2C (backend-oms)
  }) async {
    try {
      if (isB2B) {
        // B2B: Use backend-mms endpoint for account deletion (soft-delete)
        final url = Uri.parse('${EndPoints.mmsBaseUrl}${EndPoints.mmsDeleteAccount}');
        
        var headers = {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer $token',
        };
        
        final response = await http.delete(url, headers: headers);

        log('deleteAccount() [B2B] [ STATUS ] -> ${response.statusCode}');

        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          if (body['success'] == true) {
            return true;
          }
          return false;
        } else {
          log('deleteAccount() [B2B] [ ERROR ] -> Status ${response.statusCode}, body: ${response.body}');
          return false;
        }
      } else {
        // B2C: Use backend-oms endpoint (ASP.NET API)
        final response = await HttpHelper.postData(
          query: EndPoints.deleteAccount,
          token: token,
        );

        log('deleteAccount() [B2C] [ STATUS ] -> ${response.statusCode}');

        if (response.statusCode == 200) {
          return true;
        } else {
          log('deleteAccount() [B2C] [ ERROR ] -> Status ${response.statusCode}');
          return false;
        }
      }
    } catch (e) {
      log('deleteAccount() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future getAboutUs() async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.about,
      );

      log('getAboutUs() [ Status ] : ${response.statusCode} ');

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        log('Somthing Error');
      }
    } catch (e) {
      log('getAboutUs() [ Error ] : $e ');
    }
  }

  // static Future getPrivacy() async {
  //   try {
  //     final response = await HttpHelper.getData(
  //       query: EndPoints.privacy,
  //     );

  //     log('getPrivacy() [ Status ] : ${response.statusCode} ');

  //     final body = json.decode(response.body);
  //     if (response.statusCode == 200) {
  //       return [body['pageName'], body['pageDescription']];
  //     } else {
  //       log('Somthing Error');
  //     }
  //   } catch (e) {
  //     log('getPrivacy() [ Error ] : $e ');
  //   }
  // }

  // static Future getTerms() async {
  //   try {
  //     final response = await HttpHelper.getData(
  //       query: EndPoints.terms,
  //     );

  //     log('getTerms() [ Status ] : ${response.statusCode} ');

  //     final body = json.decode(response.body);
  //     if (response.statusCode == 200) {
  //       return [body['pageName'], body['pageDescription']];
  //     } else {
  //       log('Somthing Error');
  //     }
  //   } catch (e) {
  //     log('getTerms() [ Error ] : $e ');
  //   }
  // }
}
