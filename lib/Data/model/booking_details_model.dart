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
  String status;
  bool? isWithFemale;
  String customerName;
  dynamic customerImage;
  String customerAddress;
  String latitudel;
  String longitude;
  String mobile;
  String description;
  bool isWithMaterial;
  bool? isReated;
  String esitmatedTime;
  String? qrCodePath;
  String? qrCode;
  String reportLink;
  List<TicketAttatchment> ticketAttatchments;
  List<TicketTool> ticketTools;
  List<TicketMaterial> ticketMaterials;
  List<MaintenanceTicket> maintenanceTickets;

  ObjTickets({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.isReated,
    required this.type,
    required this.isWithFemale,
    required this.typeAr,
    required this.date,
    required this.status,
    required this.customerName,
    required this.customerImage,
    required this.customerAddress,
    required this.latitudel,
    required this.longitude,
    required this.mobile,
    required this.description,
    required this.isWithMaterial,
    required this.esitmatedTime,
    required this.qrCodePath,
    required this.qrCode,
    required this.reportLink,
    required this.ticketAttatchments,
    required this.ticketTools,
    required this.ticketMaterials,
    required this.maintenanceTickets,
  });

  factory ObjTickets.fromJson(Map<String, dynamic> json) => ObjTickets(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        isReated: json["isRated"],
        type: json["type"],
        typeAr: json["typeAr"],
        date: DateTime.parse(json["date"]),
        status: json["status"],
        isWithFemale: json["isWithFemale"],
        customerName: json["customerName"],
        customerImage: json["customerImage"],
        customerAddress: json["customerAddress"],
        latitudel: json["latitudel"],
        longitude: json["longitude"],
        mobile: json["mobile"],
        description: json["description"],
        isWithMaterial: json["isWithMaterial"],
        esitmatedTime: json["esitmatedTime"],
        qrCodePath: json["qrCodePath"],
        qrCode: json["qrCode"],
        reportLink: json["reportLink"],
        ticketAttatchments: List<TicketAttatchment>.from(
            json["ticketAttatchments"]
                .map((x) => TicketAttatchment.fromJson(x))),
        ticketTools: List<TicketTool>.from(
            json["ticketTools"].map((x) => TicketTool.fromJson(x))),
        ticketMaterials: List<TicketMaterial>.from(
            json["ticketMaterials"].map((x) => TicketMaterial.fromJson(x))),
        maintenanceTickets: List<MaintenanceTicket>.from(
            json["maintenanceTickets"]
                .map((x) => MaintenanceTicket.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isReated": isReated,
        "titleAr": titleAr,
        "isWithFemale": isWithFemale,
        "type": type,
        "typeAr": typeAr,
        "date": date.toIso8601String(),
        "status": status,
        "customerName": customerName,
        "customerImage": customerImage,
        "customerAddress": customerAddress,
        "latitudel": latitudel,
        "longitude": longitude,
        "mobile": mobile,
        "description": description,
        "isWithMaterial": isWithMaterial,
        "esitmatedTime": esitmatedTime,
        "qrCodePath": qrCodePath,
        "qrCode": qrCode,
        "reportLink": reportLink,
        "ticketAttatchments":
            List<dynamic>.from(ticketAttatchments.map((x) => x.toJson())),
        "ticketTools": List<dynamic>.from(ticketTools.map((x) => x.toJson())),
        "ticketMaterials":
            List<dynamic>.from(ticketMaterials.map((x) => x.toJson())),
        "maintenanceTickets":
            List<dynamic>.from(maintenanceTickets.map((x) => x.toJson())),
      };
}

class MaintenanceTicket {
  int id;
  String name;
  String nameAr;
  String description;
  String note;

  MaintenanceTicket({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.note,
  });

  factory MaintenanceTicket.fromJson(Map<String, dynamic> json) =>
      MaintenanceTicket(
        id: json["id"],
        name: json["name"],
        nameAr: json["nameAr"],
        description: json["description"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "nameAr": nameAr,
        "description": description,
        "note": note,
      };
}

class TicketAttatchment {
  int id;
  int ticketId;
  dynamic size;
  dynamic fileName;
  String filePath;
  dynamic type;
  DateTime createdDate;
  dynamic ticket;

  TicketAttatchment({
    required this.id,
    required this.ticketId,
    required this.size,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.createdDate,
    required this.ticket,
  });

  factory TicketAttatchment.fromJson(Map<String, dynamic> json) =>
      TicketAttatchment(
        id: json["id"],
        ticketId: json["ticketId"],
        size: json["size"],
        fileName: json["fileName"],
        filePath: json["filePath"],
        type: json["type"],
        createdDate: DateTime.parse(json["createdDate"]),
        ticket: json["ticket"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ticketId": ticketId,
        "size": size,
        "fileName": fileName,
        "filePath": filePath,
        "type": type,
        "createdDate": createdDate.toIso8601String(),
        "ticket": ticket,
      };
}

class TicketMaterial {
  int id;
  String title;
  String titleAr;
  String status;
  bool iSselected;
  int quantity;

  TicketMaterial({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.status,
    required this.iSselected,
    required this.quantity,
  });

  factory TicketMaterial.fromJson(Map<String, dynamic> json) => TicketMaterial(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        status: json["status"],
        iSselected: json["iSselected"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "titleAr": titleAr,
        "status": status,
        "iSselected": iSselected,
        "quantity": quantity,
      };
}

class TicketTool {
  int id;
  String title;
  String titleAr;
  int quantity;

  TicketTool({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.quantity,
  });

  factory TicketTool.fromJson(Map<String, dynamic> json) => TicketTool(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "titleAr": titleAr,
        "quantity": quantity,
      };
}
