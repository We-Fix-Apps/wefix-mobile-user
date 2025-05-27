class OrdersDeatilsModel {
  List<Products>? products;
  String? total;
  String? currency;
  double? chargelistQyty;
  double? varialistqty;
  Address? address;
  String? date;
  String? paymentStatus;
  String? orderStatus;

  OrdersDeatilsModel({
    this.products,
    this.total,
    this.currency,
    this.chargelistQyty,
    this.varialistqty,
    this.address,
    this.date,
    this.paymentStatus,
    this.orderStatus,
  });

  OrdersDeatilsModel.fromJson(Map<String, dynamic> json) {
    products = (json['products'] as List?)?.map((dynamic e) => Products.fromJson(e as Map<String,dynamic>)).toList();
    total = json['total'] as String?;
    currency = json['currency'] as String?;
    chargelistQyty = json['chargelistQyty'] as double?;
    varialistqty = json['varialistqty'] as double?;
    address = (json['address'] as Map<String,dynamic>?) != null ? Address.fromJson(json['address'] as Map<String,dynamic>) : null;
    date = json['date'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    orderStatus = json['orderStatus'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['products'] = products?.map((e) => e.toJson()).toList();
    json['total'] = total;
    json['currency'] = currency;
    json['chargelistQyty'] = chargelistQyty;
    json['varialistqty'] = varialistqty;
    json['address'] = address?.toJson();
    json['date'] = date;
    json['paymentStatus'] = paymentStatus;
    json['orderStatus'] = orderStatus;
    return json;
  }
}

class Products {
  int? id;
  String? name;
  String? itemImage;
  int? quantity;
  String? description;
  String? itemURL;
  String? sellingType;
  String? listingType;
  String? invoiceNumber;
  String? itemQtyTotal;
  String? varialistqty;
  String? chargelistQyty;
  String? paymentMethod;
  String? paymentStatus;
  String? paidAmount;

  Products({
    this.id,
    this.name,
    this.itemImage,
    this.quantity,
    this.description,
    this.itemURL,
    this.sellingType,
    this.listingType,
    this.invoiceNumber,
    this.itemQtyTotal,
    this.varialistqty,
    this.chargelistQyty,
    this.paymentMethod,
    this.paymentStatus,
    this.paidAmount,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    itemImage = json['itemImage'] as String?;
    quantity = json['quantity'] as int?;
    description = json['description'] as String?;
    itemURL = json['itemURL'] as String?;
    sellingType = json['sellingType'] as String?;
    listingType = json['listingType'] as String?;
    invoiceNumber = json['invoiceNumber'] as String?;
    itemQtyTotal = json['itemQtyTotal'] as String?;
    varialistqty = json['varialistqty'] as String?;
    chargelistQyty = json['chargelistQyty'] as String?;
    paymentMethod = json['paymentMethod'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    paidAmount = json['paidAmount'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['name'] = name;
    json['itemImage'] = itemImage;
    json['quantity'] = quantity;
    json['description'] = description;
    json['itemURL'] = itemURL;
    json['sellingType'] = sellingType;
    json['listingType'] = listingType;
    json['invoiceNumber'] = invoiceNumber;
    json['itemQtyTotal'] = itemQtyTotal;
    json['varialistqty'] = varialistqty;
    json['chargelistQyty'] = chargelistQyty;
    json['paymentMethod'] = paymentMethod;
    json['paymentStatus'] = paymentStatus;
    json['paidAmount'] = paidAmount;
    return json;
  }
}

class Address {
  String? fullName;
  String? addressType;
  String? shippingAddress;
  String? shippingEmail;
  String? shippingPhone;
  String? shippingLatitude;
  String? shippingLongitude;
  String? nearestLandMark;

  Address({
    this.fullName,
    this.addressType,
    this.shippingAddress,
    this.shippingEmail,
    this.shippingPhone,
    this.shippingLatitude,
    this.shippingLongitude,
    this.nearestLandMark,
  });

  Address.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'] as String?;
    addressType = json['addressType'] as String?;
    shippingAddress = json['shippingAddress'] as String?;
    shippingEmail = json['shippingEmail'] as String?;
    shippingPhone = json['shippingPhone'] as String?;
    shippingLatitude = json['shippingLatitude'] as String?;
    shippingLongitude = json['shippingLongitude'] as String?;
    nearestLandMark = json['nearestLandMark'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['fullName'] = fullName;
    json['addressType'] = addressType;
    json['shippingAddress'] = shippingAddress;
    json['shippingEmail'] = shippingEmail;
    json['shippingPhone'] = shippingPhone;
    json['shippingLatitude'] = shippingLatitude;
    json['shippingLongitude'] = shippingLongitude;
    json['nearestLandMark'] = nearestLandMark;
    return json;
  }
}