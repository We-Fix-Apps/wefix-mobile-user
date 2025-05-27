class CartModel {
  List<Products>? products;
  double? total;
  String? currency;
  double? chargelistQyty;
  double? varialistqty;
  dynamic address;
  String? date;
  String? paymentStatus;
  String? orderStatus;
  List<ChargesModel>? chargesModel;

  CartModel({
    this.products,
    this.total,
    this.currency,
    this.chargelistQyty,
    this.varialistqty,
    this.address,
    this.date,
    this.paymentStatus,
    this.orderStatus,
    this.chargesModel,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    products = (json['products'] as List?)
        ?.map((dynamic e) => Products.fromJson(e as Map<String, dynamic>))
        .toList();
    total = json['total'] as double?;
    currency = json['currency'] as String?;
    chargelistQyty = json['chargelistQyty'] as double?;
    varialistqty = json['varialistqty'] as double?;
    address = json['address'];
    date = json['date'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    orderStatus = json['orderStatus'] as String?;
    chargesModel = (json['chargesModel'] as List?)
        ?.map((dynamic e) => ChargesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['products'] = products?.map((e) => e.toJson()).toList();
    json['total'] = total;
    json['currency'] = currency;
    json['chargelistQyty'] = chargelistQyty;
    json['varialistqty'] = varialistqty;
    json['address'] = address;
    json['date'] = date;
    json['paymentStatus'] = paymentStatus;
    json['orderStatus'] = orderStatus;
    json['chargesModel'] = chargesModel?.map((e) => e.toJson()).toList();
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
  dynamic paymentMethod;
  dynamic paymentStatus;
  dynamic paidAmount;
  ItemDetailMetaData? itemDetailMetaData;
  dynamic shippingDetailMetaData;

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
    this.itemDetailMetaData,
    this.shippingDetailMetaData,
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
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    paidAmount = json['paidAmount'];
    itemDetailMetaData =
        (json['itemDetailMetaData'] as Map<String, dynamic>?) != null
            ? ItemDetailMetaData.fromJson(
                json['itemDetailMetaData'] as Map<String, dynamic>)
            : null;
    shippingDetailMetaData = json['shippingDetailMetaData'];
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
    json['itemDetailMetaData'] = itemDetailMetaData?.toJson();
    json['shippingDetailMetaData'] = shippingDetailMetaData;
    return json;
  }
}

class ItemDetailMetaData {
  BasicModel? basicModel;
  PaymentModel? paymentModel;
  List<VariationModel>? variationModel;
  List<ChargesModel>? chargesModel;
  List<SaleschargesModel>? saleschargesModel;
  List<dynamic>? productDigitalMetaData;
  dynamic creditModel;
  dynamic subscriptionModel;

  ItemDetailMetaData({
    this.basicModel,
    this.paymentModel,
    this.variationModel,
    this.chargesModel,
    this.saleschargesModel,
    this.productDigitalMetaData,
    this.creditModel,
    this.subscriptionModel,
  });

  ItemDetailMetaData.fromJson(Map<String, dynamic> json) {
    basicModel = (json['basicModel'] as Map<String, dynamic>?) != null
        ? BasicModel.fromJson(json['basicModel'] as Map<String, dynamic>)
        : null;
    paymentModel = (json['paymentModel'] as Map<String, dynamic>?) != null
        ? PaymentModel.fromJson(json['paymentModel'] as Map<String, dynamic>)
        : null;
    variationModel = (json['variationModel'] as List?)
        ?.map((dynamic e) => VariationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    chargesModel = (json['chargesModel'] as List?)
        ?.map((dynamic e) => ChargesModel.fromJson(e as Map<String, dynamic>))
        .toList();
    saleschargesModel = (json['saleschargesModel'] as List?)
        ?.map((dynamic e) =>
            SaleschargesModel.fromJson(e as Map<String, dynamic>))
        .toList();
    productDigitalMetaData = json['productDigitalMetaData'] as List?;
    creditModel = json['creditModel'];
    subscriptionModel = json['subscriptionModel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['basicModel'] = basicModel?.toJson();
    json['paymentModel'] = paymentModel?.toJson();
    json['variationModel'] = variationModel?.map((e) => e.toJson()).toList();
    json['chargesModel'] = chargesModel?.map((e) => e.toJson()).toList();
    json['saleschargesModel'] =
        saleschargesModel?.map((e) => e.toJson()).toList();
    json['productDigitalMetaData'] = productDigitalMetaData;
    json['creditModel'] = creditModel;
    json['subscriptionModel'] = subscriptionModel;
    return json;
  }
}

class BasicModel {
  int? id;
  String? name;
  String? itemImage;
  int? quantity;
  String? description;
  String? itemURL;
  String? sellingType;
  String? listingType;
  String? invoiceNumber;

  BasicModel({
    this.id,
    this.name,
    this.itemImage,
    this.quantity,
    this.description,
    this.itemURL,
    this.sellingType,
    this.listingType,
    this.invoiceNumber,
  });

  BasicModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    itemImage = json['itemImage'] as String?;
    quantity = json['quantity'] as int?;
    description = json['description'] as String?;
    itemURL = json['itemURL'] as String?;
    sellingType = json['sellingType'] as String?;
    listingType = json['listingType'] as String?;
    invoiceNumber = json['invoiceNumber'] as String?;
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
    return json;
  }
}

class PaymentModel {
  double? conversionRate;
  double? conversionAmount;
  String? conversionCurrency;
  double? actualAmount;
  String? actualCurrency;

  PaymentModel({
    this.conversionRate,
    this.conversionAmount,
    this.conversionCurrency,
    this.actualAmount,
    this.actualCurrency,
  });

  PaymentModel.fromJson(Map<String, dynamic> json) {
    conversionRate = json['conversionRate'] as double?;
    conversionAmount = json['conversionAmount'] as double?;
    conversionCurrency = json['conversionCurrency'] as String?;
    actualAmount = json['actualAmount'] as double?;
    actualCurrency = json['actualCurrency'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['conversionRate'] = conversionRate;
    json['conversionAmount'] = conversionAmount;
    json['conversionCurrency'] = conversionCurrency;
    json['actualAmount'] = actualAmount;
    json['actualCurrency'] = actualCurrency;
    return json;
  }
}

class VariationModel {
  String? variationName;
  double? conversionRate;
  double? conversionAmount;
  String? conversionCurrency;
  double? actualAmount;
  String? actualCurrency;

  VariationModel({
    this.variationName,
    this.conversionRate,
    this.conversionAmount,
    this.conversionCurrency,
    this.actualAmount,
    this.actualCurrency,
  });

  VariationModel.fromJson(Map<String, dynamic> json) {
    variationName = json['variationName'] as String?;
    conversionRate = json['conversionRate'] as double?;
    conversionAmount = json['conversionAmount'] as double?;
    conversionCurrency = json['conversionCurrency'] as String?;
    actualAmount = json['actualAmount'] as double?;
    actualCurrency = json['actualCurrency'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['variationName'] = variationName;
    json['conversionRate'] = conversionRate;
    json['conversionAmount'] = conversionAmount;
    json['conversionCurrency'] = conversionCurrency;
    json['actualAmount'] = actualAmount;
    json['actualCurrency'] = actualCurrency;
    return json;
  }
}

class ChargesModel {
  String? chargesName;
  double? conversionRate;
  double? conversionAmount;
  String? conversionCurrency;
  double? actualAmount;
  String? actualCurrency;

  ChargesModel({
    this.chargesName,
    this.conversionRate,
    this.conversionAmount,
    this.conversionCurrency,
    this.actualAmount,
    this.actualCurrency,
  });

  ChargesModel.fromJson(Map<String, dynamic> json) {
    chargesName = json['chargesName'] as String?;
    conversionRate = json['conversionRate'] as double?;
    conversionAmount = json['conversionAmount'] as double?;
    conversionCurrency = json['conversionCurrency'] as String?;
    actualAmount = json['actualAmount'] as double?;
    actualCurrency = json['actualCurrency'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['chargesName'] = chargesName;
    json['conversionRate'] = conversionRate;
    json['conversionAmount'] = conversionAmount;
    json['conversionCurrency'] = conversionCurrency;
    json['actualAmount'] = actualAmount;
    json['actualCurrency'] = actualCurrency;
    return json;
  }
}

class SaleschargesModel {
  String? salesChargeName;
  double? conversionRate;
  double? conversionAmount;
  String? conversionCurrency;
  double? actualAmount;
  String? actualCurrency;

  SaleschargesModel({
    this.salesChargeName,
    this.conversionRate,
    this.conversionAmount,
    this.conversionCurrency,
    this.actualAmount,
    this.actualCurrency,
  });

  SaleschargesModel.fromJson(Map<String, dynamic> json) {
    salesChargeName = json['salesChargeName'] as String?;
    conversionRate = json['conversionRate'] as double?;
    conversionAmount = json['conversionAmount'] as double?;
    conversionCurrency = json['conversionCurrency'] as String?;
    actualAmount = json['actualAmount'] as double?;
    actualCurrency = json['actualCurrency'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['salesChargeName'] = salesChargeName;
    json['conversionRate'] = conversionRate;
    json['conversionAmount'] = conversionAmount;
    json['conversionCurrency'] = conversionCurrency;
    json['actualAmount'] = actualAmount;
    json['actualCurrency'] = actualCurrency;
    return json;
  }
}
