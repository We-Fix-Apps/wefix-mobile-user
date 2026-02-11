import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Data/Helper/cache_helper.dart';

class CachedNotification {
  final String id; // Unique ID for the notification
  final String? ticketId;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final DateTime createdDate;
  final Map<String, dynamic>? data; // Original FCM data

  CachedNotification({
    required this.id,
    this.ticketId,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.createdDate,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketId': ticketId,
        'title': title,
        'titleAr': titleAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'createdDate': createdDate.toIso8601String(),
        'data': data,
      };

  factory CachedNotification.fromJson(Map<String, dynamic> json) => CachedNotification(
        id: json['id'] as String,
        ticketId: json['ticketId'] as String?,
        title: json['title'] as String,
        titleAr: json['titleAr'] as String?,
        description: json['description'] as String,
        descriptionAr: json['descriptionAr'] as String?,
        createdDate: DateTime.parse(json['createdDate'] as String),
        data: json['data'] as Map<String, dynamic>?,
      );
}

class NotificationCacheService {
  static const String _cacheKey = 'cached_notifications';
  static const int _maxNotifications = 100; // Limit to prevent excessive storage

  /// Save a notification to cache
  static Future<void> saveNotification(CachedNotification notification) async {
    try {
      // Ensure CacheHelper is initialized
      await CacheHelper.init();
      
      final notifications = getCachedNotifications();
      log('📦 Current cached notifications count: ${notifications.length}');
      
      // Remove duplicate if exists (same ID)
      notifications.removeWhere((n) => n.id == notification.id);
      
      // Add new notification at the beginning (most recent first)
      notifications.insert(0, notification);
      
      // Limit the number of cached notifications
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }
      
      // Save to cache
      final jsonList = notifications.map((n) => n.toJson()).toList();
      final jsonString = json.encode(jsonList);
      log('💾 Saving ${notifications.length} notifications to cache (JSON length: ${jsonString.length})');
      
      final saved = await CacheHelper.saveData(key: _cacheKey, value: jsonString);
      if (saved) {
        log('✅ Saved notification to cache: ${notification.id} (Total: ${notifications.length})');
        
        // Verify it was saved correctly
        final verifyCount = getCachedNotifications().length;
        log('✅ Verified cache: ${verifyCount} notifications found after save');
      } else {
        log('❌ Failed to save notification to cache - saveData returned false');
      }
    } catch (e, stackTrace) {
      log('❌ Error saving notification to cache: $e');
      log('❌ Stack trace: $stackTrace');
    }
  }

  /// Get all cached notifications (sorted by date, most recent first)
  static List<CachedNotification> getCachedNotifications() {
    try {
      final cachedData = CacheHelper.getData(key: _cacheKey);
      log('📥 Getting cached notifications - cachedData type: ${cachedData.runtimeType}, isNull: ${cachedData == null}');
      
      if (cachedData == null || cachedData.toString().isEmpty) {
        log('📭 No cached notifications found (cachedData is null or empty)');
        return [];
      }
      
      log('📥 Cached data length: ${cachedData.toString().length} characters');
      
      final jsonList = json.decode(cachedData.toString()) as List<dynamic>;
      log('📥 Parsed ${jsonList.length} notifications from cache');
      
      final notifications = jsonList
          .map((json) => CachedNotification.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by date (most recent first)
      notifications.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      log('✅ Retrieved ${notifications.length} cached notifications');
      return notifications;
    } catch (e, stackTrace) {
      log('❌ Error getting cached notifications: $e');
      log('❌ Stack trace: $stackTrace');
      return [];
    }
  }

  /// Check if a notification is B2B (delegated ticket)
  static bool isB2BNotification(CachedNotification notification) {
    final type = notification.data?['type']?.toString() ?? '';
    // B2B notifications are those related to delegated tickets
    return type.contains('delegated') || 
           type == 'delegated_ticket_created' || 
           type == 'delegated_ticket_status_changed';
  }

  /// Get B2B notifications only
  static List<CachedNotification> getB2BNotifications() {
    return getCachedNotifications().where((n) => isB2BNotification(n)).toList();
  }

  /// Get B2C notifications only
  static List<CachedNotification> getB2CNotifications() {
    return getCachedNotifications().where((n) => !isB2BNotification(n)).toList();
  }

  /// Clear all cached notifications
  static Future<void> clearAllNotifications() async {
    try {
      await CacheHelper.removeData(key: _cacheKey);
      log('✅ Cleared all cached notifications');
    } catch (e) {
      log('❌ Error clearing cached notifications: $e');
    }
  }

  /// Remove a specific notification by ID
  static Future<void> removeNotification(String id) async {
    try {
      final notifications = getCachedNotifications();
      notifications.removeWhere((n) => n.id == id);
      
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await CacheHelper.saveData(key: _cacheKey, value: json.encode(jsonList));
      
      log('✅ Removed notification from cache: $id');
    } catch (e) {
      log('❌ Error removing notification from cache: $e');
    }
  }

  /// Get count of cached notifications
  static int getNotificationCount() {
    return getCachedNotifications().length;
  }
}
