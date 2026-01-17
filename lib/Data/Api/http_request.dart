import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
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

  // Pretty logger for HTTP requests (similar to PrettyDioLogger)
  static void _logRequest(String method, String url, Map<String, String>? headers, dynamic body) {
    if (!kDebugMode) return;
    
    log('╔══════════════════════════════════════════════════════════════════════════════════════════╗', name: 'HTTP');
    log('║  $method: $url', name: 'HTTP');
    if (headers != null && headers.isNotEmpty) {
      log('║  Headers:', name: 'HTTP');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          log('║    $key: Bearer ${value.substring(7).substring(0, value.length > 30 ? 20 : value.length - 7)}...', name: 'HTTP');
        } else {
          log('║    $key: $value', name: 'HTTP');
        }
      });
    }
    if (body != null) {
      log('║  Body: ${body is String ? body : jsonEncode(body)}', name: 'HTTP');
    }
    log('╚══════════════════════════════════════════════════════════════════════════════════════════╝', name: 'HTTP');
  }

  static void _logResponse(int? statusCode, String? body, Map<String, String>? headers) {
    if (!kDebugMode) return;
    
    log('╔══════════════════════════════════════════════════════════════════════════════════════════╗', name: 'HTTP');
    log('║  Response Status: $statusCode', name: 'HTTP');
    if (headers != null && headers.isNotEmpty) {
      log('║  Response Headers:', name: 'HTTP');
      headers.forEach((key, value) {
        log('║    $key: $value', name: 'HTTP');
      });
    }
    if (body != null && body.isNotEmpty) {
      try {
        // Try to parse and beautify JSON
        final decoded = json.decode(body);
        const encoder = JsonEncoder.withIndent('  ');
        final beautified = encoder.convert(decoded);
        
        log('║  Response Body:', name: 'HTTP');
        // Split into lines and add prefix to each line
        beautified.split('\n').forEach((line) {
          log('║  $line', name: 'HTTP');
        });
      } catch (e) {
        // If not JSON, log as plain text
        final truncatedBody = body.length > 500 ? '${body.substring(0, 500)}...' : body;
        log('║  Response Body: $truncatedBody', name: 'HTTP');
      }
    }
    log('╚══════════════════════════════════════════════════════════════════════════════════════════╝', name: 'HTTP');
  }


// Todo :-  Get Data
  static Future<http.Response> getData({
    required String query,
    dynamic token,
  }) async {
    final url = EndPoints.baseUrl + query;
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    _logRequest('GET', url, headers, null);
    
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    // Check for 401/403 responses and handle auth errors
    // Skip auth error handling for guest users (no token)
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (token != null && token.toString().isNotEmpty) {
        // Only handle auth errors if we have a token
        String? responseMessage;
        try {
          final body = json.decode(response.body);
          responseMessage = body['message'];
        } catch (_) {}
        await AuthHelper.checkResponseStatus(response.statusCode, query, null, isMMS: false, responseMessage: responseMessage);
      } else {
        // For guest users with 401, just log it - don't force logout
        log('Guest user received ${response.statusCode} for $query - this is expected for some endpoints', name: 'HTTP');
      }
    }
    
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
    
    _logRequest('GET', query, headers, null);
    
    final response = await http.get(
      Uri.parse(query),
      headers: headers,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    // Check for 401/403 responses and handle auth errors
    String? responseMessage;
    try {
      final body = json.decode(response.body);
      responseMessage = body['message'];
    } catch (_) {}
    await AuthHelper.checkResponseStatus(response.statusCode, query, context, isMMS: query.contains(EndPoints.mmsBaseUrl), responseMessage: responseMessage);
    
    return response;
  }

// Todo :- Post Data
  static Future<http.Response> postData({
    required String query,
    String? token,
    Map<String, dynamic>? data,
  }) async {
    final url = EndPoints.baseUrl + query;
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    _logRequest('POST', url, headers, data);
    
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: headers,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    // Check for 401/403 responses and handle auth errors
    String? responseMessage;
    try {
      final body = json.decode(response.body);
      responseMessage = body['message'];
    } catch (_) {}
    await AuthHelper.checkResponseStatus(response.statusCode, query, null, isMMS: false, responseMessage: responseMessage);
    
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
    
    _logRequest('POST', query, requestHeaders, data);
    
    final response = await http.post(
      Uri.parse(query),
      body: jsonEncode(data),
      headers: requestHeaders,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    // Check for 401/403 responses and handle auth errors
    String? responseMessage;
    try {
      final body = json.decode(response.body);
      responseMessage = body['message'];
    } catch (_) {}
    await AuthHelper.checkResponseStatus(response.statusCode, query, context, isMMS: query.contains(EndPoints.mmsBaseUrl), responseMessage: responseMessage);
    
    return response;
  }

  // Todo :- Put Data
  static Future<http.Response> putData({
    required String query,
    Map<String, dynamic>? data,
    dynamic token,
  }) async {
    final url = EndPoints.baseUrl + query;
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    _logRequest('PUT', url, headers, data);
    
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: headers,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    return response;
  }

  // Todo :- Remove Data
  static Future<http.Response> removeData({
    required String query,
    Map<String, dynamic>? data,
    dynamic token,
  }) async {
    final url = EndPoints.baseUrl + query;
    var headers = _setHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    _logRequest('DELETE', url, headers, data);
    
    final response = await http.delete(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: headers,
    );
    
    _logResponse(response.statusCode, response.body, response.headers);
    
    return response;
  }
}
