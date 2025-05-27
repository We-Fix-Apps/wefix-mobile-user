class WishListModel {
  String? profileguid;
  int? profileId;
  String? shopurlpath;
  int? productId;
  String? productGUID;
  String? productSeourl;
  String? productImage;
  dynamic produtAltText;
  String? productName;
  dynamic productUnit;
  String? brandName;
  String? sku;
  dynamic eanCode;
  String? shortDescription;
  dynamic detailDescription;
  dynamic returnPolicy;
  dynamic cancelPolicy;
  bool? isOutofStock;
  bool? isVideo;
  dynamic listofVideo;
  bool? isManagedInventory;
  int? minQty;
  int? maxQty;
  String? currency;
  double? price;
  double? actualPrice;
  int? actualCurrency;
  bool? isDiscounted;
  double? discountAmount;
  double? priceBeforeDiscount;
  String? insertdate;
  bool? ispublish;
  String? itemaddress;
  String? itemcontact;
  String? itememail;
  int? generalSetupId;
  String? listingType;
  String? sellingType;
  dynamic wishlistgroupname;
  int? isAttributeExist;
  dynamic productList;
  dynamic productDetail;
  dynamic productAttributeViewModel;
  dynamic productShippingMetaData;
  List<ListofImages>? listofImages;
  String? categoryarrary;
  List<ListProductCategoryMetaData>? listProductCategoryMetaData;
  int? categoryId;
  dynamic categoryName;
  dynamic amenityViewModel;
  List<dynamic>? listAmenityMetaData;
  dynamic productAmenityHeader;
  dynamic productAmenityChild;
  dynamic amenitiesHeader;
  int? amenitiesid;
  dynamic amenitiesOptionName;
  dynamic amenitiesIcon;
  int? optionAmenityId;
  int? totalorders;
  bool? loginuserfavorite;
  int? favorite;
  int? comparisionExist;
  Userothermetadata? userothermetadata;
  dynamic itemothermetadata;
  dynamic itemdigitalmetadata;

  WishListModel({
    this.profileguid,
    this.profileId,
    this.shopurlpath,
    this.productId,
    this.productGUID,
    this.productSeourl,
    this.productImage,
    this.produtAltText,
    this.productName,
    this.productUnit,
    this.brandName,
    this.sku,
    this.eanCode,
    this.shortDescription,
    this.detailDescription,
    this.returnPolicy,
    this.cancelPolicy,
    this.isOutofStock,
    this.isVideo,
    this.listofVideo,
    this.isManagedInventory,
    this.minQty,
    this.maxQty,
    this.currency,
    this.price,
    this.actualPrice,
    this.actualCurrency,
    this.isDiscounted,
    this.discountAmount,
    this.priceBeforeDiscount,
    this.insertdate,
    this.ispublish,
    this.itemaddress,
    this.itemcontact,
    this.itememail,
    this.generalSetupId,
    this.listingType,
    this.sellingType,
    this.wishlistgroupname,
    this.isAttributeExist,
    this.productList,
    this.productDetail,
    this.productAttributeViewModel,
    this.productShippingMetaData,
    this.listofImages,
    this.categoryarrary,
    this.listProductCategoryMetaData,
    this.categoryId,
    this.categoryName,
    this.amenityViewModel,
    this.listAmenityMetaData,
    this.productAmenityHeader,
    this.productAmenityChild,
    this.amenitiesHeader,
    this.amenitiesid,
    this.amenitiesOptionName,
    this.amenitiesIcon,
    this.optionAmenityId,
    this.totalorders,
    this.loginuserfavorite,
    this.favorite,
    this.comparisionExist,
    this.userothermetadata,
    this.itemothermetadata,
    this.itemdigitalmetadata,
  });

  WishListModel.fromJson(Map<String, dynamic> json) {
    profileguid = json['profileguid'] as String?;
    profileId = json['profileId'] as int?;
    shopurlpath = json['shopurlpath'] as String?;
    productId = json['productId'] as int?;
    productGUID = json['productGUID'] as String?;
    productSeourl = json['productSeourl'] as String?;
    productImage = json['productImage'] as String?;
    produtAltText = json['produtAltText'];
    productName = json['productName'] as String?;
    productUnit = json['productUnit'];
    brandName = json['brandName'] as String?;
    sku = json['sku'] as String?;
    eanCode = json['eanCode'];
    shortDescription = json['shortDescription'] as String?;
    detailDescription = json['detailDescription'];
    returnPolicy = json['returnPolicy'];
    cancelPolicy = json['cancelPolicy'];
    isOutofStock = json['isOutofStock'] as bool?;
    isVideo = json['isVideo'] as bool?;
    listofVideo = json['listofVideo'];
    isManagedInventory = json['isManagedInventory'] as bool?;
    minQty = json['minQty'] as int?;
    maxQty = json['maxQty'] as int?;
    currency = json['currency'] as String?;
    price = json['price'] as double?;
    actualPrice = json['actualPrice'] as double?;
    actualCurrency = json['actualCurrency'] as int?;
    isDiscounted = json['isDiscounted'] as bool?;
    discountAmount = json['discountAmount'] as double?;
    priceBeforeDiscount = json['priceBeforeDiscount'] as double?;
    insertdate = json['insertdate'] as String?;
    ispublish = json['ispublish'] as bool?;
    itemaddress = json['itemaddress'] as String?;
    itemcontact = json['itemcontact'] as String?;
    itememail = json['itememail'] as String?;
    generalSetupId = json['generalSetupId'] as int?;
    listingType = json['listingType'] as String?;
    sellingType = json['sellingType'] as String?;
    wishlistgroupname = json['wishlistgroupname'];
    isAttributeExist = json['isAttributeExist'] as int?;
    productList = json['productList'];
    productDetail = json['productDetail'];
    productAttributeViewModel = json['productAttributeViewModel'];
    productShippingMetaData = json['productShippingMetaData'];
    listofImages = (json['listofImages'] as List?)
        ?.map((dynamic e) => ListofImages.fromJson(e as Map<String, dynamic>))
        .toList();
    categoryarrary = json['categoryarrary'] as String?;
    listProductCategoryMetaData = (json['listProductCategoryMetaData'] as List?)
        ?.map((dynamic e) =>
            ListProductCategoryMetaData.fromJson(e as Map<String, dynamic>))
        .toList();
    categoryId = json['categoryId'] as int?;
    categoryName = json['categoryName'];
    amenityViewModel = json['amenityViewModel'];
    listAmenityMetaData = json['listAmenityMetaData'] as List?;
    productAmenityHeader = json['productAmenityHeader'];
    productAmenityChild = json['productAmenityChild'];
    amenitiesHeader = json['amenitiesHeader'];
    amenitiesid = json['amenitiesid'] as int?;
    amenitiesOptionName = json['amenitiesOptionName'];
    amenitiesIcon = json['amenitiesIcon'];
    optionAmenityId = json['optionAmenityId'] as int?;
    totalorders = json['totalorders'] as int?;
    loginuserfavorite = json['loginuserfavorite'] as bool?;
    favorite = json['favorite'] as int?;
    comparisionExist = json['comparisionExist'] as int?;
    userothermetadata =
        (json['userothermetadata'] as Map<String, dynamic>?) != null
            ? Userothermetadata.fromJson(
                json['userothermetadata'] as Map<String, dynamic>)
            : null;
    itemothermetadata = json['itemothermetadata'];
    itemdigitalmetadata = json['itemdigitalmetadata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['profileguid'] = profileguid;
    json['profileId'] = profileId;
    json['shopurlpath'] = shopurlpath;
    json['productId'] = productId;
    json['productGUID'] = productGUID;
    json['productSeourl'] = productSeourl;
    json['productImage'] = productImage;
    json['produtAltText'] = produtAltText;
    json['productName'] = productName;
    json['productUnit'] = productUnit;
    json['brandName'] = brandName;
    json['sku'] = sku;
    json['eanCode'] = eanCode;
    json['shortDescription'] = shortDescription;
    json['detailDescription'] = detailDescription;
    json['returnPolicy'] = returnPolicy;
    json['cancelPolicy'] = cancelPolicy;
    json['isOutofStock'] = isOutofStock;
    json['isVideo'] = isVideo;
    json['listofVideo'] = listofVideo;
    json['isManagedInventory'] = isManagedInventory;
    json['minQty'] = minQty;
    json['maxQty'] = maxQty;
    json['currency'] = currency;
    json['price'] = price;
    json['actualPrice'] = actualPrice;
    json['actualCurrency'] = actualCurrency;
    json['isDiscounted'] = isDiscounted;
    json['discountAmount'] = discountAmount;
    json['priceBeforeDiscount'] = priceBeforeDiscount;
    json['insertdate'] = insertdate;
    json['ispublish'] = ispublish;
    json['itemaddress'] = itemaddress;
    json['itemcontact'] = itemcontact;
    json['itememail'] = itememail;
    json['generalSetupId'] = generalSetupId;
    json['listingType'] = listingType;
    json['sellingType'] = sellingType;
    json['wishlistgroupname'] = wishlistgroupname;
    json['isAttributeExist'] = isAttributeExist;
    json['productList'] = productList;
    json['productDetail'] = productDetail;
    json['productAttributeViewModel'] = productAttributeViewModel;
    json['productShippingMetaData'] = productShippingMetaData;
    json['listofImages'] = listofImages?.map((e) => e.toJson()).toList();
    json['categoryarrary'] = categoryarrary;
    json['listProductCategoryMetaData'] =
        listProductCategoryMetaData?.map((e) => e.toJson()).toList();
    json['categoryId'] = categoryId;
    json['categoryName'] = categoryName;
    json['amenityViewModel'] = amenityViewModel;
    json['listAmenityMetaData'] = listAmenityMetaData;
    json['productAmenityHeader'] = productAmenityHeader;
    json['productAmenityChild'] = productAmenityChild;
    json['amenitiesHeader'] = amenitiesHeader;
    json['amenitiesid'] = amenitiesid;
    json['amenitiesOptionName'] = amenitiesOptionName;
    json['amenitiesIcon'] = amenitiesIcon;
    json['optionAmenityId'] = optionAmenityId;
    json['totalorders'] = totalorders;
    json['loginuserfavorite'] = loginuserfavorite;
    json['favorite'] = favorite;
    json['comparisionExist'] = comparisionExist;
    json['userothermetadata'] = userothermetadata?.toJson();
    json['itemothermetadata'] = itemothermetadata;
    json['itemdigitalmetadata'] = itemdigitalmetadata;
    return json;
  }
}

class ListofImages {
  int? id;
  String? image;
  dynamic poster;
  String? source;

  ListofImages({
    this.id,
    this.image,
    this.poster,
    this.source,
  });

  ListofImages.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    image = json['image'] as String?;
    poster = json['poster'];
    source = json['source'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['image'] = image;
    json['poster'] = poster;
    json['source'] = source;
    return json;
  }
}

class ListProductCategoryMetaData {
  int? id;
  int? categoryId;
  String? categoryName;

  ListProductCategoryMetaData({
    this.id,
    this.categoryId,
    this.categoryName,
  });

  ListProductCategoryMetaData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    categoryId = json['categoryId'] as int?;
    categoryName = json['categoryName'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['categoryId'] = categoryId;
    json['categoryName'] = categoryName;
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
