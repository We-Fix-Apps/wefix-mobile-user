import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Profile/Screens/ticket_details_loader.dart';
import 'package:wefix/Presentation/Profile/Screens/notifications_screen.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/main.dart';
import 'awesome_notification.service.dart';
import 'notification_cache_service.dart';

class FcmHelper {
  // prevent making instance
  FcmHelper._();

  // FCM Messaging
  static late FirebaseMessaging messaging;
  
  // Store pending notification data for navigation after splash screen
  static Map<String, dynamic>? pendingNotificationData;
  
  // Flag to prevent multiple navigation attempts
  static bool _isNavigating = false;
  
  // Cache keys for persistent storage (works across isolates)
  static const String _pendingNotificationKey = 'pending_notification_data';
  static const String _splashCompletedKey = 'splash_screen_completed';
  static bool _splashCompletedInCurrentRun = false;
  static bool _splashGateInitialized = false;
  
  /// Clear pending notification data (both in-memory and persistent storage)
  static void _clearPendingNotificationData() {
    pendingNotificationData = null;
    try {
      CacheHelper.removeData(key: _pendingNotificationKey);
    } catch (e) {
      // Error clearing stored notification
    }
  }
  
  /// Check if splash screen has completed (from persistent storage - works across isolates)
  static bool _isSplashScreenCompleted() {
    if (_splashCompletedInCurrentRun) return true;
    if (_splashGateInitialized) return false;

    try {
      final completed = CacheHelper.getData(key: _splashCompletedKey);
      return completed == true || completed == 'true';
    } catch (e) {
      return false;
    }
  }
  
  /// Public method to check if splash screen has completed
  /// Used to determine if we can navigate immediately when app is already running
  static bool isSplashScreenCompleted() {
    return _isSplashScreenCompleted();
  }
  
  /// Mark that splash screen has completed - allows immediate navigation when notification data arrives
  /// Uses persistent storage so it works across isolates
  static void markSplashScreenCompleted() {
    try {
      _splashCompletedInCurrentRun = true;
      _splashGateInitialized = true;
      CacheHelper.saveData(key: _splashCompletedKey, value: true);
      
      // Don't trigger navigation here - let _onSplashExit() handle it
      // This prevents duplicate navigation calls
      // _checkAndNavigateFromStoredNotification(); // REMOVED - navigation handled by _onSplashExit()
    } catch (e) {
      // Error marking splash as completed
    }
  }
  
  /// Clear splash completion state at startup.
  /// Must be called before notification handlers run.
  static void clearSplashScreenCompleted() {
    _splashCompletedInCurrentRun = false;
    _splashGateInitialized = true;
    try {
      CacheHelper.removeData(key: _splashCompletedKey);
    } catch (e) {
      // Error clearing splash flag
    }
  }
  
  // Deduplication: Track recently created notification IDs and content to prevent duplicates
  // Use both in-memory (for fast access) and persistent storage (for cross-isolate deduplication)
  static final Set<int> _recentNotificationIds = <int>{};
  static final Map<int, DateTime> _notificationTimestamps = <int, DateTime>{};
  static final Map<String, DateTime> _recentNotificationContent = <String, DateTime>{};
  
  // Cache keys for persistent storage
  static const String _notificationIdsKey = 'recent_notification_ids';
  static const String _notificationContentKey = 'recent_notification_content';
  
  // Clean up old notification IDs and content (older than 30 seconds)
  // Increased window to catch duplicates across isolates
  static Future<void> _cleanupOldNotificationIds() async {
    try {
      final now = DateTime.now();
      
      // Clean up in-memory data
      _notificationTimestamps.removeWhere((id, timestamp) {
        if (now.difference(timestamp).inSeconds > 30) {
          _recentNotificationIds.remove(id);
          return true;
        }
        return false;
      });
      _recentNotificationContent.removeWhere((content, timestamp) {
        return now.difference(timestamp).inSeconds > 30;
      });
      
      // Clean up persistent storage
      final storedIdsJson = CacheHelper.getData(key: _notificationIdsKey) as String?;
      if (storedIdsJson != null) {
        try {
          final storedIds = Map<String, dynamic>.from(json.decode(storedIdsJson));
          final cleanedIds = <String, dynamic>{};
          storedIds.forEach((id, timestampMillis) {
            if (timestampMillis is int) {
              final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
              if (now.difference(timestamp).inSeconds <= 30) {
                cleanedIds[id] = timestampMillis;
              }
            }
          });
          await CacheHelper.saveData(key: _notificationIdsKey, value: json.encode(cleanedIds));
        } catch (e) {
          // Error parsing stored notification IDs
        }
      }
      
      final storedContentJson = CacheHelper.getData(key: _notificationContentKey) as String?;
      if (storedContentJson != null) {
        try {
          final storedContent = Map<String, dynamic>.from(json.decode(storedContentJson));
          final cleanedContent = <String, dynamic>{};
          storedContent.forEach((content, timestampMillis) {
            if (timestampMillis is int) {
              final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
              if (now.difference(timestamp).inSeconds <= 30) {
                cleanedContent[content] = timestampMillis;
              }
            }
          });
          await CacheHelper.saveData(key: _notificationContentKey, value: json.encode(cleanedContent));
        } catch (e) {
          // Error parsing stored notification content
        }
      }
    } catch (e) {
      // Error cleaning up old notification IDs
    }
  }
  
  // Check if notification ID or content was recently created (within last 30 seconds)
  // Checks both in-memory and persistent storage for cross-isolate deduplication
  static Future<bool> _isDuplicateNotification(int notificationId, String title, String body) async {
    await _cleanupOldNotificationIds();
    
    final now = DateTime.now();
    final notificationIdStr = notificationId.toString();
    
    // Check in-memory first (fast)
    if (_recentNotificationIds.contains(notificationId)) {
      return true;
    }
    
    // Check persistent storage (for cross-isolate deduplication)
    try {
      final storedIdsJson = CacheHelper.getData(key: _notificationIdsKey) as String?;
      if (storedIdsJson != null) {
        final storedIds = Map<String, dynamic>.from(json.decode(storedIdsJson));
        if (storedIds.containsKey(notificationIdStr)) {
          final timestampMillis = storedIds[notificationIdStr] as int?;
          if (timestampMillis != null) {
            final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
            if (now.difference(timestamp).inSeconds < 30) {
              return true;
            }
          }
        }
      }
    } catch (e) {
      // Error checking persistent storage for duplicate ID
    }
    
    // Also check by content (title + body) to catch duplicates even if IDs somehow differ
    final contentKey = '${title}_$body';
    
    // Check in-memory
    if (_recentNotificationContent.containsKey(contentKey)) {
      final lastSeen = _recentNotificationContent[contentKey]!;
      if (now.difference(lastSeen).inSeconds < 30) {
        return true;
      }
    }
    
    // Check persistent storage for content
    try {
      final storedContentJson = CacheHelper.getData(key: _notificationContentKey) as String?;
      if (storedContentJson != null) {
        final storedContent = Map<String, dynamic>.from(json.decode(storedContentJson));
        if (storedContent.containsKey(contentKey)) {
          final timestampMillis = storedContent[contentKey] as int?;
          if (timestampMillis != null) {
            final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
            if (now.difference(timestamp).inSeconds < 30) {
              return true;
            }
          }
        }
      }
    } catch (e) {
      // Error checking persistent storage for duplicate content
    }
    
    return false;
  }
  
  // Mark notification ID and content as created (both in-memory and persistent storage)
  static Future<void> _markNotificationCreated(int notificationId, String title, String body) async {
    final now = DateTime.now();
    final nowMillis = now.millisecondsSinceEpoch;
    final notificationIdStr = notificationId.toString();
    final contentKey = '${title}_$body';
    
    // Update in-memory
    _recentNotificationIds.add(notificationId);
    _notificationTimestamps[notificationId] = now;
    _recentNotificationContent[contentKey] = now;
    
    // Update persistent storage for cross-isolate deduplication
    try {
      final storedIdsJson = CacheHelper.getData(key: _notificationIdsKey) as String?;
      final storedIds = storedIdsJson != null 
          ? Map<String, dynamic>.from(json.decode(storedIdsJson))
          : <String, dynamic>{};
      storedIds[notificationIdStr] = nowMillis;
      await CacheHelper.saveData(key: _notificationIdsKey, value: json.encode(storedIds));
      
      final storedContentJson = CacheHelper.getData(key: _notificationContentKey) as String?;
      final storedContent = storedContentJson != null
          ? Map<String, dynamic>.from(json.decode(storedContentJson))
          : <String, dynamic>{};
      storedContent[contentKey] = nowMillis;
      await CacheHelper.saveData(key: _notificationContentKey, value: json.encode(storedContent));
    } catch (e) {
      // Error saving notification to persistent storage
    }
  }

  /// this function will initialize firebase and fcm instance
  static Future<void> initFcm() async {
    try {
      messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();
      await messaging.setAutoInitEnabled(true);
      // String? token;
      if (Platform.isIOS) {
         await messaging.getAPNSToken();
      } else if (Platform.isAndroid) {
         await messaging.getToken();
      }
      await _setupFcmNotificationSettings();
       

      // Register foreground handler to show localized system notifications
      FirebaseMessaging.onMessage.listen(_fcmForegroundHandler);
      
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    } catch (error) {
      // FCM Error
    }
  }

  ///handle fcm notification settings (sound,badge..etc)
  static Future<void> _setupFcmNotificationSettings() async {
    // Disable automatic notification display in foreground
    // We handle foreground notifications manually with Awesome Notifications (localized)
    // This prevents Android from showing the default English FCM notification
    messaging.setForegroundNotificationPresentationOptions(
      alert: false, // Don't show default notification in foreground
      sound: false, // We'll handle sound in our custom notification
      badge: true,  // Still update badge
    );

    //NotificationSettings settings
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
  }

  /// generate and save fcm token if its not already generated (generate only for 1 time)
  // static Future<void> _generateFcmToken() async {
  //   try {
  //     var token = await messaging.getToken();
  //     if (token != null) {
  //       Get.put(AppServices()).appBox.put(BoxKey.firebaseToken, token);
  //
  //       _sendFcmTokenToServer();
  //     } else {
  //       // retry generating token
  //       await Future.delayed(const Duration(seconds: 5));
  //       _generateFcmToken();
  //     }
  //   } catch (error) {
  //     log(error);
  //   }
  // }

  // static _sendFcmTokenToServer() {
  //   Get.find<AppServices>().appBox.get(BoxKey.firebaseToken);
  // }

  // Helper function to get localized notification text
  static String _getLocalizedNotificationText(
    Map<String, dynamic> data,
    String defaultText,
    String enKey,
    String arKey,
  ) {
    try {
      // Initialize SharedPreferences in background isolate
      // Note: This might already be initialized, but we ensure it's available
      
      // Get user's language preference
      final langCode = CacheHelper.getData(key: LANG_CACHE);
      
      // Handle both string and dynamic types
      String? langString;
      if (langCode is String) {
        langString = langCode;
      } else if (langCode != null) {
        langString = langCode.toString();
      }
      
      // Default to English if language is not set
      // Both apps should default to English for consistency
      if (langString == null || langString.isEmpty) {
        langString = 'en';
      }
      
      final isArabic = langString.toLowerCase().trim() == 'ar';

      // Check if localized data exists in message.data
      if (data.containsKey(enKey) || data.containsKey(arKey)) {
        final enValue = data[enKey]?.toString().trim() ?? '';
        final arValue = data[arKey]?.toString().trim() ?? '';
        
        if (isArabic) {
          // Prefer Arabic, fallback to English, then default
          final result = arValue.isNotEmpty 
              ? arValue 
              : (enValue.isNotEmpty ? enValue : defaultText);
          return result;
        } else {
          // Prefer English, fallback to Arabic, then default
          final result = enValue.isNotEmpty 
              ? enValue 
              : (arValue.isNotEmpty ? arValue : defaultText);
          return result;
        }
      }

      // Fallback to default notification text
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    } catch (e) {
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    }
  }

  //handle fcm notification when app is open (foreground)
  @pragma('vm:entry-point')
  static Future<void> _fcmForegroundHandler(RemoteMessage message) async {
    // Skip if we don't have notification data to avoid showing empty notifications
    if (!message.data.containsKey('titleEn') && 
        !message.data.containsKey('titleAr') && 
        message.notification == null) {
      return;
    }
    
    // Get localized notification text
    final localizedTitle = _getLocalizedNotificationText(
      message.data,
      message.notification?.title ?? 'New Notification',
      'titleEn',
      'titleAr',
    );
    final localizedBody = _getLocalizedNotificationText(
      message.data,
      message.notification?.body ?? 'You have a new notification',
      'bodyEn',
      'bodyAr',
    );

    // Create a localized system notification that will appear in notification tray (when user swipes down)
    // This won't show as a heads-up because we set alert: false in setForegroundNotificationPresentationOptions
    try {
      // Generate consistent notification ID based on ticketId and type to prevent duplicates
      // Using consistent ID ensures duplicates replace each other instead of creating new ones
      final ticketId = message.data['ticketId']?.toString();
      final notificationType = message.data['type']?.toString() ?? 'general';
      
      // Create consistent ID: combine ticketId (if exists) and type
      // This ensures the same notification (same ticketId + type) replaces the previous one instead of creating duplicates
      // Only use timestamp as fallback if no ticketId is available
      final notificationIdString = ticketId != null && ticketId.isNotEmpty
          ? '${ticketId}_${notificationType}'
          : '${notificationType}_${DateTime.now().millisecondsSinceEpoch}';
      final uniqueNotificationId = notificationIdString.hashCode.abs() % 2147483647;
      
      // Check for duplicates before creating notification (by ID and content)
      final isDuplicate = await _isDuplicateNotification(uniqueNotificationId, localizedTitle, localizedBody);
      if (isDuplicate) {
        return;
      }
      
      // Mark as created to prevent duplicates
      await _markNotificationCreated(uniqueNotificationId, localizedTitle, localizedBody);
      
      // Cache the notification
      final cachedNotification = CachedNotification(
        id: uniqueNotificationId.toString(),
        ticketId: ticketId,
        title: localizedTitle,
        titleAr: message.data['titleAr']?.toString(),
        description: localizedBody,
        descriptionAr: message.data['bodyAr']?.toString(),
        createdDate: DateTime.now(),
        data: message.data.cast(),
      );
      await NotificationCacheService.saveNotification(cachedNotification);
      
      // Create notification with localized text
      // This will appear in notification tray but not as a heads-up (no duplicate with BotToast)
      await NotificationsController.createNewNotification(
          title: localizedTitle.isNotEmpty ? localizedTitle : 'New Notification',
          body: localizedBody.isNotEmpty ? localizedBody : 'You have a new notification',
          bigPicture: '',
          payload: message.data.cast(),
          notificationId: uniqueNotificationId);
    } catch (e) {
      // Error creating system notification
    }
    
    // Show BotToast snackbar for in-app display after a delay
    // This ensures the system notification appears first
    // Also check for duplicates before showing BotToast
    Future.delayed(const Duration(milliseconds: 4500), () async {
      // Re-check for duplicates before showing BotToast (in case multiple messages arrive)
      final ticketId = message.data['ticketId']?.toString();
      final notificationType = message.data['type']?.toString() ?? 'general';
      final botToastNotificationIdString = ticketId != null && ticketId.isNotEmpty
          ? '${ticketId}_${notificationType}_bottoast'
          : '${notificationType}_${DateTime.now().millisecondsSinceEpoch}_bottoast';
      final botToastNotificationId = botToastNotificationIdString.hashCode.abs() % 2147483647;
      
      // Check if this BotToast notification was already shown
      final isDuplicate = await _isDuplicateNotification(botToastNotificationId, localizedTitle, localizedBody);
      if (!isDuplicate) {
        await _markNotificationCreated(botToastNotificationId, localizedTitle, localizedBody);
        _showInAppNotification(localizedTitle, localizedBody, message.data);
      }
    });
  }
  
  // Helper function to show in-app BotToast notification
  static void _showInAppNotification(String title, String body, Map<String, dynamic> data) {
    try {
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        BotToast.showNotification(
          onTap: () {
            // Get fresh context when tapped to ensure app is opened and ready
            _navigateFromNotification(context, data);
          },
          contentPadding: const EdgeInsets.all(8.0),
          align: Alignment.topCenter,
          title: (w) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: AppColors(context).primaryColor,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: AppSize(context).smallText2,
                            color: AppColors(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
          subtitle: (w) => Text(
                body,
                style: TextStyle(
                  color: AppColors.greyColor2,
                  fontWeight: FontWeight.normal,
                  fontSize: AppSize(context).smallText3,
                ),
              ),
          duration: const Duration(seconds: 5));
      }
    } catch (e) {
      // Error showing in-app notification
    }
  }
  
  /// Store notification data for later navigation (after splash screen)
  /// Called when app is opened from background/terminated state via notification
  /// Uses persistent storage so it works across isolates
  static Future<void> storePendingNotification(Map<String, dynamic> data) async {
    developer.log('💾 [FCM] storePendingNotification called with data: $data');
    print('💾 [FCM] storePendingNotification called with data: $data');
    
    // Check if notification data already exists to prevent duplicate storage
    final existingData = pendingNotificationData;
    final existingStoredJson = CacheHelper.getData(key: _pendingNotificationKey) as String?;
    
    if (existingData != null || (existingStoredJson != null && existingStoredJson.isNotEmpty)) {
      developer.log('⚠️ [FCM] Notification data already exists, skipping duplicate storage');
      print('⚠️ [FCM] Notification data already exists, skipping duplicate storage');
      return; // Don't store duplicate - navigation will be handled by existing data
    }
    
    // Store in memory
    pendingNotificationData = data;
    developer.log('✅ [FCM] Stored in memory');
    print('✅ [FCM] Stored in memory');
    
    // Store persistently (works across isolates)
    try {
      final dataJson = json.encode(data);
      await CacheHelper.saveData(key: _pendingNotificationKey, value: dataJson);
      developer.log('✅ [FCM] Stored persistently');
      print('✅ [FCM] Stored persistently');
    } catch (e) {
      developer.log('❌ [FCM] Error storing notification persistently: $e');
      print('❌ [FCM] Error storing notification persistently: $e');
    }
    
    // Don't trigger navigation here - let _onSplashExit() handle it
    // This prevents duplicate navigation calls
    developer.log('⏳ [FCM] Notification stored, will navigate after splash completes');
    print('⏳ [FCM] Notification stored, will navigate after splash completes');
  }
  
  /// Public method to navigate from Firebase Messaging notification tap
  /// This should be called AFTER the splash screen completes
  /// Also checks persistent storage in case data is in a different isolate
  static void navigateFromPendingNotification() {
    developer.log('🔍 [FCM] navigateFromPendingNotification called');
    print('🔍 [FCM] navigateFromPendingNotification called');
    
    // Prevent multiple simultaneous navigation attempts
    if (_isNavigating) {
      developer.log('⏸️ [FCM] Navigation already in progress, skipping');
      print('⏸️ [FCM] Navigation already in progress, skipping');
      return;
    }
    
    // First try in-memory data
    Map<String, dynamic>? data = pendingNotificationData;
    developer.log('💾 [FCM] In-memory data: ${data != null ? "Found" : "Not found"}');
    print('💾 [FCM] In-memory data: ${data != null ? "Found" : "Not found"}');
    
    // If not in memory, try persistent storage (might be in different isolate)
    if (data == null) {
      try {
        developer.log('🔍 [FCM] Checking persistent storage...');
        print('🔍 [FCM] Checking persistent storage...');
        final storedDataJson = CacheHelper.getData(key: _pendingNotificationKey) as String?;
        if (storedDataJson != null && storedDataJson.isNotEmpty) {
          data = json.decode(storedDataJson) as Map<String, dynamic>;
          // Restore to in-memory
          pendingNotificationData = data;
          developer.log('✅ [FCM] Found data in persistent storage');
          print('✅ [FCM] Found data in persistent storage');
        } else {
          developer.log('❌ [FCM] No data in persistent storage');
          print('❌ [FCM] No data in persistent storage');
        }
      } catch (e) {
        developer.log('❌ [FCM] Error loading notification from storage: $e');
        print('❌ [FCM] Error loading notification from storage: $e');
      }
    }
    
    if (data == null) {
      developer.log('❌ [FCM] No notification data found, returning');
      print('❌ [FCM] No notification data found, returning');
      return;
    }
    
    // DON'T clear data yet - wait until navigation succeeds
    // This prevents data loss if multiple calls happen
    
    final ticketId = data['ticketId']?.toString();
    developer.log('🎫 [FCM] Extracted ticketId: $ticketId');
    print('🎫 [FCM] Extracted ticketId: $ticketId');
    
    if (ticketId == null || ticketId.isEmpty || ticketId == 'null') {
      developer.log('❌ [FCM] Invalid ticketId, clearing data');
      print('❌ [FCM] Invalid ticketId, clearing data');
      // Clear data if invalid
      _clearPendingNotificationData();
      return;
    }
    
    // Mark as navigating to prevent duplicates
    _isNavigating = true;
    developer.log('🚦 [FCM] Starting navigation for ticketId: $ticketId');
    print('🚦 [FCM] Starting navigation for ticketId: $ticketId');
    
    // Simple navigation with a small delay for stability
    Future.delayed(const Duration(milliseconds: 500), () {
      _navigate(ticketId);
    });
  }
  
  /// Navigate to ticket details or notifications screen
  static void _navigate(String? ticketId) {
    // Check if navigation already succeeded (prevent multiple navigations)
    if (!_isNavigating) {
      developer.log('✅ [FCM] Navigation already completed, skipping');
      print('✅ [FCM] Navigation already completed, skipping');
      return;
    }
    
    try {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        developer.log('⚠️ [FCM] Navigator is null, cannot navigate');
        print('⚠️ [FCM] Navigator is null, cannot navigate');
        _isNavigating = false;
        return;
      }

      final context = navigator.context;
      if (!context.mounted) {
        developer.log('⚠️ [FCM] Context not mounted, cannot navigate');
        print('⚠️ [FCM] Context not mounted, cannot navigate');
        _isNavigating = false;
        return;
      }
      
      developer.log('✅ [FCM] Navigator and context are ready, proceeding with navigation');
      print('✅ [FCM] Navigator and context are ready, proceeding with navigation');
      
      if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
        try {
          // Use loader screen to prevent crashes during cold start
          // TicketDetailsLoader will show loading indicator, then navigate to actual screen
          developer.log('📱 [FCM] Navigating to TicketDetailsLoader (ticketId: $ticketId)');
          print('📱 [FCM] Navigating to TicketDetailsLoader (ticketId: $ticketId)');
          final route = rightToLeft(TicketDetailsLoader(ticketId: ticketId));
          
          final result = navigator.push(route);
          
          // Clear flag and data only after successful navigation
          result.then((_) {
            _clearPendingNotificationData();
            _isNavigating = false;
          }).catchError((e, stackTrace) {
            _isNavigating = false;
          });
        } catch (e) {
          developer.log('❌ [FCM] Error navigating to ticket details: $e');
          print('❌ [FCM] Error navigating to ticket details: $e');
          _isNavigating = false;
        }
      } else {
        try {
          final route = downToTop(NotificationsScreen());
          final result = navigator.push(route);
          
          result.then((_) {
            _clearPendingNotificationData();
            _isNavigating = false;
          }).catchError((e) {
            _isNavigating = false;
          });
        } catch (e) {
          developer.log('❌ [FCM] Error navigating to notifications: $e');
          print('❌ [FCM] Error navigating to notifications: $e');
          _isNavigating = false;
        }
      }
    } catch (e) {
      developer.log('❌ [FCM] Error during navigation: $e');
      print('❌ [FCM] Error during navigation: $e');
      _isNavigating = false;
    }
  }
  
  // Helper function to navigate from notification
  static void _navigateFromNotification(BuildContext context, Map<String, dynamic> data) {
    try {
      final ticketId = data['ticketId']?.toString();
      
      // Use a small delay to ensure the app is ready and context is valid
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          // Get fresh context in case app was in background
          final currentContext = navigatorKey.currentState?.context;
          if (currentContext != null && currentContext.mounted) {
            if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
              Navigator.push(
                currentContext,
                rightToLeft(TicketDetailsLoader(ticketId: ticketId)),
              );
            } else {
              Navigator.push(currentContext, downToTop(NotificationsScreen()));
            }
          } else {
            // Retry after longer delay if context not ready
            Future.delayed(const Duration(milliseconds: 1000), () {
              try {
                final retryContext = navigatorKey.currentState?.context;
                if (retryContext != null && retryContext.mounted) {
                  if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
                    Navigator.push(
                      retryContext,
                      rightToLeft(TicketDetailsLoader(ticketId: ticketId)),
                    );
                  } else {
                    Navigator.push(retryContext, downToTop(NotificationsScreen()));
                  }
                }
              } catch (e) {
                // Error navigating on retry
              }
            });
          }
        } catch (e) {
          // Error navigating from notification
        }
      });
    } catch (e) {
      // Error in _navigateFromNotification
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
    // Initialize Flutter bindings for background isolate
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize SharedPreferences in background isolate
    try {
      await CacheHelper.init();
    } catch (e) {
      // Error initializing CacheHelper in background
    }
    
    // Get localized notification text
    final localizedTitle = _getLocalizedNotificationText(
      message.data,
      message.notification?.title ?? 'New Notification',
      'titleEn',
      'titleAr',
    );
    final localizedBody = _getLocalizedNotificationText(
      message.data,
      message.notification?.body ?? 'You have a new notification',
      'bodyEn',
      'bodyAr',
    );

    try {
      // Generate consistent notification ID based on ticketId and type to prevent duplicates
      // Using consistent ID ensures duplicates replace each other instead of creating new ones
      final ticketId = message.data['ticketId']?.toString();
      final notificationType = message.data['type']?.toString() ?? 'general';
      
      // Create consistent ID: combine ticketId (if exists) and type
      // This ensures the same notification (same ticketId + type) replaces the previous one instead of creating duplicates
      // Only use timestamp as fallback if no ticketId is available
      final notificationIdString = ticketId != null && ticketId.isNotEmpty
          ? '${ticketId}_${notificationType}'
          : '${notificationType}_${DateTime.now().millisecondsSinceEpoch}';
      final notificationId = notificationIdString.hashCode.abs() % 2147483647;
      
      // Check for duplicates before creating notification (by ID and content)
      final isDuplicate = await _isDuplicateNotification(notificationId, localizedTitle, localizedBody);
      if (isDuplicate) {
        return;
      }
      
      // Mark as created to prevent duplicates
      await _markNotificationCreated(notificationId, localizedTitle, localizedBody);
      
      // Cache the notification
      final cachedNotification = CachedNotification(
        id: notificationId.toString(),
        ticketId: ticketId,
        title: localizedTitle,
        titleAr: message.data['titleAr']?.toString(),
        description: localizedBody,
        descriptionAr: message.data['bodyAr']?.toString(),
        createdDate: DateTime.now(),
        data: message.data.cast(),
      );
      await NotificationCacheService.saveNotification(cachedNotification);
      
      await NotificationsController.createNewNotification(
          title: localizedTitle.isNotEmpty ? localizedTitle : 'New Notification',
          body: localizedBody.isNotEmpty ? localizedBody : 'You have a new notification',
          bigPicture: '',
          payload: message.data.cast(),
          notificationId: notificationId); // Consistent ID ensures duplicates replace each other
    } catch (e) {
      // Re-throw to ensure Firebase knows the handler completed
      rethrow;
    }
  }

}