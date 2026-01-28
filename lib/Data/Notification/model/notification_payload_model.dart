import 'dart:convert';

class NotificationPayloadModel {
  final String? channel;
  final String? topic;
  final Map<String, dynamic>? data;

  NotificationPayloadModel({
    required this.channel,
    required this.topic,
    required this.data,
  });

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadModel(
      channel: json['channel'],
      topic: json['topic'],
      data: json['data'] != null ? jsonDecode(json['data']) : null,
    );
  }

  @override
  String toString() {
    return '''
    channel :$channel,
    topic:$topic,
    data:$data,
    ''';
  }
}