import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Functions/token_refresh.dart';
import 'package:wefix/main.dart' show navigatorKey;
import 'package:wefix/Presentation/auth/login_screen.dart';

/// Helper class for authentication-related operations
class AuthHelper {
  /// Check if user is company personnel (logged in via backend-mms)
  static bool isCompanyPersonnel(AppProvider appProvider) {
    return appProvider.userModel?.customer.roleId == 2 && appProvider.accessToken != null;
  }

  /// Check and refresh token if needed before making request
  /// Only for MMS API calls (backend-mms) which require token refresh
  static Future<void> ensureValidTokenForMMS(BuildContext? context) async {
    // Call ensureValidToken which will try to get AppProvider from context or navigatorKey
    // Pass null as appProvider to let it get it automatically
    try {
      await ensureValidToken(null, context);
    } catch (e) {
      // Provider might not be available, continue anyway
    }
  }

  /// Get updated token from AppProvider using context or navigatorKey
  static Future<String?> getUpdatedToken(BuildContext? context, String? originalToken) async {
    try {
      BuildContext? ctx = context ?? navigatorKey.currentContext;
      if (ctx != null) {
        final appProvider = Provider.of<AppProvider>(ctx, listen: false);
        if (appProvider.accessToken != null) {
          return appProvider.accessToken;
        }
      }
    } catch (e) {
      // Silent fail
    }
    return originalToken;
  }

  /// Ensure token is valid for company personnel before making MMS API request
  /// Returns true if token is valid, false otherwise
  static Future<bool> ensureTokenValidForCompanyPersonnel(BuildContext? context) async {
    try {
      BuildContext? ctx = context ?? navigatorKey.currentContext;
      if (ctx != null) {
        final appProvider = Provider.of<AppProvider>(ctx, listen: false);
        // If company personnel, check token validity
        if (isCompanyPersonnel(appProvider)) {
          final isValid = await ensureValidToken(appProvider, ctx);
          if (!isValid) {
            // Token expired or invalid - force logout already handled in ensureValidToken
            return false;
          }
          return true;
        }
      }
    } catch (e) {
      // Silent fail
    }
    return true; // If not company personnel, assume valid
  }

  /// Check response status and handle auth errors if needed
  static Future<void> checkResponseStatus(int statusCode, String query, BuildContext? context, {bool isMMS = false}) async {
    if (statusCode == 401 || statusCode == 403) {
      if (isMMS) {
        // For MMS endpoints, handle auth error
        if (query.contains('login') || query.contains('refresh-token')) {
          // Skip auth error handling for login and refresh-token endpoints
          return;
        }
        await handleAuthError(context, isMMS: true);
      } else {
        // For OMS endpoints
        await handleAuthError(context, isMMS: false);
      }
    }
  }

  /// Handle authentication error (401/403) by forcing logout
  /// For backend-mms: tries to refresh token first, then logs out if refresh fails
  /// For backend-oms: only force logout if user is NOT company personnel
  static Future<void> handleAuthError(BuildContext? context, {bool isMMS = false}) async {
    try {
      BuildContext? ctx = context ?? navigatorKey.currentContext;
      if (ctx != null) {
        final appProvider = Provider.of<AppProvider>(ctx, listen: false);
        
        if (isMMS) {
          // For MMS, try to refresh token first (ensureValidToken handles this)
          await ensureValidToken(appProvider, ctx);
        } else {
          // For OMS APIs: only force logout if user is NOT company personnel
          // Company personnel use backend-mms, so 401 from backend-oms is expected
          if (!isCompanyPersonnel(appProvider)) {
            await _forceLogoutDirect(appProvider, ctx);
          }
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Force logout directly without trying to refresh token (for backend-oms)
  static Future<void> _forceLogoutDirect(AppProvider appProvider, BuildContext? context) async {
    try {
      // Schedule logout after current frame is built to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // Clear all user data and tokens
          appProvider.clearUser();
          appProvider.clearTokens();

          // Navigate to login screen using context or navigatorKey
          BuildContext? ctx = context ?? navigatorKey.currentContext;
          if (ctx != null) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          // Silent fail
        }
      });
    } catch (e) {
      // Silent fail
    }
  }
}

