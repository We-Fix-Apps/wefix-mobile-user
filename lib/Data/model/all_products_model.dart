// class AllProductsModel {
//   final List<AllProducts>? allProducts;
//   final int? pagecount;
//   AllProductsModel({
//     this.pagecount,
//     this.allProducts,
//   });

//   AllProductsModel.fromJson(Map<String, dynamic> json)
//       : allProducts = (json['productmodel'] as List?)
//             ?.map(
//                 (dynamic e) => AllProducts.fromJson(e as Map<String, dynamic>))
//             .toList(),
//         pagecount = json['pagecount'] as int?;
// }

// class AllProducts {
//   final int? id;
//   final String? itemGUID;
//   final String? currency;
//   final int? profileID;
//   final String? insertDate;
//   final bool? isPublish;
//   bool? isFav;
//   bool? favorite;

//   final bool? isDiscounted;
//   final bool? isAdminLocked;
//   final String? imagesMetaData;
//   final dynamic videoMetaData;
//   final dynamic amenityMetaData;
//   final int? isAttributeExist;
//   final ProductBasicMetaData? productBasicMetaData;
//   final ProductDetailMetaData? productDetailMetaData;
//   final dynamic productClassifiedMetaData;
//   final dynamic productDigitalMetaData;
//   final dynamic productRelatedMetaData;
//   final dynamic productAuctionMetaData;
//   final dynamic productPennyAuctionMetaData;
//   final dynamic productPolicyMetaData;
//   final ProductShippingMetaData? productShippingMetaData;
//   final dynamic imageItemMetaDatas;
//   final dynamic productVideoMetaDatas;
//   final dynamic amenityMetaDatas;
//   final dynamic productInventoryMetaData;
//   final dynamic itemOtherMetaData;
//   final dynamic sellerDiscountMetaData;

//   AllProducts({
//     this.id,
//     this.favorite,
//     this.isFav,
//     this.itemGUID,
//     this.profileID,
//     this.insertDate,
//     this.isPublish,
//     this.isAdminLocked,
//     this.imagesMetaData,
//     this.videoMetaData,
//     this.isDiscounted,
//     this.amenityMetaData,
//     this.currency,
//     this.isAttributeExist,
//     this.productBasicMetaData,
//     this.productDetailMetaData,
//     this.productClassifiedMetaData,
//     this.productDigitalMetaData,
//     this.productRelatedMetaData,
//     this.productAuctionMetaData,
//     this.productPennyAuctionMetaData,
//     this.productPolicyMetaData,
//     this.productShippingMetaData,
//     this.imageItemMetaDatas,
//     this.productVideoMetaDatas,
//     this.amenityMetaDatas,
//     this.productInventoryMetaData,
//     this.itemOtherMetaData,
//     this.sellerDiscountMetaData,
//   });

//   AllProducts.fromJson(Map<String, dynamic> json)
//       : id = json['id'] as int?,
//         itemGUID = json['itemGUID'] as String?,
//         profileID = json['profileID'] as int?,
//         insertDate = json['insertDate'] as String?,
//         currency = json['currency'] as String?,
//         isPublish = json['isPublish'] as bool?,
//         isFav = false,
//         favorite = json['favorite'] as bool?,
//         isDiscounted = json['isDiscounted'] as bool?,
//         isAdminLocked = json['isAdminLocked'] as bool?,
//         imagesMetaData = json['imagesMetaData'] as String?,
//         videoMetaData = json['videoMetaData'],
//         amenityMetaData = json['amenityMetaData'],
//         isAttributeExist = json['isAttributeExist'] as int?,
//         productBasicMetaData =
//             (json['productBasicMetaData'] as Map<String, dynamic>?) != null
//                 ? ProductBasicMetaData.fromJson(
//                     json['productBasicMetaData'] as Map<String, dynamic>)
//                 : null,
//         productDetailMetaData =
//             (json['productDetailMetaData'] as Map<String, dynamic>?) != null
//                 ? ProductDetailMetaData.fromJson(
//                     json['productDetailMetaData'] as Map<String, dynamic>)
//                 : null,
//         productClassifiedMetaData = json['productClassifiedMetaData'],
//         productDigitalMetaData = json['productDigitalMetaData'],
//         productRelatedMetaData = json['productRelatedMetaData'],
//         productAuctionMetaData = json['productAuctionMetaData'],
//         productPennyAuctionMetaData = json['productPennyAuctionMetaData'],
//         productPolicyMetaData = json['productPolicyMetaData'],
//         productShippingMetaData =
//             (json['productShippingMetaData'] as Map<String, dynamic>?) != null
//                 ? ProductShippingMetaData.fromJson(
//                     json['productShippingMetaData'] as Map<String, dynamic>)
//                 : null,
//         imageItemMetaDatas = json['imageItemMetaDatas'],
//         productVideoMetaDatas = json['productVideoMetaDatas'],
//         amenityMetaDatas = json['amenityMetaDatas'],
//         productInventoryMetaData = json['productInventoryMetaData'],
//         itemOtherMetaData = json['itemOtherMetaData'],
//         sellerDiscountMetaData = json['sellerDiscountMetaData'];

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'itemGUID': itemGUID,
//         'profileID': profileID,
//         'insertDate': insertDate,
//         'isPublish': isPublish,
//         'isAdminLocked': isAdminLocked,
//         'isDiscounted': isDiscounted,
//         'imagesMetaData': imagesMetaData,
//         'videoMetaData': videoMetaData,
//         'amenityMetaData': amenityMetaData,
//         'isAttributeExist': isAttributeExist,
//         'productBasicMetaData': productBasicMetaData?.toJson(),
//         'productDetailMetaData': productDetailMetaData?.toJson(),
//         'productClassifiedMetaData': productClassifiedMetaData,
//         'productDigitalMetaData': productDigitalMetaData,
//         'productRelatedMetaData': productRelatedMetaData,
//         'currency': currency,
//         'productAuctionMetaData': productAuctionMetaData,
//         'productPennyAuctionMetaData': productPennyAuctionMetaData,
//         'productPolicyMetaData': productPolicyMetaData,
//         'productShippingMetaData': productShippingMetaData?.toJson(),
//         'imageItemMetaDatas': imageItemMetaDatas,
//         'productVideoMetaDatas': productVideoMetaDatas,
//         'amenityMetaDatas': amenityMetaDatas,
//         'productInventoryMetaData': productInventoryMetaData,
//         'itemOtherMetaData': itemOtherMetaData,
//         'sellerDiscountMetaData': sellerDiscountMetaData
//       };
// }

// class ProductBasicMetaData {
//   final int? sellingTypeID;
//   final int? listingTypeID;
//   final String? name;
//   final String? seourl;
//   final String? shortDescription;
//   final int? currencyId;
//   final double? price;
//   final String? image;
//   final String? productCategoryArray;
//   final String? unit;
//   final String? brand;
//   final String? seoMetaTitle;
//   final String? seoKeywords;
//   final String? seoMetadescription;

//   ProductBasicMetaData({
//     this.sellingTypeID,
//     this.listingTypeID,
//     this.name,
//     this.seourl,
//     this.shortDescription,
//     this.currencyId,
//     this.price,
//     this.image,
//     this.productCategoryArray,
//     this.unit,
//     this.brand,
//     this.seoMetaTitle,
//     this.seoKeywords,
//     this.seoMetadescription,
//   });

//   ProductBasicMetaData.fromJson(Map<String, dynamic> json)
//       : sellingTypeID = json['sellingTypeID'] as int?,
//         listingTypeID = json['listingTypeID'] as int?,
//         name = json['name'] as String?,
//         seourl = json['seourl'] as String?,
//         shortDescription = json['shortDescription'] as String?,
//         currencyId = json['currencyId'] as int?,
//         price = json['price'] as double?,
//         image = json['image'] as String?,
//         productCategoryArray = json['productCategoryArray'] as String?,
//         unit = json['unit'] as String?,
//         brand = json['brand'] as String?,
//         seoMetaTitle = json['seoMetaTitle'] as String?,
//         seoKeywords = json['seoKeywords'] as String?,
//         seoMetadescription = json['seoMetadescription'] as String?;

//   Map<String, dynamic> toJson() => {
//         'sellingTypeID': sellingTypeID,
//         'listingTypeID': listingTypeID,
//         'name': name,
//         'seourl': seourl,
//         'shortDescription': shortDescription,
//         'currencyId': currencyId,
//         'price': price,
//         'image': image,
//         'productCategoryArray': productCategoryArray,
//         'unit': unit,
//         'brand': brand,
//         'seoMetaTitle': seoMetaTitle,
//         'seoKeywords': seoKeywords,
//         'seoMetadescription': seoMetadescription
//       };
// }

// class ProductDetailMetaData {
//   final String? detailDescription;

//   ProductDetailMetaData({
//     this.detailDescription,
//   });

//   ProductDetailMetaData.fromJson(Map<String, dynamic> json)
//       : detailDescription = json['detailDescription'] as String?;

//   Map<String, dynamic> toJson() => {'detailDescription': detailDescription};
// }

// class ProductShippingMetaData {
//   final bool? isFreeShipping;
//   final dynamic shippingWeight;
//   final dynamic shippingLength;
//   final dynamic shippingWidth;
//   final dynamic shippingHeight;
//   final double? shippingAddOnCharges;

//   ProductShippingMetaData({
//     this.isFreeShipping,
//     this.shippingWeight,
//     this.shippingLength,
//     this.shippingWidth,
//     this.shippingHeight,
//     this.shippingAddOnCharges,
//   });

//   ProductShippingMetaData.fromJson(Map<String, dynamic> json)
//       : isFreeShipping = json['isFreeShipping'] as bool?,
//         shippingWeight = json['shippingWeight'],
//         shippingLength = json['shippingLength'],
//         shippingWidth = json['shippingWidth'],
//         shippingHeight = json['shippingHeight'],
//         shippingAddOnCharges = json['shippingAddOnCharges'] as double?;

//   Map<String, dynamic> toJson() => {
//         'isFreeShipping': isFreeShipping,
//         'shippingWeight': shippingWeight,
//         'shippingLength': shippingLength,
//         'shippingWidth': shippingWidth,
//         'shippingHeight': shippingHeight,
//         'shippingAddOnCharges': shippingAddOnCharges
//       };
// }

class AllProductsModel {
  List<AllProducts>? allProducts;
  int? pagecount;

  AllProductsModel({
    this.allProducts,
    this.pagecount,
  });

  AllProductsModel.fromJson(Map<String, dynamic> json) {
    allProducts = (json['productmodel'] as List?)
        ?.map((dynamic e) => AllProducts.fromJson(e as Map<String, dynamic>))
        .toList();
    pagecount = json['pagecount'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productmodel'] = allProducts?.map((e) => e.toJson()).toList();
    json['pagecount'] = pagecount;
    return json;
  }
}

class AllProducts {
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
  String? sellername;
  String? sellerimage;
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
  bool? favorite;
  int? comparisionExist;
  Userothermetadata? userothermetadata;
  dynamic itemothermetadata;
  dynamic itemdigitalmetadata;

  AllProducts({
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
    this.sellername,
    this.sellerimage,
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

  AllProducts.fromJson(Map<String, dynamic> json) {
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
    sellername = json['sellername'] as String?;
    sellerimage = json['sellerimage'] as String?;
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
    favorite = json['favorite'] as bool?;
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
    json['sellername'] = sellername;
    json['sellerimage'] = sellerimage;
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
