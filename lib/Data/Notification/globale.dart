import 'package:wefix/Data/Notification/model/notification_channel_model.dart';

class NotificationChannelKey {
  NotificationChannelKey._();

  static const String alarmChannel = "alarm_channel";
  static NotificationChannelModel basicChannel = NotificationChannelModel(groupKey: 'basic', key: 'basic_channel', name: 'Basic notifications', description: 'Notification channel for basic');
  static NotificationChannelModel categoryChannel = NotificationChannelModel(groupKey: 'category', key: 'call_channel', name: 'Calls Channel', description: 'Channel with call ringtone');
  static NotificationChannelModel scheduleChannel =
      NotificationChannelModel(groupKey: 'schedule', key: 'scheduled', name: 'Scheduled notifications', description: 'Notifications with schedule functionality');
}
