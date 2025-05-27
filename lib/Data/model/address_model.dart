// To parse this JSON data, do
//
//     final addressModel = addressModelFromJson(jsonString);

import 'dart:convert';

AddressModel addressModelFromJson(String str) => AddressModel.fromJson(json.decode(str));

String addressModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
    List<CustomerAddress> customerAddress;

    AddressModel({
        required this.customerAddress,
    });

    factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        customerAddress: List<CustomerAddress>.from(json["customerAddress"].map((x) => CustomerAddress.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customerAddress": List<dynamic>.from(customerAddress.map((x) => x.toJson())),
    };
}

class CustomerAddress {
    int id;
    String? latitude;
    String? longitude;
    String? address;
    String? addressType;
    bool isDefault;
    DateTime createdDate;

    CustomerAddress({
        required this.id,
        required this.latitude,
        required this.longitude,
        required this.address,
        required this.addressType,
        required this.isDefault,
        required this.createdDate,
    });

    factory CustomerAddress.fromJson(Map<String, dynamic> json) => CustomerAddress(
        id: json["id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        address: json["address"],
        addressType: json["addressType"],
        isDefault: json["isDefault"],
        createdDate: DateTime.parse(json["createdDate"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "addressType": addressType,
        "isDefault": isDefault,
        "createdDate": createdDate.toIso8601String(),
    };
}
