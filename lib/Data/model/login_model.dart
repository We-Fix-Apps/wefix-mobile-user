// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool status;
  int? otp;
  String message;

  LoginModel({
    required this.status,
    required this.otp,
    required this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        otp: json["otp"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "otp": otp,
        "message": message,
      };
}
