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
  int? numberOnFemalUse;
  int? onDemandVisit;
  int? emergancyVisit;
  int? recurringVistUse;

  SubsicripeModel({
    required this.status,
    this.objSubscribe,
    this.numberOnFemalUse,
    this.emergancyVisit,
    this.onDemandVisit,
    this.recurringVistUse,
  });

  factory SubsicripeModel.fromJson(Map<String, dynamic> json) =>
      SubsicripeModel(
        status: json["status"] ?? false,
        emergancyVisit: json["emergancyVisit"],
        onDemandVisit: json["onDemandVisit"],
        recurringVistUse: json["recurringVistUse"],
        numberOnFemalUse: json["numberOnFemalUse"],
        objSubscribe: json["objSubscribe"] == null
            ? null
            : ObjSubscribe.fromJson(json["objSubscribe"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "objSubscribe": objSubscribe?.toJson(),
        "numberOnFemalUse": numberOnFemalUse,
        "onDemandVisit": onDemandVisit,
        "recurringVistUse": recurringVistUse,
        "emergancyVisit": emergancyVisit,
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
  int numberOnFemalUse;
  dynamic price;
  dynamic age;
  dynamic area;
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
    required this.numberOnFemalUse,
    required this.price,
    required this.age,
    required this.area,
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
        numberOnFemalUse: json["numberOnFemalUse"],
        price: json["price"],
        age: json["age"],
        area: json["area"],
        package: json["package"],
        payments: json["payments"] == null
            ? []
            : List<dynamic>.from(json["payments"].map((x) => x)),
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
        "numberOnFemalUse": numberOnFemalUse,
        "price": price,
        "age": age,
        "area": area,
        "package": package,
        "payments": payments,
      };
}
