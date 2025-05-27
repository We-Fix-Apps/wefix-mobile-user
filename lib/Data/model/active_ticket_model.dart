// To parse this JSON data, do
//
//     final activeTicketModel = activeTicketModelFromJson(jsonString);

import 'dart:convert';

ActiveTicketModel activeTicketModelFromJson(String str) =>
    ActiveTicketModel.fromJson(json.decode(str));

String activeTicketModelToJson(ActiveTicketModel data) =>
    json.encode(data.toJson());

class ActiveTicketModel {
  Tickets tickets;

  ActiveTicketModel({
    required this.tickets,
  });

  factory ActiveTicketModel.fromJson(Map<String, dynamic> json) =>
      ActiveTicketModel(
        tickets: Tickets.fromJson(json["tickets"]),
      );

  Map<String, dynamic> toJson() => {
        "tickets": tickets.toJson(),
      };
}

class Tickets {
  int id;
  int customerId;
  int ticketTypeId;
  String promoCode;
  DateTime requestedDate;
  DateTime selectedDate;
  String selectedDateTime;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic teamNo;
  String status;
  String location;
  String longitude;
  String latitude;
  String? gender; // ✅ Nullable
  bool isWithMaterial;
  dynamic priority;
  int createdBy;
  int? customerPackageId; // ✅ Nullable
  int totalPrice;
  dynamic serviceprovide;
  dynamic serviceprovideImage;
  String description;
  String descriptionAr;
  String qrCodePath;
  int rating;
  bool isRated;
  String qrCode;
  String statusAr;

  Tickets({
    required this.id,
    required this.customerId,
    required this.ticketTypeId,
    required this.promoCode,
    required this.requestedDate,
    required this.selectedDate,
    required this.selectedDateTime,
    required this.timeFrom,
    required this.timeTo,
    required this.teamNo,
    required this.status,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.gender,
    required this.isWithMaterial,
    required this.priority,
    required this.createdBy,
    required this.customerPackageId,
    required this.totalPrice,
    required this.serviceprovide,
    required this.serviceprovideImage,
    required this.description,
    required this.descriptionAr,
    required this.qrCodePath,
    required this.rating,
    required this.isRated,
    required this.qrCode,
    required this.statusAr,
  });

  factory Tickets.fromJson(Map<String, dynamic> json) => Tickets(
        id: json["id"],
        customerId: json["customerId"],
        ticketTypeId: json["ticketTypeId"],
        promoCode: json["promoCode"],
        requestedDate: DateTime.parse(json["requestedDate"]),
        selectedDate: DateTime.parse(json["selectedDate"]),
        selectedDateTime: json["selectedDateTime"],
        timeFrom: json["timeFrom"],
        timeTo: json["timeTo"],
        teamNo: json["teamNo"],
        status: json["status"],
        location: json["location"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        gender: json["gender"], // may be null
        isWithMaterial: json["isWithMaterial"],
        priority: json["priority"],
        createdBy: json["createdBy"],
        customerPackageId: json["customerPackageId"],
        totalPrice: json["totalPrice"],
        serviceprovide: json["serviceprovide"],
        serviceprovideImage: json["serviceprovideImage"],
        description: json["description"],
        descriptionAr: json["descriptionAr"],
        qrCodePath: json["qrCodePath"],
        rating: json["rating"],
        isRated: json["isRated"],
        qrCode: json["qrCode"],
        statusAr: json["statusAr"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customerId": customerId,
        "ticketTypeId": ticketTypeId,
        "promoCode": promoCode,
        "requestedDate": requestedDate.toIso8601String(),
        "selectedDate": selectedDate.toIso8601String(),
        "selectedDateTime": selectedDateTime,
        "timeFrom": timeFrom,
        "timeTo": timeTo,
        "teamNo": teamNo,
        "status": status,
        "location": location,
        "longitude": longitude,
        "latitude": latitude,
        "gender": gender,
        "isWithMaterial": isWithMaterial,
        "priority": priority,
        "createdBy": createdBy,
        "customerPackageId": customerPackageId,
        "totalPrice": totalPrice,
        "serviceprovide": serviceprovide,
        "serviceprovideImage": serviceprovideImage,
        "description": description,
        "descriptionAr": descriptionAr,
        "qrCodePath": qrCodePath,
        "rating": rating,
        "isRated": isRated,
        "qrCode": qrCode,
        "statusAr": statusAr,
      };
}
