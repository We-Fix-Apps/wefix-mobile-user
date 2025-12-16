// To parse this JSON data, do
//
//     final mmsUserModel = mmsUserModelFromJson(jsonString);

import 'dart:convert';

MmsUserModel mmsUserModelFromJson(String str) =>
    MmsUserModel.fromJson(json.decode(str));

String mmsUserModelToJson(MmsUserModel data) =>
    json.encode(data.toJson());

class MmsUserModel {
  bool success;
  String message;
  MmsUser? user;
  MmsAuthToken? token;

  MmsUserModel({
    required this.success,
    required this.message,
    this.user,
    this.token,
  });

  factory MmsUserModel.fromJson(Map<String, dynamic> json) =>
      MmsUserModel(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        user: json["user"] != null ? MmsUser.fromJson(json["user"]) : null,
        token: json["token"] != null
            ? MmsAuthToken.fromJson(json["token"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "user": user?.toJson(),
        "token": token?.toJson(),
      };
}

class MmsUser {
  int id;
  String userNumber;
  String fullName;
  String fullNameEnglish;
  String? email;
  String deviceId;
  String fcmToken;
  String? mobileNumber;
  String? countryCode;
  String? username;
  int userRoleId;
  int? companyId;
  DateTime createdAt;
  DateTime updatedAt;
  int? createdBy;
  int? updatedBy;
  DateTime? deletedAt;
  int? deletedBy;
  bool isActive;
  bool isDeleted;
  String? token;
  DateTime? tokenExpiresAt;
  int failedLoginAttempts;
  DateTime? accountLockedUntil;
  String? passwordResetToken;
  DateTime? passwordResetTokenExpiresAt;
  String? gender;

  MmsUser({
    required this.id,
    required this.userNumber,
    required this.fullName,
    required this.fullNameEnglish,
    this.email,
    required this.deviceId,
    required this.fcmToken,
    this.mobileNumber,
    this.countryCode,
    this.username,
    required this.userRoleId,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
    required this.isActive,
    required this.isDeleted,
    this.token,
    this.tokenExpiresAt,
    required this.failedLoginAttempts,
    this.accountLockedUntil,
    this.passwordResetToken,
    this.passwordResetTokenExpiresAt,
    this.gender,
  });

  factory MmsUser.fromJson(Map<String, dynamic> json) => MmsUser(
        id: json["id"] ?? 0,
        userNumber: json["userNumber"] ?? "",
        fullName: json["fullName"] ?? "",
        fullNameEnglish: json["fullNameEnglish"] ?? "",
        email: json["email"],
        deviceId: json["deviceId"] ?? "",
        fcmToken: json["fcmToken"] ?? "",
        mobileNumber: json["mobileNumber"],
        countryCode: json["countryCode"],
        username: json["username"],
        userRoleId: json["userRoleId"] ?? 0,
        companyId: json["companyId"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : DateTime.now(),
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        deletedAt: json["deletedAt"] != null
            ? DateTime.parse(json["deletedAt"])
            : null,
        deletedBy: json["deletedBy"],
        isActive: json["isActive"] ?? true,
        isDeleted: json["isDeleted"] ?? false,
        token: json["token"],
        tokenExpiresAt: json["tokenExpiresAt"] != null
            ? DateTime.parse(json["tokenExpiresAt"])
            : null,
        failedLoginAttempts: json["failedLoginAttempts"] ?? 0,
        accountLockedUntil: json["accountLockedUntil"] != null
            ? DateTime.parse(json["accountLockedUntil"])
            : null,
        passwordResetToken: json["passwordResetToken"],
        passwordResetTokenExpiresAt:
            json["passwordResetTokenExpiresAt"] != null
                ? DateTime.parse(json["passwordResetTokenExpiresAt"])
                : null,
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userNumber": userNumber,
        "fullName": fullName,
        "fullNameEnglish": fullNameEnglish,
        "email": email,
        "deviceId": deviceId,
        "fcmToken": fcmToken,
        "mobileNumber": mobileNumber,
        "countryCode": countryCode,
        "username": username,
        "userRoleId": userRoleId,
        "companyId": companyId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "deletedAt": deletedAt?.toIso8601String(),
        "deletedBy": deletedBy,
        "isActive": isActive,
        "isDeleted": isDeleted,
        "token": token,
        "tokenExpiresAt": tokenExpiresAt?.toIso8601String(),
        "failedLoginAttempts": failedLoginAttempts,
        "accountLockedUntil": accountLockedUntil?.toIso8601String(),
        "passwordResetToken": passwordResetToken,
        "passwordResetTokenExpiresAt":
            passwordResetTokenExpiresAt?.toIso8601String(),
        "gender": gender,
      };
}

class MmsAuthToken {
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;

  MmsAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory MmsAuthToken.fromJson(Map<String, dynamic> json) =>
      MmsAuthToken(
        accessToken: json["accessToken"] ?? "",
        refreshToken: json["refreshToken"] ?? "",
        tokenType: json["tokenType"] ?? "Bearer",
        expiresIn: json["expiresIn"] ?? 3600,
      );

  Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "tokenType": tokenType,
        "expiresIn": expiresIn,
      };
}

