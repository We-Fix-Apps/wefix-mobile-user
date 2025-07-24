// To parse this JSON data, do
//
//     final advantagesModel = advantagesModelFromJson(jsonString);

import 'dart:convert';

AdvantagesModel advantagesModelFromJson(String str) =>
    AdvantagesModel.fromJson(json.decode(str));

String advantagesModelToJson(AdvantagesModel data) =>
    json.encode(data.toJson());

class AdvantagesModel {
  List<Advantage> advantages;

  AdvantagesModel({
    required this.advantages,
  });

  factory AdvantagesModel.fromJson(Map<String, dynamic> json) =>
      AdvantagesModel(
        advantages: List<Advantage>.from(
            json["advantages"].map((x) => Advantage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "advantages": List<dynamic>.from(advantages.map((x) => x.toJson())),
      };
}

class Advantage {
  int id;
  String titleEn;
  String titleAr;
  String subTitleEn;
  String subTitleAr;

  String icon;
  int sortOrder;
  int price;
  bool? status;

  Advantage({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.subTitleEn,
    required this.subTitleAr,
    this.status,
    required this.icon,
    required this.sortOrder,
    required this.price,
  });

  factory Advantage.fromJson(Map<String, dynamic> json) => Advantage(
        id: json["id"],
        titleEn: json["titleEn"],
        titleAr: json["titleAr"],
        subTitleEn: json["subTitleEn"],
        subTitleAr: json["subTitleAr"],
        icon: json["icon"],
        sortOrder: json["sortOrder"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titleEn": titleEn,
        "titleAr": titleAr,
        "icon": icon,
        "sortOrder": sortOrder,
        "price": price,
      };
}
