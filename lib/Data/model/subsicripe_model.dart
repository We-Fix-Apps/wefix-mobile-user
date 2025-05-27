// To parse this JSON data, do
//
//     final subsicripeModel = subsicripeModelFromJson(jsonString);

import 'dart:convert';

SubsicripeModel subsicripeModelFromJson(String str) =>
    SubsicripeModel.fromJson(json.decode(str));

String subsicripeModelToJson(SubsicripeModel data) =>
    json.encode(data.toJson());

class SubsicripeModel {
  bool status;
  ObjSubscribe? objSubscribe;

  SubsicripeModel({
    required this.status,
    required this.objSubscribe,
  });

  factory SubsicripeModel.fromJson(Map<String, dynamic> json) =>
      SubsicripeModel(
        status: json["status"],
        objSubscribe: json["objSubscribe"] != null
            ? ObjSubscribe.fromJson(json["objSubscribe"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "objSubscribe": objSubscribe?.toJson(),
      };
}

class ObjSubscribe {
  int id;
  int customerId;
  int packageId;
  DateTime createdDate;
  DateTime startDate;
  DateTime endDate;
  String status;
  int recurringVist;
  int onDemandVisit;
  int emeregencyVisit;
  int price;
  dynamic package;
  List<dynamic> payments;

  ObjSubscribe({
    required this.id,
    required this.customerId,
    required this.packageId,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.recurringVist,
    required this.onDemandVisit,
    required this.emeregencyVisit,
    required this.price,
    required this.package,
    required this.payments,
  });

  factory ObjSubscribe.fromJson(Map<String, dynamic> json) => ObjSubscribe(
        id: json["id"],
        customerId: json["customerId"],
        packageId: json["packageId"],
        createdDate: DateTime.parse(json["createdDate"]),
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        status: json["status"],
        recurringVist: json["recurringVist"],
        onDemandVisit: json["onDemandVisit"],
        emeregencyVisit: json["emeregencyVisit"],
        price: json["price"],
        package: json["package"],
        payments: List<dynamic>.from(json["payments"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customerId": customerId,
        "packageId": packageId,
        "createdDate": createdDate.toIso8601String(),
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "status": status,
        "recurringVist": recurringVist,
        "onDemandVisit": onDemandVisit,
        "emeregencyVisit": emeregencyVisit,
        "price": price,
        "package": package,
        "payments": List<dynamic>.from(payments.map((x) => x)),
      };
}
