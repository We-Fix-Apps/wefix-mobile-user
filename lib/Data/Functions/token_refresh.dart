import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Data/Functions/token_utils.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/main.dart' show navigatorKey;

/// Refresh promise to prevent multiple simultaneous refresh calls
Future<bool>? _refreshPromise;

/// Refreshes the access token using the refresh token
/// Returns true if successful, false otherwise
Future<bool> refreshAccessToken(AppProvider appProvider) async {
  // If there's already a refresh in progress, wait for it
  if (_refreshPromise != null) {
    return _refreshPromise!;
  }

  _refreshPromise = (() async {
    try {
      final currentRefreshToken = appProvider.refreshToken;

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        return false;
      }

      // Call refresh token API
      final result = await Authantication.mmsRefreshToken(
        refreshToken: currentRefreshToken,
      );

      if (result != null && result['accessToken'] != null) {
        // Update tokens in provider
        appProvider.setTokens(
          access: result['accessToken'],
          refresh: result['refreshToken'],
          type: result['tokenType'],
          expires: result['expiresIn'],
        );

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _refreshPromise = null;
    }
  })();

  return _refreshPromise!;
}

/// Get AppProvider from context or navigatorKey
AppProvider? _getAppProvider(BuildContext? context) {
  BuildContext? ctx = context ?? navigatorKey.currentContext;
  if (ctx != null) {
    try {
      return Provider.of<AppProvider>(ctx, listen: false);
    } catch (e) {
      return null;
    }
  }
  return null;
}

/// Checks if token needs refresh and refreshes it if needed
/// Should be called before making authenticated requests
/// Only refreshes if app is in foreground (user is actively using the app)
/// Returns true if token is valid or refreshed successfully, false otherwise
/// If appProvider is not provided, it will try to get it from context or navigatorKey
Future<bool> ensureValidToken(AppProvider? appProvider, BuildContext? context) async {
  // Try to get AppProvider if not provided
  appProvider ??= _getAppProvider(context);
  if (appProvider == null) {
    return false;
  }

  // If no access token, token is invalid
  if (appProvider.accessToken == null || appProvider.accessToken!.isEmpty) {
    return false;
  }

  // Get token expiration date
  DateTime? tokenExpiresAt = appProvider.tokenExpiresAt;
  
  // If tokenExpiresAt is null but we have accessToken and refreshToken, try to refresh token
  // This handles the case where token was loaded from cache but tokenExpiresAt was not saved/loaded properly
  if (tokenExpiresAt == null && appProvider.refreshToken != null && appProvider.refreshToken!.isNotEmpty) {
    final refreshed = await refreshAccessToken(appProvider);
    if (refreshed) {
      tokenExpiresAt = appProvider.tokenExpiresAt;
    } else {
      return false;
    }
  }

  // If no token expiration after refresh attempt, can't determine validity
  if (tokenExpiresAt == null) {
    return false;
  }

  // Check if token is expired
  if (!isTokenValid(tokenExpiresAt)) {
    // Token expired - force logout
    await _forceLogout(appProvider, context);
    return false;
  }

  // Check if token should be refreshed (less than 30 minutes remaining)
  if (shouldRefreshToken(tokenExpiresAt)) {
    // Refresh token - allow refresh even if app was in background (now resumed)
    final refreshed = await refreshAccessToken(appProvider);
    
    if (!refreshed) {
      // Refresh failed - force logout
      await _forceLogout(appProvider, context);
      return false;
    }
    
    return true;
  }
  
  // If token is expired but we have refresh token, try to refresh it
  // This handles the case where app was left in background and token expired
  if (!isTokenValid(tokenExpiresAt) && appProvider.refreshToken != null && appProvider.refreshToken!.isNotEmpty) {
    log('Token expired, attempting refresh...');
    final refreshed = await refreshAccessToken(appProvider);
    
    if (!refreshed) {
      // Refresh failed - force logout
      await _forceLogout(appProvider, context);
      return false;
    }
    
    return true;
  }

  // Token is valid and doesn't need refresh
  return true;
}

/// Force logout user when token expires or refresh fails
Future<void> _forceLogout(AppProvider appProvider, BuildContext? context) async {
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
