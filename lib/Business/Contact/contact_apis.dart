import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/contact_model.dart';

class ContactsApis {
  static ContactModel? contactModel;
  static Future getContactInfo({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.contactInfo,
        token: token,
      );

      log('getContactInfo() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        contactModel = ContactModel.fromJson(body);

        return contactModel!;
      } else {
        return [];
      }
    } catch (e) {
      log('getContactInfo() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future contactUsForm({
    required String details,
    required String type,
    required String subject,
    required BuildContext context,
  }) async {
    try {
      AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

      final response = await HttpHelper.postData(
        query: EndPoints.contactUs,
        data: {
          "Name": appProvider.userModel?.customer.name ?? "",
          "MobileNumber": appProvider.userModel?.customer.mobile ?? "",
          "Email": appProvider.userModel?.customer.email ?? "",
          "Type": type,
          "Subject": subject,
          "Details": details,
          "createdDate": DateTime.now().toString().substring(0, 10),
        },
      );

      log('contactUsForm() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        return null;
      }
    } catch (e) {
      log('contactUsForm() [ ERROR ] -> $e');
      return null;
    }
  }
}
