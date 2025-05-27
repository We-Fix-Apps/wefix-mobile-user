import 'package:wefix/Data/model/all_products_model.dart';

class ProductsDetails {
  Productmodel? productmodel;
  List<AllProducts>? productrelatedModel;
  bool? incart;

  ProductsDetails({
    this.productmodel,
    this.incart,
    this.productrelatedModel,
  });

  ProductsDetails.fromJson(Map<String, dynamic> json) {
    productmodel = (json['productmodel'] as Map<String, dynamic>?) != null
        ? Productmodel.fromJson(json['productmodel'] as Map<String, dynamic>)
        : null;
    incart = json['incart'] as bool?;

    productrelatedModel = (json['productrelatedModel'] as List?)
        ?.map((dynamic e) => AllProducts.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productmodel'] = productmodel?.toJson();
    incart = json['incart'] as bool?;

    return json;
  }
}

class Productmodel {
  String? profileguid;
  int? profileId;
  dynamic shopurlpath;
  int? productId;
  String? productGUID;
  dynamic productSeourl;
  dynamic productImage;
  dynamic produtAltText;
  dynamic productName;
  dynamic productUnit;
  dynamic brandName;
  dynamic sku;
  dynamic eanCode;
  dynamic shortDescription;
  dynamic detailDescription;
  dynamic returnPolicy;
  dynamic cancelPolicy;
  bool? isOutofStock;
  bool? isVideo;
  dynamic listofVideo;
  bool? isManagedInventory;
  int? minQty;
  int? maxQty;
  dynamic currency;
  double? price;
  double? actualPrice;
  int? actualCurrency;
  bool? isDiscounted;
  double? discountAmount;
  double? priceBeforeDiscount;
  dynamic insertdate;
  bool? ispublish;
  dynamic itemaddress;
  dynamic itemcontact;
  dynamic itememail;
  int? generalSetupId;
  dynamic listingType;
  dynamic sellingType;
  dynamic wishlistgroupname;
  int? isAttributeExist;
  dynamic productList;
  ProductDetail? productDetail;
  List<ProductAttributeViewModel>? productAttributeViewModel;
  dynamic productShippingMetaData;
  dynamic listofImages;
  dynamic categoryarrary;
  dynamic listProductCategoryMetaData;
  int? categoryId;
  dynamic categoryName;
  dynamic amenityViewModel;
  dynamic listAmenityMetaData;
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
  dynamic userothermetadata;
  dynamic itemothermetadata;
  dynamic itemdigitalmetadata;

  Productmodel({
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

  Productmodel.fromJson(Map<String, dynamic> json) {
    profileguid = json['profileguid'] as String?;
    profileId = json['profileId'] as int?;
    shopurlpath = json['shopurlpath'];
    productId = json['productId'] as int?;
    productGUID = json['productGUID'] as String?;
    productSeourl = json['productSeourl'];
    productImage = json['productImage'];
    produtAltText = json['produtAltText'];
    productName = json['productName'];
    productUnit = json['productUnit'];
    brandName = json['brandName'];
    sku = json['sku'];
    eanCode = json['eanCode'];
    shortDescription = json['shortDescription'];
    detailDescription = json['detailDescription'];
    returnPolicy = json['returnPolicy'];
    cancelPolicy = json['cancelPolicy'];
    isOutofStock = json['isOutofStock'] as bool?;
    isVideo = json['isVideo'] as bool?;
    listofVideo = json['listofVideo'];
    isManagedInventory = json['isManagedInventory'] as bool?;
    minQty = json['minQty'] as int?;
    maxQty = json['maxQty'] as int?;
    currency = json['currency'];
    price = json['price'] as double?;
    actualPrice = json['actualPrice'] as double?;
    actualCurrency = json['actualCurrency'] as int?;
    isDiscounted = json['isDiscounted'] as bool?;
    discountAmount = json['discountAmount'] as double?;
    priceBeforeDiscount = json['priceBeforeDiscount'] as double?;
    insertdate = json['insertdate'];
    ispublish = json['ispublish'] as bool?;
    itemaddress = json['itemaddress'];
    itemcontact = json['itemcontact'];
    itememail = json['itememail'];
    generalSetupId = json['generalSetupId'] as int?;
    listingType = json['listingType'];
    sellingType = json['sellingType'];
    wishlistgroupname = json['wishlistgroupname'];
    isAttributeExist = json['isAttributeExist'] as int?;
    productList = json['productList'];
    productDetail = (json['productDetail'] as Map<String, dynamic>?) != null
        ? ProductDetail.fromJson(json['productDetail'] as Map<String, dynamic>)
        : null;
    productAttributeViewModel = (json['productAttributeViewModel'] as List?)
        ?.map((dynamic e) =>
            ProductAttributeViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    productShippingMetaData = json['productShippingMetaData'];
    listofImages = json['listofImages'];
    categoryarrary = json['categoryarrary'];
    listProductCategoryMetaData = json['listProductCategoryMetaData'];
    categoryId = json['categoryId'] as int?;
    categoryName = json['categoryName'];
    amenityViewModel = json['amenityViewModel'];
    listAmenityMetaData = json['listAmenityMetaData'];
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
    userothermetadata = json['userothermetadata'];
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
    json['productDetail'] = productDetail?.toJson();
    json['productAttributeViewModel'] =
        productAttributeViewModel?.map((e) => e.toJson()).toList();
    json['productShippingMetaData'] = productShippingMetaData;
    json['listofImages'] = listofImages;
    json['categoryarrary'] = categoryarrary;
    json['listProductCategoryMetaData'] = listProductCategoryMetaData;
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
    json['userothermetadata'] = userothermetadata;
    json['itemothermetadata'] = itemothermetadata;
    json['itemdigitalmetadata'] = itemdigitalmetadata;
    return json;
  }
}

class ProductDetail {
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
  String? sellername;
  String? sellerimage;
  dynamic productDetail;
  dynamic productAttributeViewModel;
  dynamic productShippingMetaData;
  List<ListofImages>? listofImages;
  String? categoryarrary;
  List<ListProductCategoryMetaData>? listProductCategoryMetaData;
  int? categoryId;
  dynamic categoryName;
  dynamic amenityViewModel;
  List<ListAmenityMetaData>? listAmenityMetaData;
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
  Itemothermetadata? itemothermetadata;
  dynamic itemdigitalmetadata;

  ProductDetail({
    this.sellername,
    this.sellerimage,
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

  ProductDetail.fromJson(Map<String, dynamic> json) {
    profileguid = json['profileguid'] as String?;
    profileId = json['profileId'] as int?;
    sellerimage = json['sellerimage'] as String?;
    sellername = json['sellername'] as String?;
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
    listAmenityMetaData = (json['listAmenityMetaData'] as List?)
        ?.map((dynamic e) =>
            ListAmenityMetaData.fromJson(e as Map<String, dynamic>))
        .toList();
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
    itemothermetadata =
        (json['itemothermetadata'] as Map<String, dynamic>?) != null
            ? Itemothermetadata.fromJson(
                json['itemothermetadata'] as Map<String, dynamic>)
            : null;
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
    json['sellerimage'] = sellerimage;
    json['sellername'] = sellername;
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
    json['listAmenityMetaData'] =
        listAmenityMetaData?.map((e) => e.toJson()).toList();
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
    json['itemothermetadata'] = itemothermetadata?.toJson();
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

class ListAmenityMetaData {
  int? id;
  int? optionID;
  int? amenityID;

  ListAmenityMetaData({
    this.id,
    this.optionID,
    this.amenityID,
  });

  ListAmenityMetaData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    optionID = json['optionID'] as int?;
    amenityID = json['amenityID'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['optionID'] = optionID;
    json['amenityID'] = amenityID;
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

class Itemothermetadata {
  int? totalCompletedOrders;
  int? totalReviews;
  double? itemAverageRating;
  int? totalViews;
  int? totalClicks;

  Itemothermetadata({
    this.totalCompletedOrders,
    this.totalReviews,
    this.itemAverageRating,
    this.totalViews,
    this.totalClicks,
  });

  Itemothermetadata.fromJson(Map<String, dynamic> json) {
    totalCompletedOrders = json['totalCompletedOrders'] as int?;
    totalReviews = json['totalReviews'] as int?;
    itemAverageRating = json['itemAverageRating'] as double?;
    totalViews = json['totalViews'] as int?;
    totalClicks = json['totalClicks'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['totalCompletedOrders'] = totalCompletedOrders;
    json['totalReviews'] = totalReviews;
    json['itemAverageRating'] = itemAverageRating;
    json['totalViews'] = totalViews;
    json['totalClicks'] = totalClicks;
    return json;
  }
}

class ProductAttributeViewModel {
  Question? question;
  List<Options>? options;

  ProductAttributeViewModel({
    this.question,
    this.options,
  });

  ProductAttributeViewModel.fromJson(Map<String, dynamic> json) {
    question = (json['question'] as Map<String, dynamic>?) != null
        ? Question.fromJson(json['question'] as Map<String, dynamic>)
        : null;
    options = (json['options'] as List?)
        ?.map((dynamic e) => Options.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['question'] = question?.toJson();
    json['options'] = options?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Question {
  int? productAttributeId;
  String? productAttributeGuid;
  String? productGuid;
  String? question;
  String? type;
  int? sortNumber;
  bool? isPublish;
  String? insertDate;
  int? profileId;

  Question({
    this.productAttributeId,
    this.productAttributeGuid,
    this.productGuid,
    this.question,
    this.type,
    this.sortNumber,
    this.isPublish,
    this.insertDate,
    this.profileId,
  });

  Question.fromJson(Map<String, dynamic> json) {
    productAttributeId = json['productAttributeId'] as int?;
    productAttributeGuid = json['productAttributeGuid'] as String?;
    productGuid = json['productGuid'] as String?;
    question = json['question'] as String?;
    type = json['type'] as String?;
    sortNumber = json['sortNumber'] as int?;
    isPublish = json['isPublish'] as bool?;
    insertDate = json['insertDate'] as String?;
    profileId = json['profileId'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['productAttributeId'] = productAttributeId;
    json['productAttributeGuid'] = productAttributeGuid;
    json['productGuid'] = productGuid;
    json['question'] = question;
    json['type'] = type;
    json['sortNumber'] = sortNumber;
    json['isPublish'] = isPublish;
    json['insertDate'] = insertDate;
    json['profileId'] = profileId;
    return json;
  }
}

class Options {
  double? actualAttributeprice;
  double? conversionAttributeprice;
  String? optionText;
  dynamic attributeimage;
  bool? isSelect;

  Options({
    this.actualAttributeprice,
    this.conversionAttributeprice,
    this.optionText,
    this.isSelect,
    this.attributeimage,
  });

  Options.fromJson(Map<String, dynamic> json) {
    actualAttributeprice = json['actualAttributeprice'] as double?;
    isSelect = false;
    conversionAttributeprice = json['conversionAttributeprice'] as double?;
    optionText = json['optionText'] as String?;
    attributeimage = json['attributeimage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['actualAttributeprice'] = actualAttributeprice;
    json['conversionAttributeprice'] = conversionAttributeprice;
    json['optionText'] = optionText;
    json['attributeimage'] = attributeimage;
    return json;
  }
}
