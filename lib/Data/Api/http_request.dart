import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Functions/token_refresh.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  static Map<String, String> _setHeaders() => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        "Connection": "keep-alive",
      };

  /// Check and refresh token if needed before making request
  /// Only for MMS API calls (backend-mms) which require token refresh
  static Future<void> _ensureValidTokenForMMS(BuildContext? context) async {
    // Call ensureValidToken which will try to get AppProvider from context or navigatorKey
    // Pass null as appProvider to let it get it automatically
    try {
      await ensureValidToken(null, context);
    } catch (e) {
      // Provider might not be available, continue anyway
    }
  }

// Todo :-  Get Data
  static Future<http.Response> getData({
    required String query,
    dynamic token,
  }) async {
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(
      Uri.parse(EndPoints.baseUrl + query),
      headers: headers,
    );
  }

  static Future<http.Response> getData2({
    required String query,
    dynamic token,
    BuildContext? context,
  }) async {
    // Check and refresh token if needed (only for MMS API calls with token)
    if (token != null && query.contains(EndPoints.mmsBaseUrl)) {
      await _ensureValidTokenForMMS(context);
      
      // Get updated token from provider after potential refresh
      // Try to get AppProvider from context or navigatorKey
      try {
        BuildContext? ctx = context;
        if (ctx == null) {
          // Try to get context from navigatorKey (imported from main.dart via token_refresh)
          // For now, we'll skip if context is not available
        } else {
          final appProvider = Provider.of<AppProvider>(ctx, listen: false);
          if (appProvider.accessToken != null) {
            token = appProvider.accessToken;
          }
        }
      } catch (e) {
        // Continue with original token if provider not available
      }
    }

    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return await http.get(
      Uri.parse(query),
      headers: headers,
    );
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
    return await http.post(
      Uri.parse(EndPoints.baseUrl + query),
      body: jsonEncode(data),
      headers: headers,
    );
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
      await _ensureValidTokenForMMS(context);
      
      // Get updated token from provider after potential refresh
      // Try to get AppProvider from context or navigatorKey
      try {
        BuildContext? ctx = context;
        if (ctx == null) {
          // Try to get context from navigatorKey (imported from main.dart via token_refresh)
          // For now, we'll skip if context is not available
        } else {
          final appProvider = Provider.of<AppProvider>(ctx, listen: false);
          if (appProvider.accessToken != null) {
            token = appProvider.accessToken;
          }
        }
      } catch (e) {
        // Continue with original token if provider not available
      }
    }

    var requestHeaders = _setHeaders();
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }
    // Merge additional headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    return await http.post(
      Uri.parse(query),
      body: jsonEncode(data),
      headers: requestHeaders,
    );
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
