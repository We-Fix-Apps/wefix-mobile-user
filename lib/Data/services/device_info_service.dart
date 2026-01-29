import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get device ID with metadata (model, brand, etc.)
  /// Returns a JSON string containing device information
  static Future<String> getDeviceIdWithMetadata() async {
    try {
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceData = {
          'deviceId': androidInfo.id,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'androidId': androidInfo.id,
          'systemVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'platform': 'Android',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceData = {
          'deviceId': iosInfo.identifierForVendor ?? '',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'utsname': iosInfo.utsname.machine,
          'platform': 'iOS',
        };
      } else {
        // Web or other platforms
        deviceData = {
          'deviceId': 'unknown',
          'platform': kIsWeb ? 'Web' : 'Unknown',
        };
      }

      // Convert to JSON string
      return jsonEncode(deviceData);
    } catch (e) {
      // Fallback if device info fails
      return 'unknown_device';
    }
  }

  /// Get device ID only (for backward compatibility)
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      } else {
        return 'unknown';
      }
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get device metadata as a formatted string
  /// Format: "Brand Model (Platform Version)"
  /// Example: "Samsung Galaxy S21 (Android 12)"
  static Future<String> getDeviceMetadataString() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return '${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Get device metadata as JSON object
  static Future<Map<String, dynamic>> getDeviceMetadata() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'deviceId': androidInfo.id,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'systemVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'platform': 'Android',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor ?? '',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'utsname': iosInfo.utsname.machine,
          'platform': 'iOS',
        };
      } else {
        return {
          'deviceId': 'unknown',
          'platform': kIsWeb ? 'Web' : 'Unknown',
        };
      }
    } catch (e) {
      return {
        'deviceId': 'unknown',
        'platform': 'Unknown',
        'error': e.toString(),
      };
    }
  }
}

