import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/branch_model.dart';

class B2bApi {
  // Helper function to get nullable string from JSON with multiple field name options
  static String? _getNullableString(Map<String, dynamic> json, List<String> fieldNames) {
    for (var fieldName in fieldNames) {
      if (json.containsKey(fieldName) && json[fieldName] != null) {
        final value = json[fieldName].toString();
        if (value.isNotEmpty && value != 'null') {
          return value;
        }
      }
    }
    return null;
  }

// * Create Branch (MMS API)
  static Future<bool> createBranch({
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
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyBranches,
        token: token,
        context: context,
        data: {
          "name": name,
          "nameAr": nameAr,
          "phone": phone,
          "city": city,
          "address": address,
          "latitude": latitude.isNotEmpty ? double.tryParse(latitude) ?? 0.0 : 0.0,
          "longitude": longitude.isNotEmpty ? double.tryParse(longitude) ?? 0.0 : 0.0,
        },
        headers: {'x-client-type': 'mobile'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static BranchesModel? branchesModel;
  static Future<BranchesModel?> getBranches({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyBranches,
        token: token,
        context: context,
      );

      // Handle empty response body
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return null;
      }

      final body = json.decode(response.body);
      
      if (response.statusCode == 200 && body['success'] == true) {
        // MMS API returns data in {success: true, data: [...]} format
        final branchesData = body['data'] as List<dynamic>? ?? [];
        
        // Map MMS API response to BranchesModel structure
        // MMS API response structure: {id, title, subtitle, branchTitle, branchNameArabic, branchNameEnglish, ...}
        final branches = branchesData.map((branchJson) {
          return Branch(
            id: branchJson['id'] ?? branchJson['Id'] ?? 0,
            customerId: branchJson['customerId'] ?? branchJson['CustomerId'] ?? branchJson['companyId'] ?? branchJson['CompanyId'] ?? 0,
            // Use branchNameEnglish or title or branchTitle for English name
            name: (branchJson['branchNameEnglish'] ?? branchJson['branchTitle'] ?? branchJson['title'] ?? branchJson['name'] ?? branchJson['Name'] ?? '').toString(),
            // Use branchNameArabic or subtitle for Arabic name
            nameAr: (branchJson['branchNameArabic'] ?? branchJson['subtitle'] ?? branchJson['nameAr'] ?? branchJson['NameAr'] ?? branchJson['name'] ?? branchJson['Name'] ?? '').toString(),
            // Map representative_mobile_numb from database schema (backend-mms uses representativeMobileNumber)
            phone: (branchJson['representativeMobileNumber'] ?? branchJson['representativeMobileNumb'] ?? branchJson['representative_mobile_numb'] ?? branchJson['phone'] ?? branchJson['Phone'] ?? '').toString(),
            city: (branchJson['city'] ?? branchJson['City'] ?? '').toString(),
            // Map location from database schema to address
            address: (branchJson['location'] ?? branchJson['Location'] ?? branchJson['address'] ?? branchJson['Address'] ?? '').toString(),
            // Backend-mms now returns latitude and longitude extracted from location URL
            latitude: (branchJson['latitude'] ?? branchJson['Latitude'] ?? '0').toString(),
            longitude: (branchJson['longitude'] ?? branchJson['Longitude'] ?? '0').toString(),
            // Map branch_representative_name from database schema (backend-mms uses branchRepresentativeName)
            representativeName: _getNullableString(branchJson, ['branchRepresentativeName', 'branch_representative_name', 'representativeName', 'RepresentativeName']),
            // Map representative_email_address from database schema (backend-mms uses representativeEmailAddress)
            representativeEmail: _getNullableString(branchJson, ['representativeEmailAddress', 'representative_email_address', 'representativeEmail', 'RepresentativeEmail']),
            // Map team_leader_lookup_id from database schema (backend-mms uses teamLeaderLookupId)
            teamLeaderLookupId: branchJson['teamLeaderLookupId'] ?? branchJson['team_leader_lookup_id'] ?? branchJson['teamLeaderId'] ?? branchJson['team_leader_id'],
            // Map team leader information from nested teamLeader object (backend-mms returns teamLeader object)
            teamLeaderName: branchJson['teamLeader'] != null && branchJson['teamLeader']['name'] != null
                ? branchJson['teamLeader']['name'].toString()
                : _getNullableString(branchJson, ['teamLeaderName', 'team_leader_name']),
            teamLeaderNameArabic: branchJson['teamLeader']?['nameArabic']?.toString(),
            teamLeaderCode: branchJson['teamLeader']?['code']?.toString(),
            teamLeaderDescription: branchJson['teamLeader']?['description']?.toString(),
            // Map company information from nested company object (backend-mms returns company object)
            companyName: branchJson['company'] != null && branchJson['company']['name'] != null
                ? branchJson['company']['name'].toString()
                : _getNullableString(branchJson, ['companyName']),
            companyNameArabic: branchJson['company']?['nameArabic']?.toString(),
            companyId: branchJson['company']?['companyId']?.toString(),
            companyTitle: branchJson['company']?['title']?.toString(),
            companyHoAddress: branchJson['company']?['hoAddress']?.toString(),
          );
        }).toList();

        branchesModel = BranchesModel(branches: branches);
        return branchesModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
