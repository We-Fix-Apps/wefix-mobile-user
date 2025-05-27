class ShippingInfoModel {
  List<Products>? products;
  String? total;
  String? currency;
  String? invoice;
  double? chargelistQyty;
  double? varialistqty;
  String? date;
  String? paymentStatus;
  String? orderStatus;
  List<Rates>? rates;
  BuyerAddreess? buyerAddreess;
  List<ListSellerAdderss>? listSellerAdderss;

  ShippingInfoModel({
    this.products,
    this.total,
    this.currency,
    this.chargelistQyty,
    this.invoice,
    this.varialistqty,
    this.date,
    this.paymentStatus,
    this.orderStatus,
    this.rates,
    this.buyerAddreess,
    this.listSellerAdderss,
  });

  ShippingInfoModel.fromJson(Map<String, dynamic> json) {
    products = (json['products'] as List?)
        ?.map((dynamic e) => Products.fromJson(e as Map<String, dynamic>))
        .toList();
    invoice = json['invoice'] as String?;
    total = json['total'] as String?;
    currency = json['currency'] as String?;
    chargelistQyty = json['chargelistQyty'] as double?;
    varialistqty = json['varialistqty'] as double?;
    date = json['date'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    orderStatus = json['orderStatus'] as String?;
    rates = (json['rates'] as List?)
        ?.map((dynamic e) => Rates.fromJson(e as Map<String, dynamic>))
        .toList();
    buyerAddreess = (json['buyerAddreess'] as Map<String, dynamic>?) != null
        ? BuyerAddreess.fromJson(json['buyerAddreess'] as Map<String, dynamic>)
        : null;
    listSellerAdderss = (json['listSellerAdderss'] as List?)
        ?.map((dynamic e) =>
            ListSellerAdderss.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['products'] = products?.map((e) => e.toJson()).toList();
    json['total'] = total;
    json['invoice'] = invoice;
    json['currency'] = currency;
    json['chargelistQyty'] = chargelistQyty;
    json['varialistqty'] = varialistqty;
    json['date'] = date;
    json['paymentStatus'] = paymentStatus;
    json['orderStatus'] = orderStatus;
    json['rates'] = rates?.map((e) => e.toJson()).toList();
    json['buyerAddreess'] = buyerAddreess?.toJson();
    json['listSellerAdderss'] =
        listSellerAdderss?.map((e) => e.toJson()).toList();
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
  dynamic varialistqty;
  String? chargelistQyty;
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic paidAmount;

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
    varialistqty = json['varialistqty'];
    chargelistQyty = json['chargelistQyty'] as String?;
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    paidAmount = json['paidAmount'];
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

class Rates {
  int? id;
  String? objectId;
  String? objectCreated;
  String? objectOwner;
  String? shipment;
  String? amount;
  String? currency;
  String? amountLocal;
  String? currencyLocal;
  List<dynamic>? attributes;
  String? provider;
  String? providerImage75;
  String? providerImage200;
  String? arrivesBy;
  String? durationTerms;
  List<dynamic>? messages;
  String? carrierAccount;
  String? zone;
  bool? test;
  Servicelevel? servicelevel;
  int? estimatedDays;
  dynamic includedInsurancePrice;

  Rates({
    this.id,
    this.objectId,
    this.objectCreated,
    this.objectOwner,
    this.shipment,
    this.amount,
    this.currency,
    this.amountLocal,
    this.currencyLocal,
    this.attributes,
    this.provider,
    this.providerImage75,
    this.providerImage200,
    this.arrivesBy,
    this.durationTerms,
    this.messages,
    this.carrierAccount,
    this.zone,
    this.test,
    this.servicelevel,
    this.estimatedDays,
    this.includedInsurancePrice,
  });

  Rates.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;

    objectId = json['object_id'] as String?;
    objectCreated = json['object_created'] as String?;
    objectOwner = json['object_owner'] as String?;
    shipment = json['shipment'] as String?;
    amount = json['amount'] as String?;
    currency = json['currency'] as String?;
    amountLocal = json['amount_local'] as String?;
    currencyLocal = json['currency_local'] as String?;
    attributes = json['attributes'] as List?;
    provider = json['provider'] as String?;
    providerImage75 = json['provider_image_75'] as String?;
    providerImage200 = json['provider_image_200'] as String?;
    arrivesBy = json['arrives_by'] as String?;
    durationTerms = json['duration_terms'] as String?;
    messages = json['messages'] as List?;
    carrierAccount = json['carrier_account'] as String?;
    zone = json['zone'] as String?;
    test = json['test'] as bool?;
    servicelevel = (json['servicelevel'] as Map<String, dynamic>?) != null
        ? Servicelevel.fromJson(json['servicelevel'] as Map<String, dynamic>)
        : null;
    estimatedDays = json['estimated_days'] as int?;
    includedInsurancePrice = json['included_insurance_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['object_id'] = objectId;
    json['object_created'] = objectCreated;
    json['object_owner'] = objectOwner;
    json['shipment'] = shipment;
    json['amount'] = amount;
    json['currency'] = currency;
    json['amount_local'] = amountLocal;
    json['currency_local'] = currencyLocal;
    json['attributes'] = attributes;
    json['provider'] = provider;
    json['provider_image_75'] = providerImage75;
    json['provider_image_200'] = providerImage200;
    json['arrives_by'] = arrivesBy;
    json['duration_terms'] = durationTerms;
    json['messages'] = messages;
    json['carrier_account'] = carrierAccount;
    json['zone'] = zone;
    json['test'] = test;
    json['servicelevel'] = servicelevel?.toJson();
    json['estimated_days'] = estimatedDays;
    json['included_insurance_price'] = includedInsurancePrice;
    return json;
  }
}

class Servicelevel {
  String? name;
  String? token;
  String? terms;
  String? extendedToken;
  dynamic displayName;
  dynamic parentServicelevel;

  Servicelevel({
    this.name,
    this.token,
    this.terms,
    this.extendedToken,
    this.displayName,
    this.parentServicelevel,
  });

  Servicelevel.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    token = json['token'] as String?;
    terms = json['terms'] as String?;
    extendedToken = json['extended_token'] as String?;
    displayName = json['display_name'];
    parentServicelevel = json['parent_servicelevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['name'] = name;
    json['token'] = token;
    json['terms'] = terms;
    json['extended_token'] = extendedToken;
    json['display_name'] = displayName;
    json['parent_servicelevel'] = parentServicelevel;
    return json;
  }
}

class BuyerAddreess {
  String? name;
  dynamic company;
  String? street1;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? phone;
  String? email;
  dynamic rates;
  String? lat;
  String? long;

  BuyerAddreess({
    this.name,
    this.company,
    this.street1,
    this.lat,
    this.long,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
    this.email,
    this.rates,
  });

  BuyerAddreess.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    company = json['company'];
    street1 = json['street1'] as String?;
    city = json['city'] as String?;
    state = json['state'] as String?;
    zip = json['zip'] as String?;
    country = json['country'] as String?;
    phone = json['phone'] as String?;
    email = json['email'] as String?;
    rates = json['rates'];
    lat = json['latitude'] as String?;
    long = json['longitude'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['name'] = name;
    json['company'] = company;
    json['street1'] = street1;
    json['city'] = city;
    json['state'] = state;
    json['zip'] = zip;
    json['country'] = country;
    json['phone'] = phone;
    json['email'] = email;
    json['rates'] = rates;
    return json;
  }
}

class ListSellerAdderss {
  String? name;
  String? company;
  String? street1;
  String? city;
  String? state;

  String? zip;
  String? country;
  String? phone;
  String? email;
  int? id;
  String? image;
  List<Rates>? rates;

  ListSellerAdderss({
    this.name,
    this.company,
    this.id,
    this.image,
    this.street1,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phone,
    this.email,
    this.rates,
  });

  ListSellerAdderss.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    company = json['company'] as String?;

    id = json['id'] as int?;
    image = json['image'] as String?;
    street1 = json['street1'] as String?;
    city = json['city'] as String?;
    state = json['state'] as String?;
    zip = json['zip'] as String?;
    country = json['country'] as String?;
    phone = json['phone'] as String?;
    email = json['email'] as String?;
    rates = (json['rates'] as List?)
        ?.map((dynamic e) => Rates.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['name'] = name;
    json['company'] = company;
    json['street1'] = street1;
    json['city'] = city;
    json['state'] = state;
    json['zip'] = zip;
    json['country'] = country;
    json['phone'] = phone;
    json['email'] = email;
    json['rates'] = rates?.map((e) => e.toJson()).toList();
    return json;
  }
}