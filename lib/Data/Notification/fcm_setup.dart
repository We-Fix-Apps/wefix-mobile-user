import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/Functions/cash_strings.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
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
          log('Error parsing stored notification IDs: $e');
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
          log('Error parsing stored notification content: $e');
        }
      }
    } catch (e) {
      log('Error cleaning up old notification IDs: $e');
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
      log('⚠️ DUPLICATE DETECTED (in-memory) - ID: $notificationId');
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
              log('⚠️ DUPLICATE DETECTED (persistent storage) - ID: $notificationId');
              return true;
            }
          }
        }
      }
    } catch (e) {
      log('Error checking persistent storage for duplicate ID: $e');
    }
    
    // Also check by content (title + body) to catch duplicates even if IDs somehow differ
    final contentKey = '${title}_$body';
    
    // Check in-memory
    if (_recentNotificationContent.containsKey(contentKey)) {
      final lastSeen = _recentNotificationContent[contentKey]!;
      if (now.difference(lastSeen).inSeconds < 30) {
        log('⚠️ DUPLICATE DETECTED (in-memory content) - Content: $contentKey');
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
              log('⚠️ DUPLICATE DETECTED (persistent storage content) - Content: $contentKey');
              return true;
            }
          }
        }
      }
    } catch (e) {
      log('Error checking persistent storage for duplicate content: $e');
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
      log('Error saving notification to persistent storage: $e');
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
      log("FCM Error : ${error.toString()}");
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
      log('[mobile-user] Language code from cache: $langCode');
      
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
        log('[mobile-user] Language not set, defaulting to English');
      }
      
      final isArabic = langString.toLowerCase().trim() == 'ar';
      log('[mobile-user] Is Arabic: $isArabic (langString: $langString)');

      // Check if localized data exists in message.data
      log('Checking for keys: $enKey, $arKey in data: ${data.keys.toList()}');
      if (data.containsKey(enKey) || data.containsKey(arKey)) {
        final enValue = data[enKey]?.toString().trim() ?? '';
        final arValue = data[arKey]?.toString().trim() ?? '';
        
        log('English value: $enValue, Arabic value: $arValue');
        
        if (isArabic) {
          // Prefer Arabic, fallback to English, then default
          final result = arValue.isNotEmpty 
              ? arValue 
              : (enValue.isNotEmpty ? enValue : defaultText);
          log('Selected Arabic text: $result');
          return result;
        } else {
          // Prefer English, fallback to Arabic, then default
          final result = enValue.isNotEmpty 
              ? enValue 
              : (arValue.isNotEmpty ? arValue : defaultText);
          log('Selected English text: $result');
          return result;
        }
      }

      // Fallback to default notification text
      log('No localized keys found, using default: $defaultText');
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    } catch (e) {
      log('Error getting localized notification text: $e');
      return defaultText.isNotEmpty ? defaultText : 'New Notification';
    }
  }

  //handle fcm notification when app is open (foreground)
  @pragma('vm:entry-point')
  static Future<void> _fcmForegroundHandler(RemoteMessage message) async {
    log('FCM Foreground message received: ${message.data}');
    
    // Skip if we don't have notification data to avoid showing empty notifications
    if (!message.data.containsKey('titleEn') && 
        !message.data.containsKey('titleAr') && 
        message.notification == null) {
      log('Skipping notification - no title data available');
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

    log('Foreground notification - showing BotToast and creating system notification for notification tray');
    log('Notification payload: ${message.data}');
    
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
      
      log('Foreground notification - ID: $uniqueNotificationId, ticketId: $ticketId, type: $notificationType, title: $localizedTitle');
      
      // Check for duplicates before creating notification (by ID and content)
      final isDuplicate = await _isDuplicateNotification(uniqueNotificationId, localizedTitle, localizedBody);
      if (isDuplicate) {
        log('⚠️ DUPLICATE DETECTED - Skipping duplicate notification with ID: $uniqueNotificationId (ticketId: $ticketId, type: $notificationType)');
        return;
      }
      
      // Mark as created to prevent duplicates
      await _markNotificationCreated(uniqueNotificationId, localizedTitle, localizedBody);
      log('✅ Marked notification as created - ID: $uniqueNotificationId');
      
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
      log('✅ Created localized system notification for notification tray with ID: $uniqueNotificationId (ticketId: $ticketId, type: $notificationType)');
    } catch (e) {
      log('Error creating system notification: $e');
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
        log('✅ BotToast notification shown with ID: $botToastNotificationId');
      } else {
        log('⚠️ DUPLICATE BotToast DETECTED - Skipping BotToast notification with ID: $botToastNotificationId');
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
      log('Error showing in-app notification: $e');
    }
  }
  
  /// Public method to navigate from Firebase Messaging notification tap
  /// Called when app is opened from background/terminated state via notification
  static void navigateFromFirebaseMessage(Map<String, dynamic> data) {
    log('navigateFromFirebaseMessage called with data: $data');
    final ticketId = data['ticketId']?.toString();
    
    // Try navigation with multiple retries and increasing delays
    _navigateWithRetry(ticketId, 0);
  }
  
  /// Navigate with retry logic
  static void _navigateWithRetry(String? ticketId, int attempt) {
    if (attempt >= 5) {
      log('Failed to navigate after 5 attempts');
      return;
    }
    
    Future.delayed(Duration(milliseconds: 500 * (attempt + 1)), () {
      try {
        final context = navigatorKey.currentState?.context;
        if (context != null && context.mounted) {
          if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
            log('Navigating to ticket details: $ticketId (attempt ${attempt + 1})');
            Navigator.push(
              context,
              rightToLeft(TicketDetailsScreen(id: ticketId)),
            );
            log('Successfully navigated to ticket details: $ticketId');
          } else {
            log('Navigating to notifications screen (attempt ${attempt + 1})');
            Navigator.push(context, downToTop(NotificationsScreen()));
            log('Successfully navigated to notifications screen');
          }
        } else {
          log('Context not ready yet (attempt ${attempt + 1}/5), retrying...');
          _navigateWithRetry(ticketId, attempt + 1);
        }
      } catch (e) {
        log('Error navigating on attempt ${attempt + 1}: $e');
        _navigateWithRetry(ticketId, attempt + 1);
      }
    });
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
              log('Navigating to ticket details: $ticketId');
              Navigator.push(
                currentContext,
                rightToLeft(TicketDetailsScreen(id: ticketId)),
              );
            } else {
              log('No ticketId found, navigating to notifications screen');
              Navigator.push(currentContext, downToTop(NotificationsScreen()));
            }
          } else {
            log('Context not available, retrying navigation...');
            // Retry after longer delay if context not ready
            Future.delayed(const Duration(milliseconds: 1000), () {
              try {
                final retryContext = navigatorKey.currentState?.context;
                if (retryContext != null && retryContext.mounted) {
                  if (ticketId != null && ticketId.isNotEmpty && ticketId != 'null') {
                    Navigator.push(
                      retryContext,
                      rightToLeft(TicketDetailsScreen(id: ticketId)),
                    );
                  } else {
                    Navigator.push(retryContext, downToTop(NotificationsScreen()));
                  }
                }
              } catch (e) {
                log('Error navigating on retry: $e');
              }
            });
          }
        } catch (e) {
          log('Error navigating from notification: $e');
        }
      });
    } catch (e) {
      log('Error in _navigateFromNotification: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
    // Initialize Flutter bindings for background isolate
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize SharedPreferences in background isolate
    try {
      await CacheHelper.init();
      log('CacheHelper initialized in background isolate');
    } catch (e) {
      log('Error initializing CacheHelper in background: $e');
    }
    
    log('FCM Background message received: ${message.data}');
    log('Message notification: ${message.notification?.title} - ${message.notification?.body}');
    
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

    log('Creating notification with localized title: $localizedTitle, body: $localizedBody');
    log('Notification payload: ${message.data}');
    
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
      
      log('Background notification - ID: $notificationId, ticketId: $ticketId, type: $notificationType, title: $localizedTitle');
      
      // Check for duplicates before creating notification (by ID and content)
      final isDuplicate = await _isDuplicateNotification(notificationId, localizedTitle, localizedBody);
      if (isDuplicate) {
        log('⚠️ DUPLICATE DETECTED - Skipping duplicate notification with ID: $notificationId (ticketId: $ticketId, type: $notificationType)');
        return;
      }
      
      // Mark as created to prevent duplicates
      await _markNotificationCreated(notificationId, localizedTitle, localizedBody);
      log('✅ Marked notification as created - ID: $notificationId');
      
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
      log('✅ Notification created successfully with ID: $notificationId (ticketId: $ticketId, type: $notificationType)');
    } catch (e) {
      log('Error creating notification: $e');
      // Re-throw to ensure Firebase knows the handler completed
      rethrow;
    }
  }

}