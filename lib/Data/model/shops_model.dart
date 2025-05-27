class ShopsModel {
  List<Shops>? shops;

  ShopsModel({
    this.shops,
  });

  ShopsModel.fromJson(Map<String, dynamic> json) {
    shops = (json['seller'] as List?)
        ?.map((dynamic e) => Shops.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['seller'] = shops?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Shops {
  int? profileId;
  String? profileGuid;
  String? displayname;
  dynamic contact;
  dynamic email;
  String? image;
  dynamic businessType;
  String? businessName;
  String? businessUrlpath;
  dynamic businessDescription;
  int? productTotal;
  Userothermetadata? userothermetadata;
  dynamic primaryaddressViewModel;
  dynamic businessMetaData;

  Shops({
    this.profileId,
    this.profileGuid,
    this.displayname,
    this.contact,
    this.email,
    this.image,
    this.businessType,
    this.businessName,
    this.businessUrlpath,
    this.businessDescription,
    this.productTotal,
    this.userothermetadata,
    this.primaryaddressViewModel,
    this.businessMetaData,
  });

  Shops.fromJson(Map<String, dynamic> json) {
    profileId = json['profileId'] as int?;
    profileGuid = json['profileGuid'] as String?;
    displayname = json['displayname'] as String?;
    contact = json['contact'];
    email = json['email'];
    image = json['image'] as String?;
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
    primaryaddressViewModel = json['primaryaddressViewModel'];
    businessMetaData = json['businessMetaData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['profileId'] = profileId;
    json['profileGuid'] = profileGuid;
    json['displayname'] = displayname;
    json['contact'] = contact;
    json['email'] = email;
    json['image'] = image;
    json['businessType'] = businessType;
    json['businessName'] = businessName;
    json['businessUrlpath'] = businessUrlpath;
    json['businessDescription'] = businessDescription;
    json['productTotal'] = productTotal;
    json['userothermetadata'] = userothermetadata?.toJson();
    json['primaryaddressViewModel'] = primaryaddressViewModel;
    json['businessMetaData'] = businessMetaData;
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
  dynamic userAgentMetaData;
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
    userAgentMetaData = json['userAgentMetaData'];
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
    json['userAgentMetaData'] = userAgentMetaData;
    json['userInactiveMetaData'] = userInactiveMetaData;
    return json;
  }
}
