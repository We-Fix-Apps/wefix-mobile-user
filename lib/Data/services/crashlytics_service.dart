import 'dart:convert';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/model/user_model.dart';

class CrashlyticsService {
  /// Initialize Crashlytics and set user info from cache if available
  static Future<void> initialize() async {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Set user info from cache if available
    await setUserInfoFromCache();
  }

  /// Set user info in Crashlytics from cached user data
  static Future<void> setUserInfoFromCache() async {
    try {
      final String? userData = CacheHelper.getData(key: CacheHelper.userData);
      if (userData != null && userData != 'null' && userData != CacheHelper.clearUserData) {
        final body = json.decode(userData);
        final userModel = UserModel.fromJson(body);
        await setUserInfo(userModel);
      }
    } catch (e) {
      // Silently fail - user might not be logged in
    }
  }

  /// Set user info in Crashlytics from UserModel
  static Future<void> setUserInfo(UserModel? userModel) async {
    if (userModel == null) {
      // Clear user info if user is null
      await FirebaseCrashlytics.instance.setUserIdentifier('');
      return;
    }

    final customer = userModel.customer;
    
    // Set user ID - use id as primary identifier
    await FirebaseCrashlytics.instance.setUserIdentifier(customer.id.toString());

    // Set custom keys with full user info - matching mobile-technician structure
    await FirebaseCrashlytics.instance.setCustomKey('user_id', customer.id);
    
    // user_name (maps to name in Customer model)
    if (customer.name.isNotEmpty) {
      await FirebaseCrashlytics.instance.setCustomKey('user_name', customer.name);
      // Also set as user_full_name to match mobile-technician structure
      await FirebaseCrashlytics.instance.setCustomKey('user_full_name', customer.name);
    }
    if (customer.email.isNotEmpty) {
      await FirebaseCrashlytics.instance.setCustomKey('user_email', customer.email);
    }
    // user_mobile (maps to mobile in Customer model)
    if (customer.mobile.isNotEmpty) {
      await FirebaseCrashlytics.instance.setCustomKey('user_mobile', customer.mobile);
      // Also set as user_mobile_number to match mobile-technician structure
      await FirebaseCrashlytics.instance.setCustomKey('user_mobile_number', customer.mobile);
    }
    if (customer.roleId != null) {
      await FirebaseCrashlytics.instance.setCustomKey('user_role_id', customer.roleId.toString());
    }
    await FirebaseCrashlytics.instance.setCustomKey('user_provider_id', customer.providerId);
    
    if (customer.address.isNotEmpty) {
      await FirebaseCrashlytics.instance.setCustomKey('user_address', customer.address);
    }
    await FirebaseCrashlytics.instance.setCustomKey('user_created_date', customer.createdDate.toIso8601String());
    // Also set as user_created_at to match mobile-technician structure
    await FirebaseCrashlytics.instance.setCustomKey('user_created_at', customer.createdDate.toIso8601String());
    
    // Set wallet info if available
    if (userModel.wallet != null) {
      await FirebaseCrashlytics.instance.setCustomKey('user_wallet', userModel.wallet!);
    }
  }

  /// Clear user info from Crashlytics (e.g., on logout)
  static Future<void> clearUserInfo() async {
    await FirebaseCrashlytics.instance.setUserIdentifier('');
    await FirebaseCrashlytics.instance.setCustomKey('user_id', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_name', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_full_name', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_email', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_mobile', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_mobile_number', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_role_id', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_provider_id', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_address', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_created_date', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_created_at', '');
    await FirebaseCrashlytics.instance.setCustomKey('user_wallet', '');
  }

  /// Log a non-fatal error
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Trigger a test crash to verify Crashlytics is working
  /// This will throw an exception that will be captured by Crashlytics
  static void testCrash() {
    FirebaseCrashlytics.instance.crash();
  }

  /// Trigger a test non-fatal error to verify Crashlytics is working
  /// This will record an error without crashing the app
  static Future<void> testError() async {
    try {
      throw Exception('Test error for Firebase Crashlytics');
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Test error to verify Crashlytics integration',
        fatal: false,
      );
    }
  }
}
