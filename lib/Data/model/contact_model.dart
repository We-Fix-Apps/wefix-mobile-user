// To parse this JSON data, do
//
//     final contactModel = contactModelFromJson(jsonString);

import 'dart:convert';

ContactModel contactModelFromJson(String str) =>
    ContactModel.fromJson(json.decode(str));

String contactModelToJson(ContactModel data) => json.encode(data.toJson());

class ContactModel {
  Languages languages;

  ContactModel({
    required this.languages,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        languages: Languages.fromJson(json["languages"]),
      );

  Map<String, dynamic> toJson() => {
        "languages": languages.toJson(),
      };
}

class Languages {
  int id;
  String phone;
  String emegancyPhone;
  String email;
  String longitude;
  String latitude;
  String facebook;
  String twitter;
  String instagram;
  String youtube;

  Languages({
    required this.id,
    required this.phone,
    required this.emegancyPhone,
    required this.email,
    required this.longitude,
    required this.latitude,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.youtube,
  });

  factory Languages.fromJson(Map<String, dynamic> json) => Languages(
        id: json["id"],
        phone: json["phone"],
        emegancyPhone: json["emegancyPhone"],
        email: json["email"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        facebook: json["facebook"],
        twitter: json["twitter"],
        instagram: json["instagram"],
        youtube: json["youtube"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "emegancyPhone": emegancyPhone,
        "email": email,
        "longitude": longitude,
        "latitude": latitude,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
        "youtube": youtube,
      };
}
