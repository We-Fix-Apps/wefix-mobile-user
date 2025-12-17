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
        log('refreshAccessToken: No refresh token available');
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

        log('refreshAccessToken: Token refreshed successfully');
        return true;
      } else {
        log('refreshAccessToken: Refresh failed - invalid response');
        return false;
      }
    } catch (e) {
      log('refreshAccessToken: Error refreshing token - $e');
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

/// Check if app is currently in foreground/active state
bool _isAppInForeground() {
  final lifecycleState = WidgetsBinding.instance.lifecycleState;
  // App is active/in foreground if lifecycleState is resumed
  return lifecycleState == AppLifecycleState.resumed;
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
    log('ensureValidToken: AppProvider not available');
    return false;
  }
  final tokenExpiresAt = appProvider.tokenExpiresAt;

  // If no token expiration, can't determine validity
  if (tokenExpiresAt == null) {
    log('ensureValidToken: No token expiration date');
    return false;
  }

  // Check if token is expired
  if (!isTokenValid(tokenExpiresAt)) {
    log('ensureValidToken: Token expired - forcing logout');
    // Token expired - force logout
    await _forceLogout(appProvider, context);
    return false;
  }

  // Check if token should be refreshed (less than 30 minutes remaining)
  if (shouldRefreshToken(tokenExpiresAt)) {
    // Only refresh token if app is in foreground (user is actively using the app)
    if (!_isAppInForeground()) {
      log('ensureValidToken: Token needs refresh but app is in background - skipping refresh');
      // Don't refresh if app is in background, but token is still valid
      return true;
    }

    log('ensureValidToken: Token needs refresh (less than 30 minutes remaining) and app is active');
    final refreshed = await refreshAccessToken(appProvider);
    
    if (!refreshed) {
      log('ensureValidToken: Token refresh failed - forcing logout');
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
    // Clear all user data and tokens
    appProvider.clearUser();
    appProvider.clearTokens();

    // Navigate to login screen if context is available
    // Note: If context is not provided, navigation will be handled by the caller
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    log('_forceLogout: Error during force logout - $e');
  }
}

