import 'dart:convert';

// To parse this JSON data, do:
// final ticketModel = ticketModelFromJson(jsonString);

TicketModel ticketModelFromJson(String str) =>
    TicketModel.fromJson(json.decode(str));

String ticketModelToJson(TicketModel data) => json.encode(data.toJson());

class TicketModel {
  List<Ticket> tickets;

  TicketModel({
    required this.tickets,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
        tickets:
            List<Ticket>.from(json["tickets"].map((x) => Ticket.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tickets": List<dynamic>.from(tickets.map((x) => x.toJson())),
      };
}

class Ticket {
  int id;
  int customerId;
  int ticketTypeId;
  String? promoCode;
  DateTime requestedDate;
  DateTime selectedDate;
  String? selectedDateTime;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic teamNo;
  String? status;
  String? statusAr;
  dynamic rating;
  String? type;
  String? location;
  String? longitude;
  String? latitude;
  String? gender;
  bool isWithMaterial;
  bool? isRated;
  dynamic priority;
  int createdBy;
  int? customerPackageId;
  double totalPrice;
  dynamic serviceprovide;
  String? serviceprovideName; // Technician name (Arabic)
  String? serviceprovideNameEnglish; // Technician name (English)
  String? serviceprovideImage;
  String? description;
  String? descriptionAr;
  String? icon;
  String? mainServiceTitle;
  String? mainServiceNameArabic;
  String? ticketTitle;
  bool? cancelButton;
  String? ticketCodeId;
  int? delegatedToCompanyId;
  String? delegatedToCompanyTitle;
  int? companyId; // Original company that created the ticket
  String? companyTitle; // Original company name that delegated the ticket (title/fallback)
  String? companyNameArabic; // Company name in Arabic
  String? companyNameEnglish; // Company name in English

  Ticket({
    required this.id,
    required this.customerId,
    required this.statusAr,
    required this.ticketTypeId,
    this.rating,
    this.icon,
    this.mainServiceTitle,
    this.mainServiceNameArabic,
    this.ticketTitle,
    this.cancelButton,
    this.isRated,
    this.type,
    this.serviceprovideImage,
    this.ticketCodeId,
    this.delegatedToCompanyId,
    this.delegatedToCompanyTitle,
    this.companyId,
    this.companyTitle,
    this.companyNameArabic,
    this.companyNameEnglish,
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
    this.serviceprovideName,
    this.serviceprovideNameEnglish,
    required this.description,
    required this.descriptionAr,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json["id"],
        cancelButton: json["cancelButton"],
        isRated: json["isRated"],
        customerId: json["customerId"],
        type: json["type"],
        ticketTypeId: json["ticketTypeId"],
        statusAr: json["statusAr"],
        serviceprovideImage: json["serviceprovideImage"],
        promoCode: json["promoCode"],
        rating: json["rating"],
        icon: json["icon"],
        mainServiceTitle: json["mainServiceTitle"],
        mainServiceNameArabic: json["mainServiceNameArabic"],
        ticketTitle: json["ticketTitle"],
        ticketCodeId: json["ticketCodeId"],
        delegatedToCompanyId: json["delegatedToCompanyId"],
        delegatedToCompanyTitle: json["delegatedToCompanyTitle"],
        companyId: json["companyId"],
        companyTitle: json["company"]?["title"] ?? null,
        companyNameArabic: json["companyNameArabic"],
        companyNameEnglish: json["companyNameEnglish"],
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
        gender: json["gender"],
        isWithMaterial: json["isWithMaterial"],
        priority: json["priority"],
        createdBy: json["createdBy"],
        customerPackageId: json["customerPackageId"],
        totalPrice: (json["totalPrice"] as num).toDouble(),
        serviceprovide: json["serviceprovide"],
        serviceprovideName: json["serviceprovideName"],
        serviceprovideNameEnglish: json["serviceprovideNameEnglish"],
        description: json["description"],
        descriptionAr: json["descriptionAr"],
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
        "serviceprovideImage": serviceprovideImage,
        "timeTo": timeTo,
        "type": type,
        "icon": icon,
        "mainServiceTitle": mainServiceTitle,
        "mainServiceNameArabic": mainServiceNameArabic,
        "ticketTitle": ticketTitle,
        "ticketCodeId": ticketCodeId,
        "delegatedToCompanyId": delegatedToCompanyId,
        "delegatedToCompanyTitle": delegatedToCompanyTitle,
        "companyId": companyId,
        "companyTitle": companyTitle,
        "companyNameArabic": companyNameArabic,
        "companyNameEnglish": companyNameEnglish,
        "teamNo": teamNo,
        "isRated": isRated,
        "cancelButton": cancelButton,
        "status": status,
        "statusAr": statusAr,
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
        "serviceprovideName": serviceprovideName,
        "serviceprovideNameEnglish": serviceprovideNameEnglish,
        "description": description,
        "descriptionAr": descriptionAr,
      };
}
