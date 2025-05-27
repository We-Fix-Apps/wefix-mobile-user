import 'dart:convert';

HomeModel homeModelFromJson(String str) => HomeModel.fromJson(json.decode(str));

String homeModelToJson(HomeModel data) => json.encode(data.toJson());

class HomeModel {
  List<SliderModel> sliders;
  List<Category> categories;
  List<Service> serviceOffers;
  List<Service> servicePopular;
  Tickets? tickets;

  HomeModel({
    required this.sliders,
    required this.categories,
    required this.serviceOffers,
    required this.servicePopular,
    required this.tickets,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        sliders: List<SliderModel>.from(
            json["sliders"].map((x) => SliderModel.fromJson(x))),
        categories: List<Category>.from(
            json["categories"].map((x) => Category.fromJson(x))),
        serviceOffers: List<Service>.from(
            json["serviceOffers"].map((x) => Service.fromJson(x))),
        servicePopular: List<Service>.from(
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
  int id;
  String? title;
  String? titleAr;
  String? image;
  bool isActive;
  int sortOrder;

  SliderModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.image,
    required this.isActive,
    required this.sortOrder,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        id: json["id"],
        title: json["title"],
        titleAr: json["titleAr"],
        image: json["image"],
        isActive: json["isActive"],
        sortOrder: json["sortOrder"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "titleAr": titleAr,
        "image": image,
        "isActive": isActive,
        "sortOrder": sortOrder,
      };
}

class Category {
  int id;
  String? titleEn;
  String? titleAr;
  String? icon;
  String? image;
  List<Category>? subCategory;
  bool? subscribScreen;

  Category({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.image,
    this.subscribScreen,
    this.subCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        titleEn: json["titleEn"],
        subscribScreen: json["subscribScreen"] ?? false,
        titleAr: json["titleAr"],
        icon: json["icon"],
        image: json["image"],
        subCategory: json["subCategory"] == null
            ? []
            : List<Category>.from(
                json["subCategory"]!.map((x) => Category.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titleEn": titleEn,
        "titleAr": titleAr,
        "icon": icon,
        "image": image,
      };
}

class Service {
  int id;
  int categoryId;
  String? name;
  String? nameAr;
  String? icon;
  String? image;
  String? description;
  String? descriptionAr;
  double price;
  double discountPrice;
  bool isOffer;
  bool isPopular;
  bool haveQuantity;
  List<dynamic> serviceTickets;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.image,
    this.description,
    this.descriptionAr,
    required this.price,
    required this.discountPrice,
    required this.isOffer,
    required this.isPopular,
    required this.haveQuantity,
    required this.serviceTickets,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        categoryId: json["categoryId"],
        name: json["name"],
        nameAr: json["nameAr"],
        icon: json["icon"],
        image: json["image"],
        description: json["description"],
        descriptionAr: json["descriptionAr"],
        price: (json["price"] as num).toDouble(),
        discountPrice: (json["discountPrice"] as num).toDouble(),
        isOffer: json["isOffer"],
        isPopular: json["isPopular"],
        haveQuantity: json["haveQuantity"],
        serviceTickets:
            List<dynamic>.from(json["serviceTickets"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "name": name,
        "nameAr": nameAr,
        "icon": icon,
        "image": image,
        "description": description,
        "descriptionAr": descriptionAr,
        "price": price,
        "discountPrice": discountPrice,
        "isOffer": isOffer,
        "isPopular": isPopular,
        "haveQuantity": haveQuantity,
        "serviceTickets": List<dynamic>.from(serviceTickets.map((x) => x)),
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
  String? status;
  String? location;
  String? longitude;
  String? latitude;
  dynamic gender;
  bool isWithMaterial;
  dynamic priority;
  int createdBy;
  int customerPackageId;
  int totalPrice;
  dynamic serviceprovide;
  dynamic serviceprovideImage;
  String? description;
  String? descriptionAr;
  String? qrCodePath;
  int rating;
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
