// To parse this JSON data, do
//
//     final subServiceModel = subServiceModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

SubServiceModel subServiceModelFromJson(String str) =>
    SubServiceModel.fromJson(json.decode(str));

String subServiceModelToJson(SubServiceModel data) =>
    json.encode(data.toJson());

class SubServiceModel {
  List<Service> service;

  SubServiceModel({
    required this.service,
  });

  factory SubServiceModel.fromJson(Map<String, dynamic> json) =>
      SubServiceModel(
        service:
            List<Service>.from(json["service"].map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "service": List<dynamic>.from(service.map((x) => x.toJson())),
      };
}

class Service {
  int id;
  int categoryId;
  String? name;
  String? nameAr;
  String? icon;
  String? image;
  dynamic price;
  dynamic discountPrice;
  dynamic subscriptionPrice;
  bool isOffer;
  bool isPopular;
  bool haveQuantity;
  String? description;
  String? descriptionAr;
  GlobalKey serviceKey = GlobalKey();

  bool isSelected = false;
  int quantity = 0;
  int? numOfTicket;

  Service({
    required this.id,
    this.isSelected = false,
    required this.categoryId,
    required this.name,
    required this.subscriptionPrice,
    required this.quantity,
    required this.nameAr,
    required this.descriptionAr,
    required this.description,
    required this.numOfTicket,
    required this.icon,
    required this.image,
    required this.price,
    required this.discountPrice,
    required this.isOffer,
    required this.isPopular,
    required this.haveQuantity,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        descriptionAr: json["descriptionAr"],
        categoryId: json["categoryId"],
        subscriptionPrice: json["subscriptionPrice"],
        name: json["name"],
        numOfTicket: json["numOfTicket"],
        nameAr: json["nameAr"],
        description: json["description"],
        icon: json["icon"],
        quantity: 0,
        image: json["image"],
        price: json["price"],
        discountPrice: json["discountPrice"],
        isOffer: json["isOffer"],
        isPopular: json["isPopular"],
        haveQuantity: json["haveQuantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "descriptionAr": descriptionAr,
        "categoryId": categoryId,
        "name": name,
        "nameAr": nameAr,
        "subscriptionPrice": subscriptionPrice,
        "description": description,
        "icon": icon,
        "numOfTicket": numOfTicket,
        "image": image,
        "price": price,
        "discountPrice": discountPrice,
        "isOffer": isOffer,
        "isPopular": isPopular,
        "haveQuantity": haveQuantity,
      };
}
