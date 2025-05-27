// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool status;
  String token;
  String message;
  String? qrCodePath;

  int wallet;

  Customer customer;

  UserModel({
    required this.status,
    required this.token,
    required this.wallet,
    required this.qrCodePath,
    required this.message,
    required this.customer,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        status: json["status"],
        wallet: json["wallet"],
        qrCodePath: json["qrCodePath"],
        token: json["token"],
        message: json["message"],
        customer: Customer.fromJson(json["customer"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "token": token,
        "qrCodePath": qrCodePath,
        "wallet": wallet,
        "message": message,
        "customer": customer.toJson(),
      };
}

class Customer {
  int id;
  dynamic roleId;
  String name;
  String mobile;
  String email;
  DateTime createdDate;
  String password;
  dynamic oldPassword;
  int otp;
  String address;
  int providerId;

  Customer({
    required this.id,
    required this.roleId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.createdDate,
    required this.password,
    required this.oldPassword,
    required this.otp,
    required this.address,
    required this.providerId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        roleId: json["roleId"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
        createdDate: DateTime.parse(json["createdDate"]),
        password: json["password"],
        oldPassword: json["oldPassword"],
        otp: json["otp"],
        address: json["address"],
        providerId: json["providerId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "roleId": roleId,
        "name": name,
        "mobile": mobile,
        "email": email,
        "createdDate": createdDate.toIso8601String(),
        "password": password,
        "oldPassword": oldPassword,
        "otp": otp,
        "address": address,
        "providerId": providerId,
      };
}
