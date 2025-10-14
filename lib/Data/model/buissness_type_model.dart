// To parse this JSON data, do
//
//     final businessTypesModel = businessTypesModelFromJson(jsonString);

import 'dart:convert';

BusinessTypesModel businessTypesModelFromJson(String str) =>
    BusinessTypesModel.fromJson(json.decode(str));

String businessTypesModelToJson(BusinessTypesModel data) =>
    json.encode(data.toJson());

class BusinessTypesModel {
  List<BusinessType> businessTypes;

  BusinessTypesModel({
    required this.businessTypes,
  });

  factory BusinessTypesModel.fromJson(Map<String, dynamic> json) =>
      BusinessTypesModel(
        businessTypes: List<BusinessType>.from(
            json["businessTypes"].map((x) => BusinessType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "businessTypes":
            List<dynamic>.from(businessTypes.map((x) => x.toJson())),
      };
}

class BusinessType {
  int id;
  String titleEn;
  String titleAr;
  int sortOrder;

  BusinessType({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.sortOrder,
  });

  factory BusinessType.fromJson(Map<String, dynamic> json) => BusinessType(
        id: json["id"],
        titleEn: json["titleEn"],
        titleAr: json["titleAr"],
        sortOrder: json["sortOrder"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titleEn": titleEn,
        "titleAr": titleAr,
        "sortOrder": sortOrder,
      };
}
