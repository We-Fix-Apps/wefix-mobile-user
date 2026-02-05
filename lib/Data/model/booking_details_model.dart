// To parse this JSON data, do
//
//     final bookingDetailsModel = bookingDetailsModelFromJson(jsonString);

import 'dart:convert';

BookingDetailsModel bookingDetailsModelFromJson(String str) =>
    BookingDetailsModel.fromJson(json.decode(str));

String bookingDetailsModelToJson(BookingDetailsModel data) =>
    json.encode(data.toJson());

class BookingDetailsModel {
  ObjTickets objTickets;

  BookingDetailsModel({
    required this.objTickets,
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingDetailsModel(
        objTickets: ObjTickets.fromJson(json["objTickets"]),
      );

  Map<String, dynamic> toJson() => {
        "objTickets": objTickets.toJson(),
      };
}

class ObjTickets {
  int id;
  String title;
  String titleAr;
  String type;
  String typeAr;
  DateTime date;
  int? userId;
  String status;
  String statusAr;
  dynamic totalPrice;
  String customerName;
  String customerImage;
  String customerAddress;
  bool isWithFemale;
  String latitudel;
  String longitude;
  String mobile;
  String description;
  bool isWithMaterial;
  String esitmatedTime;
  String qrCodePath;
  String qrCode;
  String reportLink;
  bool isRated;
  String? reportSummary;
  List<dynamic> ticketAttatchments;
  List<dynamic> ticketImages;

  List<dynamic> ticketTools;
  List<dynamic> ticketMaterials;
  List<dynamic> maintenanceTickets;
  List<ServcieTicket> servcieTickets;
  List<AdvantageTicket> advantagesTickets;

  ObjTickets({
    required this.id,
    required this.advantagesTickets,
    required this.totalPrice,
    required this.title,
    required this.titleAr,
    required this.type,
    required this.userId,
    required this.typeAr,
    required this.ticketImages,
    required this.date,
    required this.status,
    required this.statusAr,
    required this.customerName,
    required this.customerImage,
    required this.customerAddress,
    required this.isWithFemale,
    required this.latitudel,
    required this.longitude,
    required this.mobile,
    required this.description,
    required this.isWithMaterial,
    required this.esitmatedTime,
    required this.qrCodePath,
    required this.qrCode,
    required this.reportLink,
    required this.isRated,
    this.reportSummary,
    required this.ticketAttatchments,
    required this.ticketTools,
    required this.ticketMaterials,
    required this.maintenanceTickets,
    required this.servcieTickets,
  });

  factory ObjTickets.fromJson(Map<String, dynamic> json) => ObjTickets(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        totalPrice: json["totalPrice"],
        userId: json["userId"],
        type: json["type"],
        typeAr: json["typeAr"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        statusAr: json["statusAr"] ?? json["status"],
        customerName: json["customerName"],
        customerImage: json["customerImage"],
        customerAddress: json["customerAddress"],
        isWithFemale: json["isWithFemale"],
        latitudel: json["latitudel"],
        longitude: json["longitude"],
        mobile: json["mobile"],
        description: json["description"],
        isWithMaterial: json["isWithMaterial"],
        esitmatedTime: json["esitmatedTime"],
        qrCodePath: json["qrCodePath"],
        qrCode: json["qrCode"],
        reportLink: json["reportLink"],
        isRated: json["isRated"],
        reportSummary: json["reportSummary"],
        ticketAttatchments:
            List<dynamic>.from(json["ticketAttatchments"].map((x) => x)),
        ticketImages: List<dynamic>.from(json["ticketImages"].map((x) => x)),
        ticketTools: List<dynamic>.from(json["ticketTools"].map((x) => x)),
        ticketMaterials:
            List<dynamic>.from(json["ticketMaterials"].map((x) => x)),
        maintenanceTickets:
            List<dynamic>.from(json["maintenanceTickets"].map((x) => x)),
        servcieTickets: List<ServcieTicket>.from(
            json["servcieTickets"].map((x) => ServcieTicket.fromJson(x))),
        advantagesTickets: List<AdvantageTicket>.from(
            json["advantageTickets"].map((x) => AdvantageTicket.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "userId": userId,
        "titleAr": titleAr,
        "type": type,
        "totalPrice": totalPrice,
        "typeAr": typeAr,
        "date": date.toIso8601String(),
        "status": status,
        "statusAr": statusAr,
        "customerName": customerName,
        "customerImage": customerImage,
        "customerAddress": customerAddress,
        "isWithFemale": isWithFemale,
        "latitudel": latitudel,
        "longitude": longitude,
        "mobile": mobile,
        "description": description,
        "isWithMaterial": isWithMaterial,
        "esitmatedTime": esitmatedTime,
        "qrCodePath": qrCodePath,
        "qrCode": qrCode,
        "reportLink": reportLink,
        "isRated": isRated,
        "reportSummary": reportSummary,
        "ticketAttatchments":
            List<dynamic>.from(ticketAttatchments.map((x) => x)),
        "ticketTools": List<dynamic>.from(ticketTools.map((x) => x)),
        "ticketMaterials": List<dynamic>.from(ticketMaterials.map((x) => x)),
        "maintenanceTickets":
            List<dynamic>.from(maintenanceTickets.map((x) => x)),
        "servcieTickets":
            List<dynamic>.from(servcieTickets.map((x) => x.toJson())),
      };
}

class ServcieTicket {
  int id;
  String name;
  String nameAr;
  dynamic price;
  dynamic quantity;

  ServcieTicket({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.quantity,
  });

  factory ServcieTicket.fromJson(Map<String, dynamic> json) => ServcieTicket(
        id: json["id"],
        name: json["name"],
        nameAr: json["nameAr"],
        price: json["price"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "nameAr": nameAr,
        "price": price,
        "quantity": quantity,
      };
}

class AdvantageTicket {
  int id;
  String name;
  String nameAr;
  dynamic price;

  AdvantageTicket({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
  });

  factory AdvantageTicket.fromJson(Map<String, dynamic> json) =>
      AdvantageTicket(
        id: json["id"],
        name: json["name"],
        nameAr: json["nameAr"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "nameAr": nameAr,
        "price": price,
      };
}
