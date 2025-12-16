import 'dart:convert';

HomeModel homeModelFromJson(String str) => HomeModel.fromJson(json.decode(str));

String homeModelToJson(HomeModel data) => json.encode(data.toJson());

class HomeModel {
  List<SliderModel> sliders;
  List<Category> categories;
  List<Service> serviceOffers;
  List<Service> servicePopular;
  int ? roleId ;
  Tickets? tickets;

  HomeModel({
    required this.sliders,
    required this.categories,
    required this.serviceOffers,
    required this.servicePopular,
    required this.tickets,
    required this.roleId
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        sliders: json["sliders"] == null
            ? []
            : List<SliderModel>.from(
                json["sliders"].map((x) => SliderModel.fromJson(x))),
        roleId: json["roleId"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        serviceOffers: json["serviceOffers"] == null
            ? []
            : List<Service>.from(
                json["serviceOffers"].map((x) => Service.fromJson(x))),
        servicePopular: json["servicePopular"] == null
            ? []
            : List<Service>.from(
                json["servicePopular"].map((x) => Service.fromJson(x))),
        tickets:
            json["tickets"] != null ? Tickets.fromJson(json["tickets"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "sliders": List<dynamic>.from(sliders.map((x) => x.toJson())),
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "serviceOffers":
            List<dynamic>.from(serviceOffers.map((x) => x.toJson())),
        "servicePopular":
            List<dynamic>.from(servicePopular.map((x) => x.toJson())),
        "tickets": tickets?.toJson(),
      };
}

class SliderModel {
  dynamic id;
  String? title;
  String? titleAr;
  String? image;
  bool isActive;
  dynamic? sortOrder;
  int? categoryId;

  SliderModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.titleAr,
    required this.image,
    required this.isActive,
    required this.sortOrder,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        categoryId: json["categoryId"],
        image: json["image"],
        isActive: json["isActive"],
        sortOrder: json["sortOrder"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "categoryId": categoryId,
        "titleAr": titleAr,
        "image": image,
        "isActive": isActive,
        "sortOrder": sortOrder,
      };
}

class Category {
  dynamic id;
  dynamic? parentId;
  String titleEn;
  String titleAr;
  String? icon;
  String image;
  bool? subscribScreen;
  List<Category>? subCategory;
  List<Service> service;

  Category({
    required this.id,
    required this.parentId,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.image,
    this.subscribScreen,
    this.subCategory,
    required this.service,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        parentId: json["parentId"],
        titleEn: json["titleEn"],
        titleAr: json["titleAr"],
        icon: json["icon"],
        image: json["image"],
        subscribScreen: json["subscribScreen"],
        subCategory: json["subCategory"] == null
            ? []
            : List<Category>.from(
                json["subCategory"]!.map((x) => Category.fromJson(x))),
        service: json["service"] == null
            ? []
            : List<Service>.from(json["service"].map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parentId": parentId,
        "titleEn": titleEn,
        "titleAr": titleAr,
        "icon": icon,
        "image": image,
        "subscribScreen": subscribScreen,
        "subCategory": subCategory == null
            ? []
            : List<dynamic>.from(subCategory!.map((x) => x.toJson())),
        "service": List<dynamic>.from(service.map((x) => x.toJson())),
      };
}

class Service {
  dynamic id;
  dynamic? categoryId;
  String name;
  String nameAr;
  String icon;
  String image;
  String? description;
  dynamic? price;
  dynamic? discountPrice;
  bool isOffer;
  bool isPopular;
  bool haveQuantity;
  String? descriptionAr;
  dynamic? sortOrder;
  dynamic? numOfTicket;
  dynamic? subscriptionPrice;
  dynamic category;
  List<dynamic>? serviceTickets;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.image,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.isOffer,
    required this.isPopular,
    required this.haveQuantity,
    required this.descriptionAr,
    required this.sortOrder,
    this.numOfTicket,
    this.subscriptionPrice,
    this.category,
    this.serviceTickets,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        categoryId: json["categoryId"],
        name: json["name"],
        nameAr: json["nameAr"],
        icon: json["icon"],
        image: json["image"],
        description: json["description"],
        price: json["price"],
        discountPrice: json["discountPrice"],
        isOffer: json["isOffer"],
        isPopular: json["isPopular"],
        haveQuantity: json["haveQuantity"],
        descriptionAr: json["descriptionAr"],
        sortOrder: json["sortOrder"],
        numOfTicket: json["numOfTicket"],
        subscriptionPrice: json["subscriptionPrice"],
        category: json["category"],
        serviceTickets: json["serviceTickets"] == null
            ? []
            : List<dynamic>.from(json["serviceTickets"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "name": name,
        "nameAr": nameAr,
        "icon": icon,
        "image": image,
        "description": description,
        "price": price,
        "discountPrice": discountPrice,
        "isOffer": isOffer,
        "isPopular": isPopular,
        "haveQuantity": haveQuantity,
        "descriptionAr": descriptionAr,
        "sortOrder": sortOrder,
        "numOfTicket": numOfTicket,
        "subscriptionPrice": subscriptionPrice,
        "category": category,
        "serviceTickets": serviceTickets == null
            ? []
            : List<dynamic>.from(serviceTickets!.map((x) => x)),
      };
}

class Tickets {
  dynamic id;
  dynamic? customerId;
  dynamic? ticketTypeId;
  String promoCode;
  DateTime requestedDate;
  DateTime selectedDate;
  String selectedDateTime;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic teamNo;
  String? status;
  String? location;
  String? longitude;
  String? latitude;
  dynamic gender;
  bool isWithMaterial;
  dynamic priority;
  dynamic? createdBy;
  dynamic? customerPackageId;
  dynamic totalPrice;
  dynamic serviceprovide;
  dynamic serviceprovideImage;
  String? description;
  String? descriptionAr;
  String? qrCodePath;
  dynamic? rating;
  bool isRated;
  String? qrCode;
  String? statusAr;

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
        gender: json["gender"],
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
