class OrdersModel {
  List<Orders>? orders;

  OrdersModel({
    this.orders,
  });

  OrdersModel.fromJson(Map<String, dynamic> json) {
    orders = (json['orders'] as List?)
        ?.map((dynamic e) => Orders.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['orders'] = orders?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Orders {
  int? orderId;
  int? buyerID;
  int? sellerID;
  String? itemType;
  String? orderStatus;
  String? orderProcessStatus;
  String? orderDateDT;
  String? orderDate;
  String? updateDate;
  dynamic vendorNotes;
  dynamic adminNotes;
  String? invoiceNumber;
  String? paymentStatus;
  String? transactionType;
  String? incomingOutgoing;
  ItemDetailMetaData? itemDetailMetaData;
  dynamic variationMetaData;
  dynamic chargesDetailMetaData;
  PaymentMetaData? paymentMetaData;
  List<OrderStatusMetaData>? orderStatusMetaData;
  SummaryOrderMetaData? summaryOrderMetaData;
  ShippingDetailMetaData? shippingDetailMetaData;
  SellerViewModel? sellerViewModel;
  BuyerViewModel? buyerViewModel;
  dynamic reviewMetaData;

  Orders({
    this.orderId,
    this.buyerID,
    this.sellerID,
    this.itemType,
    this.orderStatus,
    this.orderProcessStatus,
    this.orderDateDT,
    this.orderDate,
    this.updateDate,
    this.vendorNotes,
    this.adminNotes,
    this.invoiceNumber,
    this.paymentStatus,
    this.transactionType,
    this.incomingOutgoing,
    this.itemDetailMetaData,
    this.variationMetaData,
    this.chargesDetailMetaData,
    this.paymentMetaData,
    this.orderStatusMetaData,
    this.summaryOrderMetaData,
    this.shippingDetailMetaData,
    this.sellerViewModel,
    this.buyerViewModel,
    this.reviewMetaData,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'] as int?;
    buyerID = json['buyerID'] as int?;
    sellerID = json['sellerID'] as int?;
    itemType = json['itemType'] as String?;
    orderStatus = json['orderStatus'] as String?;
    orderProcessStatus = json['orderProcessStatus'] as String?;
    orderDateDT = json['orderDateDT'] as String?;
    orderDate = json['orderDate'] as String?;
    updateDate = json['updateDate'] as String?;
    vendorNotes = json['vendorNotes'];
    adminNotes = json['adminNotes'];
    invoiceNumber = json['invoiceNumber'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    transactionType = json['transactionType'] as String?;
    incomingOutgoing = json['incomingOutgoing'] as String?;
    itemDetailMetaData =
        (json['itemDetailMetaData'] as Map<String, dynamic>?) != null
            ? ItemDetailMetaData.fromJson(
                json['itemDetailMetaData'] as Map<String, dynamic>)
            : null;
    variationMetaData = json['variationMetaData'];
    chargesDetailMetaData = json['chargesDetailMetaData'];
    paymentMetaData = (json['paymentMetaData'] as Map<String, dynamic>?) != null
        ? PaymentMetaData.fromJson(
            json['paymentMetaData'] as Map<String, dynamic>)
        : null;
    orderStatusMetaData = (json['orderStatusMetaData'] as List?)
        ?.map((dynamic e) =>
            OrderStatusMetaData.fromJson(e as Map<String, dynamic>))
        .toList();
    summaryOrderMetaData =
        (json['summaryOrderMetaData'] as Map<String, dynamic>?) != null
            ? SummaryOrderMetaData.fromJson(
                json['summaryOrderMetaData'] as Map<String, dynamic>)
            : null;
    shippingDetailMetaData =
        (json['shippingDetailMetaData'] as Map<String, dynamic>?) != null
            ? ShippingDetailMetaData.fromJson(
                json['shippingDetailMetaData'] as Map<String, dynamic>)
            : null;
    sellerViewModel = (json['sellerViewModel'] as Map<String, dynamic>?) != null
        ? SellerViewModel.fromJson(
            json['sellerViewModel'] as Map<String, dynamic>)
        : null;
    buyerViewModel = (json['buyerViewModel'] as Map<String, dynamic>?) != null
        ? BuyerViewModel.fromJson(
            json['buyerViewModel'] as Map<String, dynamic>)
        : null;
    reviewMetaData = json['reviewMetaData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['orderId'] = orderId;
    json['buyerID'] = buyerID;
    json['sellerID'] = sellerID;
    json['itemType'] = itemType;
    json['orderStatus'] = orderStatus;
    json['orderProcessStatus'] = orderProcessStatus;
    json['orderDateDT'] = orderDateDT;
    json['orderDate'] = orderDate;
    json['updateDate'] = updateDate;
    json['vendorNotes'] = vendorNotes;
    json['adminNotes'] = adminNotes;
    json['invoiceNumber'] = invoiceNumber;
    json['paymentStatus'] = paymentStatus;
    json['transactionType'] = transactionType;
    json['incomingOutgoing'] = incomingOutgoing;
    json['itemDetailMetaData'] = itemDetailMetaData?.toJson();
    json['variationMetaData'] = variationMetaData;
    json['chargesDetailMetaData'] = chargesDetailMetaData;
    json['paymentMetaData'] = paymentMetaData?.toJson();
    json['orderStatusMetaData'] =
        orderStatusMetaData?.map((e) => e.toJson()).toList();
    json['summaryOrderMetaData'] = summaryOrderMetaData?.toJson();
    json['shippingDetailMetaData'] = shippingDetailMetaData?.toJson();
    json['sellerViewModel'] = sellerViewModel?.toJson();
    json['buyerViewModel'] = buyerViewModel?.toJson();
    json['reviewMetaData'] = reviewMetaData;
    return json;
  }
}

class ItemDetailMetaData {
  BasicModel? basicModel;
  PaymentModel? paymentModel;
  List<VariationModel>? variationModel;
  List<ChargesModel>? chargesModel;
  dynamic saleschargesModel;
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
    saleschargesModel = json['saleschargesModel'];
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
    json['saleschargesModel'] = saleschargesModel;
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

class PaymentMetaData {
  String? paymentMethod;
  String? paymentStatus;
  String? paymentReference;
  String? paymentReferenceFile;
  String? payerID;
  double? paidAmount;
  String? paidCurrency;
  double? walletDeduction;
  String? paymentDate;
  String? invoiceNumber;
  String? paymentStructure;
  String? payerEmailID;
  double? conversionRate;
  double? conversionAmount;
  String? conversionCurrency;
  double? actualAmount;
  String? actualCurrency;

  PaymentMetaData({
    this.paymentMethod,
    this.paymentStatus,
    this.paymentReference,
    this.paymentReferenceFile,
    this.payerID,
    this.paidAmount,
    this.paidCurrency,
    this.walletDeduction,
    this.paymentDate,
    this.invoiceNumber,
    this.paymentStructure,
    this.payerEmailID,
    this.conversionRate,
    this.conversionAmount,
    this.conversionCurrency,
    this.actualAmount,
    this.actualCurrency,
  });

  PaymentMetaData.fromJson(Map<String, dynamic> json) {
    paymentMethod = json['paymentMethod'] as String?;
    paymentStatus = json['paymentStatus'] as String?;
    paymentReference = json['paymentReference'] as String?;
    paymentReferenceFile = json['paymentReferenceFile'] as String?;
    payerID = json['payerID'] as String?;
    paidAmount = json['paidAmount'] as double?;
    paidCurrency = json['paidCurrency'] as String?;
    walletDeduction = json['walletDeduction'] as double?;
    paymentDate = json['paymentDate'] as String?;
    invoiceNumber = json['invoiceNumber'] as String?;
    paymentStructure = json['paymentStructure'] as String?;
    payerEmailID = json['payerEmailID'] as String?;
    conversionRate = json['conversionRate'] as double?;
    conversionAmount = json['conversionAmount'] as double?;
    conversionCurrency = json['conversionCurrency'] as String?;
    actualAmount = json['actualAmount'] as double?;
    actualCurrency = json['actualCurrency'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['paymentMethod'] = paymentMethod;
    json['paymentStatus'] = paymentStatus;
    json['paymentReference'] = paymentReference;
    json['paymentReferenceFile'] = paymentReferenceFile;
    json['payerID'] = payerID;
    json['paidAmount'] = paidAmount;
    json['paidCurrency'] = paidCurrency;
    json['walletDeduction'] = walletDeduction;
    json['paymentDate'] = paymentDate;
    json['invoiceNumber'] = invoiceNumber;
    json['paymentStructure'] = paymentStructure;
    json['payerEmailID'] = payerEmailID;
    json['conversionRate'] = conversionRate;
    json['conversionAmount'] = conversionAmount;
    json['conversionCurrency'] = conversionCurrency;
    json['actualAmount'] = actualAmount;
    json['actualCurrency'] = actualCurrency;
    return json;
  }
}

class OrderStatusMetaData {
  int? orderStatusID;
  String? orderStatusName;
  String? orderStatusDate;
  String? orderStatusNotes;
  String? invoiceNumber;

  OrderStatusMetaData({
    this.orderStatusID,
    this.orderStatusName,
    this.orderStatusDate,
    this.orderStatusNotes,
    this.invoiceNumber,
  });

  OrderStatusMetaData.fromJson(Map<String, dynamic> json) {
    orderStatusID = json['orderStatusID'] as int?;
    orderStatusName = json['orderStatusName'] as String?;
    orderStatusDate = json['orderStatusDate'] as String?;
    orderStatusNotes = json['orderStatusNotes'] as String?;
    invoiceNumber = json['invoiceNumber'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['orderStatusID'] = orderStatusID;
    json['orderStatusName'] = orderStatusName;
    json['orderStatusDate'] = orderStatusDate;
    json['orderStatusNotes'] = orderStatusNotes;
    json['invoiceNumber'] = invoiceNumber;
    return json;
  }
}

class SummaryOrderMetaData {
  String? baseCurrency;
  String? currency;
  double? itemTotal;
  double? itemQtyTotal;
  double? variationTotal;
  double? variationQtyTotal;
  double? chargesTotal;
  double? chargesQtyTotal;
  double? saleChargesTotal;
  double? saleChargesQtyTotal;
  double? shippingCost;
  double? shippingQtyCost;
  double? walletAmount;
  double? couponAmount;
  double? discountAmount;
  double? total;
  double? totalQty;
  double? grandTotal;
  double? commission;
  double? conversionRate;
  double? baseGrandTotal;

  SummaryOrderMetaData({
    this.baseCurrency,
    this.currency,
    this.itemTotal,
    this.itemQtyTotal,
    this.variationTotal,
    this.variationQtyTotal,
    this.chargesTotal,
    this.chargesQtyTotal,
    this.saleChargesTotal,
    this.saleChargesQtyTotal,
    this.shippingCost,
    this.shippingQtyCost,
    this.walletAmount,
    this.couponAmount,
    this.discountAmount,
    this.total,
    this.totalQty,
    this.grandTotal,
    this.commission,
    this.conversionRate,
    this.baseGrandTotal,
  });

  SummaryOrderMetaData.fromJson(Map<String, dynamic> json) {
    baseCurrency = json['baseCurrency'] as String?;
    currency = json['currency'] as String?;
    itemTotal = json['itemTotal'] as double?;
    itemQtyTotal = json['itemQtyTotal'] as double?;
    variationTotal = json['variationTotal'] as double?;
    variationQtyTotal = json['variationQtyTotal'] as double?;
    chargesTotal = json['chargesTotal'] as double?;
    chargesQtyTotal = json['chargesQtyTotal'] as double?;
    saleChargesTotal = json['saleChargesTotal'] as double?;
    saleChargesQtyTotal = json['saleChargesQtyTotal'] as double?;
    shippingCost = json['shippingCost'] as double?;
    shippingQtyCost = json['shippingQtyCost'] as double?;
    walletAmount = json['walletAmount'] as double?;
    couponAmount = json['couponAmount'] as double?;
    discountAmount = json['discountAmount'] as double?;
    total = json['total'] as double?;
    totalQty = json['totalQty'] as double?;
    grandTotal = json['grandTotal'] as double?;
    commission = json['commission'] as double?;
    conversionRate = json['conversionRate'] as double?;
    baseGrandTotal = json['baseGrandTotal'] as double?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['baseCurrency'] = baseCurrency;
    json['currency'] = currency;
    json['itemTotal'] = itemTotal;
    json['itemQtyTotal'] = itemQtyTotal;
    json['variationTotal'] = variationTotal;
    json['variationQtyTotal'] = variationQtyTotal;
    json['chargesTotal'] = chargesTotal;
    json['chargesQtyTotal'] = chargesQtyTotal;
    json['saleChargesTotal'] = saleChargesTotal;
    json['saleChargesQtyTotal'] = saleChargesQtyTotal;
    json['shippingCost'] = shippingCost;
    json['shippingQtyCost'] = shippingQtyCost;
    json['walletAmount'] = walletAmount;
    json['couponAmount'] = couponAmount;
    json['discountAmount'] = discountAmount;
    json['total'] = total;
    json['totalQty'] = totalQty;
    json['grandTotal'] = grandTotal;
    json['commission'] = commission;
    json['conversionRate'] = conversionRate;
    json['baseGrandTotal'] = baseGrandTotal;
    return json;
  }
}

class ShippingDetailMetaData {
  String? fullName;
  String? addressType;
  String? shippingAddress;
  String? shippingEmail;
  String? shippingPhone;
  String? shippingLatitude;
  String? shippingLongitude;
  String? nearestLandMark;

  ShippingDetailMetaData({
    this.fullName,
    this.addressType,
    this.shippingAddress,
    this.shippingEmail,
    this.shippingPhone,
    this.shippingLatitude,
    this.shippingLongitude,
    this.nearestLandMark,
  });

  ShippingDetailMetaData.fromJson(Map<String, dynamic> json) {
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

class SellerViewModel {
  String? sellerCoverImage;
  dynamic sellerVideoURl;
  int? productTotal;
  dynamic salesAmountTotal;
  int? salesQtyTotal;
  dynamic salesActualCurrency;
  dynamic customerTotal;
  dynamic purchaseAmountTotal;
  int? purchaseQtyTotal;
  dynamic purchaseConversionCurrency;
  dynamic businessType;
  String? businessName;
  String? businessUrlpath;
  dynamic businessDescription;
  dynamic businessMetaData;
  dynamic sellerAvailability;
  int? profileId;
  String? profileGuid;
  String? loginChannel;
  String? loginName;
  String? type;
  String? displayname;
  String? firstName;
  String? lastName;
  dynamic dateofbirth;
  dynamic gender;
  String? image;
  String? insertDate;
  dynamic about;
  String? contact;
  String? email;
  String? address;
  dynamic latitude;
  dynamic longitude;
  dynamic currentTime;
  dynamic primaryaddressViewModel;
  Userothermetadata? userothermetadata;
  dynamic sellerviewmodel;
  dynamic clientmodel;
  dynamic creditPurchaseModel;
  dynamic subscriptionPurchaseModel;

  SellerViewModel({
    this.sellerCoverImage,
    this.sellerVideoURl,
    this.productTotal,
    this.salesAmountTotal,
    this.salesQtyTotal,
    this.salesActualCurrency,
    this.customerTotal,
    this.purchaseAmountTotal,
    this.purchaseQtyTotal,
    this.purchaseConversionCurrency,
    this.businessType,
    this.businessName,
    this.businessUrlpath,
    this.businessDescription,
    this.businessMetaData,
    this.sellerAvailability,
    this.profileId,
    this.profileGuid,
    this.loginChannel,
    this.loginName,
    this.type,
    this.displayname,
    this.firstName,
    this.lastName,
    this.dateofbirth,
    this.gender,
    this.image,
    this.insertDate,
    this.about,
    this.contact,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.currentTime,
    this.primaryaddressViewModel,
    this.userothermetadata,
    this.sellerviewmodel,
    this.clientmodel,
    this.creditPurchaseModel,
    this.subscriptionPurchaseModel,
  });

  SellerViewModel.fromJson(Map<String, dynamic> json) {
    sellerCoverImage = json['sellerCoverImage'] as String?;
    sellerVideoURl = json['sellerVideoURl'];
    productTotal = json['productTotal'] as int?;
    salesAmountTotal = json['salesAmountTotal'];
    salesQtyTotal = json['salesQtyTotal'] as int?;
    salesActualCurrency = json['salesActualCurrency'];
    customerTotal = json['customerTotal'];
    purchaseAmountTotal = json['purchaseAmountTotal'];
    purchaseQtyTotal = json['purchaseQtyTotal'] as int?;
    purchaseConversionCurrency = json['purchaseConversionCurrency'];
    businessType = json['businessType'];
    businessName = json['businessName'] as String?;
    businessUrlpath = json['businessUrlpath'] as String?;
    businessDescription = json['businessDescription'];
    businessMetaData = json['businessMetaData'];
    sellerAvailability = json['sellerAvailability'];
    profileId = json['profileId'] as int?;
    profileGuid = json['profileGuid'] as String?;
    loginChannel = json['loginChannel'] as String?;
    loginName = json['loginName'] as String?;
    type = json['type'] as String?;
    displayname = json['displayname'] as String?;
    firstName = json['firstName'] as String?;
    lastName = json['lastName'] as String?;
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
    image = json['image'] as String?;
    insertDate = json['insertDate'] as String?;
    about = json['about'];
    contact = json['contact'] as String?;
    email = json['email'] as String?;
    address = json['address'] as String?;
    latitude = json['latitude'];
    longitude = json['longitude'];
    currentTime = json['currentTime'];
    primaryaddressViewModel = json['primaryaddressViewModel'];
    userothermetadata =
        (json['userothermetadata'] as Map<String, dynamic>?) != null
            ? Userothermetadata.fromJson(
                json['userothermetadata'] as Map<String, dynamic>)
            : null;
    sellerviewmodel = json['sellerviewmodel'];
    clientmodel = json['clientmodel'];
    creditPurchaseModel = json['creditPurchaseModel'];
    subscriptionPurchaseModel = json['subscriptionPurchaseModel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['sellerCoverImage'] = sellerCoverImage;
    json['sellerVideoURl'] = sellerVideoURl;
    json['productTotal'] = productTotal;
    json['salesAmountTotal'] = salesAmountTotal;
    json['salesQtyTotal'] = salesQtyTotal;
    json['salesActualCurrency'] = salesActualCurrency;
    json['customerTotal'] = customerTotal;
    json['purchaseAmountTotal'] = purchaseAmountTotal;
    json['purchaseQtyTotal'] = purchaseQtyTotal;
    json['purchaseConversionCurrency'] = purchaseConversionCurrency;
    json['businessType'] = businessType;
    json['businessName'] = businessName;
    json['businessUrlpath'] = businessUrlpath;
    json['businessDescription'] = businessDescription;
    json['businessMetaData'] = businessMetaData;
    json['sellerAvailability'] = sellerAvailability;
    json['profileId'] = profileId;
    json['profileGuid'] = profileGuid;
    json['loginChannel'] = loginChannel;
    json['loginName'] = loginName;
    json['type'] = type;
    json['displayname'] = displayname;
    json['firstName'] = firstName;
    json['lastName'] = lastName;
    json['dateofbirth'] = dateofbirth;
    json['gender'] = gender;
    json['image'] = image;
    json['insertDate'] = insertDate;
    json['about'] = about;
    json['contact'] = contact;
    json['email'] = email;
    json['address'] = address;
    json['latitude'] = latitude;
    json['longitude'] = longitude;
    json['currentTime'] = currentTime;
    json['primaryaddressViewModel'] = primaryaddressViewModel;
    json['userothermetadata'] = userothermetadata?.toJson();
    json['sellerviewmodel'] = sellerviewmodel;
    json['clientmodel'] = clientmodel;
    json['creditPurchaseModel'] = creditPurchaseModel;
    json['subscriptionPurchaseModel'] = subscriptionPurchaseModel;
    return json;
  }
}

class Userothermetadata {
  String? ip;
  String? country;
  int? following;
  int? followers;
  int? totalReviewsAsBuyer;
  int? totalReviewsAsSeller;
  double? buyerRating;
  double? sellerRating;
  String? lastSeen;
  String? sellerLevelName;
  String? buyerLevelName;
  List<UserAgentMetaData>? userAgentMetaData;
  dynamic userInactiveMetaData;

  Userothermetadata({
    this.ip,
    this.country,
    this.following,
    this.followers,
    this.totalReviewsAsBuyer,
    this.totalReviewsAsSeller,
    this.buyerRating,
    this.sellerRating,
    this.lastSeen,
    this.sellerLevelName,
    this.buyerLevelName,
    this.userAgentMetaData,
    this.userInactiveMetaData,
  });

  Userothermetadata.fromJson(Map<String, dynamic> json) {
    ip = json['ip'] as String?;
    country = json['country'] as String?;
    following = json['following'] as int?;
    followers = json['followers'] as int?;
    totalReviewsAsBuyer = json['totalReviewsAsBuyer'] as int?;
    totalReviewsAsSeller = json['totalReviewsAsSeller'] as int?;
    buyerRating = json['buyerRating'] as double?;
    sellerRating = json['sellerRating'] as double?;
    lastSeen = json['lastSeen'] as String?;
    sellerLevelName = json['sellerLevelName'] as String?;
    buyerLevelName = json['buyerLevelName'] as String?;
    userAgentMetaData = (json['userAgentMetaData'] as List?)
        ?.map((dynamic e) =>
            UserAgentMetaData.fromJson(e as Map<String, dynamic>))
        .toList();
    userInactiveMetaData = json['userInactiveMetaData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['ip'] = ip;
    json['country'] = country;
    json['following'] = following;
    json['followers'] = followers;
    json['totalReviewsAsBuyer'] = totalReviewsAsBuyer;
    json['totalReviewsAsSeller'] = totalReviewsAsSeller;
    json['buyerRating'] = buyerRating;
    json['sellerRating'] = sellerRating;
    json['lastSeen'] = lastSeen;
    json['sellerLevelName'] = sellerLevelName;
    json['buyerLevelName'] = buyerLevelName;
    json['userAgentMetaData'] =
        userAgentMetaData?.map((e) => e.toJson()).toList();
    json['userInactiveMetaData'] = userInactiveMetaData;
    return json;
  }
}

class UserAgentMetaData {
  String? browser;
  String? browserVersion;
  String? operatingSystem;
  dynamic brand;
  dynamic model;
  String? ip;
  String? deviceType;
  String? dateTime;

  UserAgentMetaData({
    this.browser,
    this.browserVersion,
    this.operatingSystem,
    this.brand,
    this.model,
    this.ip,
    this.deviceType,
    this.dateTime,
  });

  UserAgentMetaData.fromJson(Map<String, dynamic> json) {
    browser = json['browser'] as String?;
    browserVersion = json['browserVersion'] as String?;
    operatingSystem = json['operatingSystem'] as String?;
    brand = json['brand'];
    model = json['model'];
    ip = json['ip'] as String?;
    deviceType = json['deviceType'] as String?;
    dateTime = json['dateTime'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['browser'] = browser;
    json['browserVersion'] = browserVersion;
    json['operatingSystem'] = operatingSystem;
    json['brand'] = brand;
    json['model'] = model;
    json['ip'] = ip;
    json['deviceType'] = deviceType;
    json['dateTime'] = dateTime;
    return json;
  }
}

class BuyerViewModel {
  double? purchaseAmountTotal;
  int? purchaseQtyTotal;
  int? wishListTotal;
  int? followingSeller;
  dynamic customerAddresses;
  int? profileId;
  String? profileGuid;
  String? loginChannel;
  String? loginName;
  String? type;
  String? displayname;
  String? firstName;
  String? lastName;
  dynamic dateofbirth;
  dynamic gender;
  String? image;
  String? insertDate;
  dynamic about;
  dynamic contact;
  String? email;
  dynamic address;
  dynamic latitude;
  dynamic longitude;
  dynamic currentTime;
  dynamic primaryaddressViewModel;
  Userothermetadata? userothermetadata;
  dynamic sellerviewmodel;
  dynamic clientmodel;
  dynamic creditPurchaseModel;
  dynamic subscriptionPurchaseModel;

  BuyerViewModel({
    this.purchaseAmountTotal,
    this.purchaseQtyTotal,
    this.wishListTotal,
    this.followingSeller,
    this.customerAddresses,
    this.profileId,
    this.profileGuid,
    this.loginChannel,
    this.loginName,
    this.type,
    this.displayname,
    this.firstName,
    this.lastName,
    this.dateofbirth,
    this.gender,
    this.image,
    this.insertDate,
    this.about,
    this.contact,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.currentTime,
    this.primaryaddressViewModel,
    this.userothermetadata,
    this.sellerviewmodel,
    this.clientmodel,
    this.creditPurchaseModel,
    this.subscriptionPurchaseModel,
  });

  BuyerViewModel.fromJson(Map<String, dynamic> json) {
    purchaseAmountTotal = json['purchaseAmountTotal'] as double?;
    purchaseQtyTotal = json['purchaseQtyTotal'] as int?;
    wishListTotal = json['wishListTotal'] as int?;
    followingSeller = json['followingSeller'] as int?;
    customerAddresses = json['customerAddresses'];
    profileId = json['profileId'] as int?;
    profileGuid = json['profileGuid'] as String?;
    loginChannel = json['loginChannel'] as String?;
    loginName = json['loginName'] as String?;
    type = json['type'] as String?;
    displayname = json['displayname'] as String?;
    firstName = json['firstName'] as String?;
    lastName = json['lastName'] as String?;
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
    image = json['image'] as String?;
    insertDate = json['insertDate'] as String?;
    about = json['about'];
    contact = json['contact'];
    email = json['email'] as String?;
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    currentTime = json['currentTime'];
    primaryaddressViewModel = json['primaryaddressViewModel'];
    userothermetadata =
        (json['userothermetadata'] as Map<String, dynamic>?) != null
            ? Userothermetadata.fromJson(
                json['userothermetadata'] as Map<String, dynamic>)
            : null;
    sellerviewmodel = json['sellerviewmodel'];
    clientmodel = json['clientmodel'];
    creditPurchaseModel = json['creditPurchaseModel'];
    subscriptionPurchaseModel = json['subscriptionPurchaseModel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['purchaseAmountTotal'] = purchaseAmountTotal;
    json['purchaseQtyTotal'] = purchaseQtyTotal;
    json['wishListTotal'] = wishListTotal;
    json['followingSeller'] = followingSeller;
    json['customerAddresses'] = customerAddresses;
    json['profileId'] = profileId;
    json['profileGuid'] = profileGuid;
    json['loginChannel'] = loginChannel;
    json['loginName'] = loginName;
    json['type'] = type;
    json['displayname'] = displayname;
    json['firstName'] = firstName;
    json['lastName'] = lastName;
    json['dateofbirth'] = dateofbirth;
    json['gender'] = gender;
    json['image'] = image;
    json['insertDate'] = insertDate;
    json['about'] = about;
    json['contact'] = contact;
    json['email'] = email;
    json['address'] = address;
    json['latitude'] = latitude;
    json['longitude'] = longitude;
    json['currentTime'] = currentTime;
    json['primaryaddressViewModel'] = primaryaddressViewModel;
    json['userothermetadata'] = userothermetadata?.toJson();
    json['sellerviewmodel'] = sellerviewmodel;
    json['clientmodel'] = clientmodel;
    json['creditPurchaseModel'] = creditPurchaseModel;
    json['subscriptionPurchaseModel'] = subscriptionPurchaseModel;
    return json;
  }
}
