import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Functions/token_refresh.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/main.dart' show navigatorKey;
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';

/// Helper class for authentication-related operations
class AuthHelper {
  /// Check if user is company personnel (logged in via backend-mms)
  /// MMS users: Admin (18), Team Leader (20), Technician (21), Sub-Technician (22)
  static bool isCompanyPersonnel(AppProvider appProvider) {
    final currentUserRoleId = appProvider.userModel?.customer.roleId;
    int? roleIdInt;
    if (currentUserRoleId is int) {
      roleIdInt = currentUserRoleId;
    } else if (currentUserRoleId is String) {
      roleIdInt = int.tryParse(currentUserRoleId);
    } else if (currentUserRoleId != null) {
      roleIdInt = int.tryParse(currentUserRoleId.toString());
    }
    final isB2BUser = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22);
    return isB2BUser && appProvider.accessToken != null;
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
  static Future<void> checkResponseStatus(int statusCode, String query, BuildContext? context, {bool isMMS = false, String? responseMessage}) async {
    if (statusCode == 401 || statusCode == 403) {
      // Check if user account is deactivated - force logout immediately
      if (responseMessage == 'User account is deactivated') {
        await _forceLogoutImmediate(context, message: 'User account is deactivated');
        return;
      }
      
      // Check if token is invalid for this service - force logout immediately
      if (responseMessage == 'Invalid token for this service') {
        await _forceLogoutImmediate(context, message: 'Invalid token for this service');
        return;
      }
      
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

  /// Force logout immediately without refresh attempt (for deactivated accounts or invalid tokens)
  static Future<void> _forceLogoutImmediate(BuildContext? context, {String? message}) async {
    try {
      // Get context - try parameter first, then navigatorKey, then wait for it
      BuildContext? ctx = context ?? navigatorKey.currentContext;
      
      // If context is not available, wait a bit and try again
      if (ctx == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        ctx = navigatorKey.currentContext;
      }
      
      if (ctx != null && ctx.mounted) {
        // Show error message to user before logout
        if (message != null) {
          // Get current language
          String? langCode = CacheHelper.getData(key: LANG_CACHE);
          bool isArabic = langCode == 'ar';
          
          String title = isArabic ? 'خطأ في المصادقة' : 'Authentication Error';
          String desc;
          
          if (message == 'Invalid token for this service') {
            desc = isArabic 
                ? 'انتهت صلاحية جلسة تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى للمتابعة.'
                : 'Your session has expired. Please login again to continue.';
          } else if (message == 'User account is deactivated') {
            desc = isArabic
                ? 'تم إلغاء تفعيل حسابك. يرجى التواصل مع الدعم.'
                : 'Your account has been deactivated. Please contact support.';
          } else {
            desc = message;
          }
          
          // Show dialog and wait for user to dismiss it, then logout
          await showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (dialogContext) {
              return WidgetDialog(
                title: title,
                desc: desc,
                isError: true,
                onTap: () {
                  Navigator.of(dialogContext).pop();
                },
              );
            },
          );
          
          // After dialog is dismissed, proceed with logout
          if (ctx.mounted) {
            final appProvider = Provider.of<AppProvider>(ctx, listen: false);
            await _forceLogoutDirect(appProvider, ctx);
          }
        } else {
          // If no message, logout directly
          if (ctx.mounted) {
            final appProvider = Provider.of<AppProvider>(ctx, listen: false);
            await _forceLogoutDirect(appProvider, ctx);
          }
        }
      } else {
        // If context is still not available, try to get AppProvider and logout directly
        // This is a fallback for edge cases
        try {
          final fallbackCtx = navigatorKey.currentContext;
          if (fallbackCtx != null && fallbackCtx.mounted) {
            final appProvider = Provider.of<AppProvider>(fallbackCtx, listen: false);
            await _forceLogoutDirect(appProvider, fallbackCtx);
          } else {
            // If all else fails, just clear cache and tokens
            await CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
          }
        } catch (e) {
          // If all else fails, just clear cache and tokens
          await CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
        }
      }
    } catch (e) {
      // Silent fail - but try to at least clear the session
      try {
        await CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
      } catch (_) {}
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
          // Set logout flag in cache to prevent auto-navigation on app restart
          await CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
          // Clear user data but preserve for biometric login
          appProvider.clearUser(preserveUserDataForBiometric: true);
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

