import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';

/// Centralized permission management helper
/// Handles all app permissions including notifications, camera, microphone, etc.
class PermissionsHelper {
  PermissionsHelper._();

  /// Check if language is Arabic
  static bool _isArabic(BuildContext? context) {
    if (context == null) return false;
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      return languageProvider.lang == 'ar';
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // NOTIFICATION PERMISSION
  // ============================================================================

  /// Request notification permission on app launch
  /// Shows native iOS dialog automatically
  static Future<void> requestNotificationPermissionOnLaunch() async {
    try {
      final notificationStatus = await Permission.notification.status;
      
      // ALWAYS try to request if not granted - iOS will show dialog if it hasn't been shown yet
      if (!notificationStatus.isGranted) {
        await Permission.notification.request();
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Request notification permission with context (for in-app requests)
  /// On iOS, the native dialog only shows the FIRST time you request.
  /// If already denied, user must go to Settings to enable it.
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    try {
      final status = await Permission.notification.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        // Permanently denied - can't show dialog, user must go to Settings
        return false;
      }
      
      // For iOS: If status is "denied" (not permanently), we can try requesting again
      // BUT: iOS only shows the native dialog the FIRST time. After that, if denied,
      // calling request() again won't show the dialog - user must go to Settings.
      // However, we still call request() in case the status changed (e.g., user toggled in Settings)
      final result = await Permission.notification.request();
      
      // If still denied after request, it means iOS won't show dialog again
      // User needs to go to Settings manually
      if (result.isDenied && !result.isPermanentlyDenied) {
        // Status is "denied" - iOS won't show dialog again automatically
        // We could optionally show a message here, but user requested no messages
        return false;
      }
      
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // CAMERA PERMISSION
  // ============================================================================

  /// Request camera permission
  /// image_picker handles this automatically, but this can be used for pre-checks
  static Future<bool> requestCameraPermission(BuildContext? context) async {
    try {
      log('📷 [PermissionsHelper] Requesting camera permission...');
      final status = await Permission.camera.request();
      log('📷 [PermissionsHelper] Camera permission result: $status');
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied && context != null) {
        final isArabic = _isArabic(context);
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              title: Text(isArabic ? 'إذن الكاميرا مطلوب' : 'Camera Permission Required'),
              content: Text(isArabic
                  ? 'مطلوب الوصول إلى الكاميرا لالتقاط الصور ومقاطع الفيديو.\n\nيرجى تمكين الإذن في الإعدادات.'
                  : 'Camera access is required to take photos and videos.\n\nPlease enable permission in Settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(isArabic ? 'فتح الإعدادات' : 'Open Settings'),
                ),
              ],
            ),
          ),
        ) ?? false;
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      }
      
      return false;
    } catch (e) {
      log('❌ [PermissionsHelper] Error requesting camera permission: $e');
      return false;
    }
  }

  // ============================================================================
  // MICROPHONE PERMISSION
  // ============================================================================

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission(BuildContext? context) async {
    try {
      final status = await Permission.microphone.request();
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied && context != null) {
        final isArabic = _isArabic(context);
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: AlertDialog(
              title: Text(isArabic ? 'إذن الميكروفون مطلوب' : 'Microphone Permission Required'),
              content: Text(isArabic
                  ? 'مطلوب الوصول إلى الميكروفون لتسجيل الصوت.\n\nيرجى تمكين الإذن في الإعدادات.'
                  : 'Microphone access is required to record audio.\n\nPlease enable permission in Settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(isArabic ? 'فتح الإعدادات' : 'Open Settings'),
                ),
              ],
            ),
          ),
        ) ?? false;
        
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // PHOTO LIBRARY PERMISSION
  // ============================================================================

  /// Request photo library permission
  static Future<bool> requestPhotoLibraryPermission(BuildContext? context) async {
    try {
      final status = await Permission.photos.request();
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied && context != null) {
        final isArabic = _isArabic(context);
        BotToast.showText(
          text: isArabic
              ? 'مطلوب الوصول إلى الصور. يرجى تمكينه من الإعدادات.'
              : 'Photo library access is required. Please enable it in Settings.',
        );
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // LOCATION PERMISSION
  // ============================================================================

  /// Request location permission (when in use)
  static Future<bool> requestLocationPermission(BuildContext? context) async {
    try {
      final status = await Permission.locationWhenInUse.request();
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied && context != null) {
        final isArabic = _isArabic(context);
        BotToast.showText(
          text: isArabic
              ? 'مطلوب الوصول إلى الموقع. يرجى تمكينه من الإعدادات.'
              : 'Location access is required. Please enable it in Settings.',
        );
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // PERMISSION STATUS CHECKS
  // ============================================================================

  /// Check if notification permission is granted
  static Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }
}
