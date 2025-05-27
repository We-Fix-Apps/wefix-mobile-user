import 'package:wefix/Data/model/all_products_model.dart';

class ShopsDeatilsModel {
  Seller? seller;
  List<AllProducts>? product;

  ShopsDeatilsModel({
    this.seller,
    this.product,
  });

  ShopsDeatilsModel.fromJson(Map<String, dynamic> json) {
    seller = (json['seller'] as Map<String, dynamic>?) != null
        ? Seller.fromJson(json['seller'] as Map<String, dynamic>)
        : null;
    product = (json['product'] as List?)
        ?.map((dynamic e) => AllProducts.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['seller'] = seller?.toJson();
    json['product'] = product?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Seller {
  int? profileId;
  String? profileGuid;
  String? displayname;
  dynamic about;
  String? contact;
  String? email;
  String? firstName;
  String? lastName;
  String? address;
  String? image;
  String? sellerCoverImage;
  dynamic sellerVideoURl;
  dynamic businessType;
  String? businessName;
  String? businessUrlpath;
  dynamic businessDescription;
  int? productTotal;
  Userothermetadata? userothermetadata;
  String? primaryaddressViewModel;
  dynamic businessMetaData;
  String? sellerAvailability;

  Seller({
    this.profileId,
    this.profileGuid,
    this.displayname,
    this.about,
    this.contact,
    this.email,
    this.firstName,
    this.lastName,
    this.address,
    this.image,
    this.sellerCoverImage,
    this.sellerVideoURl,
    this.businessType,
    this.businessName,
    this.businessUrlpath,
    this.businessDescription,
    this.productTotal,
    this.userothermetadata,
    this.primaryaddressViewModel,
    this.businessMetaData,
    this.sellerAvailability,
  });

  Seller.fromJson(Map<String, dynamic> json) {
    profileId = json['profileId'] as int?;
    profileGuid = json['profileGuid'] as String?;
    displayname = json['displayname'] as String?;
    about = json['about'];
    contact = json['contact'] as String?;
    email = json['email'] as String?;
    firstName = json['firstName'] as String?;
    lastName = json['lastName'] as String?;
    address = json['address'] as String?;
    image = json['image'] as String?;
    sellerCoverImage = json['sellerCoverImage'] as String?;
    sellerVideoURl = json['sellerVideoURl'];
    businessType = json['businessType'];
    businessName = json['businessName'] as String?;
    businessUrlpath = json['businessUrlpath'] as String?;
    businessDescription = json['businessDescription'];
    productTotal = json['productTotal'] as int?;
    userothermetadata =
        (json['userothermetadata'] as Map<String, dynamic>?) != null
            ? Userothermetadata.fromJson(
                json['userothermetadata'] as Map<String, dynamic>)
            : null;
    primaryaddressViewModel = json['primaryaddressViewModel'] as String?;
    businessMetaData = json['businessMetaData'];
    sellerAvailability = json['sellerAvailability'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['profileId'] = profileId;
    json['profileGuid'] = profileGuid;
    json['displayname'] = displayname;
    json['about'] = about;
    json['contact'] = contact;
    json['email'] = email;
    json['firstName'] = firstName;
    json['lastName'] = lastName;
    json['address'] = address;
    json['image'] = image;
    json['sellerCoverImage'] = sellerCoverImage;
    json['sellerVideoURl'] = sellerVideoURl;
    json['businessType'] = businessType;
    json['businessName'] = businessName;
    json['businessUrlpath'] = businessUrlpath;
    json['businessDescription'] = businessDescription;
    json['productTotal'] = productTotal;
    json['userothermetadata'] = userothermetadata?.toJson();
    json['primaryaddressViewModel'] = primaryaddressViewModel;
    json['businessMetaData'] = businessMetaData;
    json['sellerAvailability'] = sellerAvailability;
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

class ProductBasicMetaData {
  int? sellingTypeID;
  int? listingTypeID;
  String? name;
  String? seourl;
  String? shortDescription;
  int? currencyId;
  double? price;
  String? image;
  String? productCategoryArray;
  String? unit;
  String? brand;
  String? seoMetaTitle;
  String? seoKeywords;
  String? seoMetadescription;

  ProductBasicMetaData({
    this.sellingTypeID,
    this.listingTypeID,
    this.name,
    this.seourl,
    this.shortDescription,
    this.currencyId,
    this.price,
    this.image,
    this.productCategoryArray,
    this.unit,
    this.brand,
    this.seoMetaTitle,
    this.seoKeywords,
    this.seoMetadescription,
  });

  ProductBasicMetaData.fromJson(Map<String, dynamic> json) {
    sellingTypeID = json['sellingTypeID'] as int?;
    listingTypeID = json['listingTypeID'] as int?;
    name = json['name'] as String?;
    seourl = json['seourl'] as String?;
    shortDescription = json['shortDescription'] as String?;
    currencyId = json['currencyId'] as int?;
    price = json['price'] as double?;
    image = json['image'] as String?;
    productCategoryArray = json['productCategoryArray'] as String?;
    unit = json['unit'] as String?;
    brand = json['brand'] as String?;
    seoMetaTitle = json['seoMetaTitle'] as String?;
    seoKeywords = json['seoKeywords'] as String?;
    seoMetadescription = json['seoMetadescription'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['sellingTypeID'] = sellingTypeID;
    json['listingTypeID'] = listingTypeID;
    json['name'] = name;
    json['seourl'] = seourl;
    json['shortDescription'] = shortDescription;
    json['currencyId'] = currencyId;
    json['price'] = price;
    json['image'] = image;
    json['productCategoryArray'] = productCategoryArray;
    json['unit'] = unit;
    json['brand'] = brand;
    json['seoMetaTitle'] = seoMetaTitle;
    json['seoKeywords'] = seoKeywords;
    json['seoMetadescription'] = seoMetadescription;
    return json;
  }
}

class ProductDetailMetaData {
  String? detailDescription;

  ProductDetailMetaData({
    this.detailDescription,
  });

  ProductDetailMetaData.fromJson(Map<String, dynamic> json) {
    detailDescription = json['detailDescription'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['detailDescription'] = detailDescription;
    return json;
  }
}

class ProductShippingMetaData {
  bool? isFreeShipping;
  dynamic shippingWeight;
  dynamic shippingLength;
  dynamic shippingWidth;
  dynamic shippingHeight;
  double? shippingAddOnCharges;

  ProductShippingMetaData({
    this.isFreeShipping,
    this.shippingWeight,
    this.shippingLength,
    this.shippingWidth,
    this.shippingHeight,
    this.shippingAddOnCharges,
  });

  ProductShippingMetaData.fromJson(Map<String, dynamic> json) {
    isFreeShipping = json['isFreeShipping'] as bool?;
    shippingWeight = json['shippingWeight'];
    shippingLength = json['shippingLength'];
    shippingWidth = json['shippingWidth'];
    shippingHeight = json['shippingHeight'];
    shippingAddOnCharges = json['shippingAddOnCharges'] as double?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['isFreeShipping'] = isFreeShipping;
    json['shippingWeight'] = shippingWeight;
    json['shippingLength'] = shippingLength;
    json['shippingWidth'] = shippingWidth;
    json['shippingHeight'] = shippingHeight;
    json['shippingAddOnCharges'] = shippingAddOnCharges;
    return json;
  }
}
