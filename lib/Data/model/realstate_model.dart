// To parse this JSON data, do
//
//     final realEstatesModel = realEstatesModelFromJson(jsonString);

import 'dart:convert';

RealEstatesModel realEstatesModelFromJson(String str) => RealEstatesModel.fromJson(json.decode(str));

String realEstatesModelToJson(RealEstatesModel data) => json.encode(data.toJson());

class RealEstatesModel {
    List<RealEstate> realEstates;

    RealEstatesModel({
        required this.realEstates,
    });

    factory RealEstatesModel.fromJson(Map<String, dynamic> json) => RealEstatesModel(
        realEstates: List<RealEstate>.from(json["realEstates"].map((x) => RealEstate.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "realEstates": List<dynamic>.from(realEstates.map((x) => x.toJson())),
    };
}

class RealEstate {
    int id;
    String title;
    String area;
    String apartmentNo;
    String address;
    String latitude;
    String longitude;
    int customerId;
    dynamic customer;

    RealEstate({
        required this.id,
        required this.title,
        required this.area,
        required this.apartmentNo,
        required this.address,
        required this.latitude,
        required this.longitude,
        required this.customerId,
        required this.customer,
    });

    factory RealEstate.fromJson(Map<String, dynamic> json) => RealEstate(
        id: json["id"],
        title: json["title"],
        area: json["area"],
        apartmentNo: json["apartmentNo"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        customerId: json["customerId"],
        customer: json["customer"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "area": area,
        "apartmentNo": apartmentNo,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "customerId": customerId,
        "customer": customer,
    };
}
