import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/auth_helper.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  static Map<String, String> _setHeaders() => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        "Connection": "keep-alive",
      };


// Todo :-  Get Data
  static Future<http.Response> getData({
    required String query,
    dynamic token,
  }) async {
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse(EndPoints.baseUrl + query),
      headers: headers,
    );
    
    // Check for 401/403 responses and handle auth errors
    await AuthHelper.checkResponseStatus(response.statusCode, query, null, isMMS: false);
    
    return response;
  }

  static Future<http.Response> getData2({
    required String query,
    dynamic token,
    BuildContext? context,
  }) async {
    // Check and refresh token if needed (only for MMS API calls with token)
    if (token != null && query.contains(EndPoints.mmsBaseUrl)) {
      // Ensure token is valid for company personnel before making request
      await AuthHelper.ensureTokenValidForCompanyPersonnel(context);
      
      // Get updated token from provider after potential refresh
      token = await AuthHelper.getUpdatedToken(context, token);
    }

    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse(query),
      headers: headers,
    );
    
    // Check for 401/403 responses and handle auth errors
    await AuthHelper.checkResponseStatus(response.statusCode, query, context, isMMS: query.contains(EndPoints.mmsBaseUrl));
    
    return response;
  }

// Todo :- Post Data
  static Future<http.Response> postData({
    required String query,
    String? token,
    Map<String, dynamic>? data,
  }) async {
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.post(
      Uri.parse(EndPoints.baseUrl + query),
      body: jsonEncode(data),
      headers: headers,
    );
    
    // Check for 401/403 responses and handle auth errors
    await AuthHelper.checkResponseStatus(response.statusCode, query, null, isMMS: false);
    
    return response;
  }

  static Future<http.Response> postData2({
    required String query,
    String? token,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    BuildContext? context,
  }) async {
    // Check and refresh token if needed (only for MMS API calls with token)
    // Skip for login and refresh-token endpoints
    if (token != null && 
        query.contains(EndPoints.mmsBaseUrl) &&
        !query.contains(EndPoints.mmsLogin) &&
        !query.contains(EndPoints.mmsRefreshToken)) {
      // Ensure token is valid for company personnel before making request
      await AuthHelper.ensureTokenValidForCompanyPersonnel(context);
      
      // Get updated token from provider after potential refresh
      token = await AuthHelper.getUpdatedToken(context, token);
    }

    var requestHeaders = _setHeaders();
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    // Merge additional headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    final response = await http.post(
      Uri.parse(query),
      body: jsonEncode(data),
      headers: requestHeaders,
    );
    
    // Check for 401/403 responses and handle auth errors
    await AuthHelper.checkResponseStatus(response.statusCode, query, context, isMMS: query.contains(EndPoints.mmsBaseUrl));
    
    return response;
  }

  // Todo :- Put Data
  static Future<http.Response> putData({
    required String query,
    Map<String, dynamic>? data,
    dynamic token,
  }) async {
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.put(
      Uri.parse(EndPoints.baseUrl + query),
      body: jsonEncode(data),
      headers: headers,
    );
  }

  // Todo :- Remove Data
  static Future<http.Response> removeData({
    required String query,
    Map<String, dynamic>? data,
    dynamic token,
  }) async {
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.delete(
      Uri.parse(EndPoints.baseUrl + query),
      body: jsonEncode(data),
      headers: headers,
    );
  }
}
