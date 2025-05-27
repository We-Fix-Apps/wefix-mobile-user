// To parse this JSON data, do
//
//     final notoModel = notoModelFromJson(jsonString);

import 'dart:convert';

NotoModel notoModelFromJson(String str) => NotoModel.fromJson(json.decode(str));

String notoModelToJson(NotoModel data) => json.encode(data.toJson());

class NotoModel {
  List<Notification> notifications;

  NotoModel({
    required this.notifications,
  });

  factory NotoModel.fromJson(Map<String, dynamic> json) => NotoModel(
        notifications: List<Notification>.from(
            json["notifications"].map((x) => Notification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
      };
}

class Notification {
  int id;
  int userId;

  int? ticketId;
  String title;
  String? titleAr;
  String? description;
  String? descriptionAr;
  bool isRead;
  DateTime createdDate;
  dynamic? user;

  Notification({
    required this.id,
    required this.userId,
    this.ticketId,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.isRead,
    required this.createdDate,
    required this.user,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        userId: json["userId"],
        ticketId: json["ticketId"],
        title: json["title"],
        titleAr: json["titleAr"],
        description: json["description"],
        descriptionAr: json["descriptionAr"],
        isRead: json["isRead"],
        createdDate: DateTime.parse(json["createdDate"]),
        user: json["user"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "ticketId": ticketId,
        "title": title,
        "titleAr": titleAr,
        "description": description,
        "descriptionAr": descriptionAr,
        "isRead": isRead,
        "createdDate": createdDate.toIso8601String(),
        "user": user,
      };
}
