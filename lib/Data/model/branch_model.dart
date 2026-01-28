// To parse this JSON data, do
//
//     final branchesModel = branchesModelFromJson(jsonString);

import 'dart:convert';

BranchesModel branchesModelFromJson(String str) =>
    BranchesModel.fromJson(json.decode(str));

String branchesModelToJson(BranchesModel data) => json.encode(data.toJson());

class BranchesModel {
  List<Branch> branches;

  BranchesModel({
    required this.branches,
  });

  factory BranchesModel.fromJson(Map<String, dynamic> json) => BranchesModel(
        branches:
            List<Branch>.from(json["branches"].map((x) => Branch.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "branches": List<dynamic>.from(branches.map((x) => x.toJson())),
      };
}

class Branch {
  int id;
  int customerId;
  String name;
  String nameAr;
  String phone;
  String city;
  String address;
  String latitude;
  String longitude;

  Branch({
    required this.id,
    required this.customerId,
    required this.name,
    required this.nameAr,
    required this.phone,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        customerId: json["customerId"],
        name: json["name"],
        nameAr: json["nameAr"],
        phone: json["phone"],
        city: json["city"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customerId": customerId,
        "name": name,
        "nameAr": nameAr,
        "phone": phone,
        "city": city,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
