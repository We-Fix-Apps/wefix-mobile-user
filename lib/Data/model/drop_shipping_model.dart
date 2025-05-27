class DropShippingProductModel {
  int? code;
  bool? result;
  String? message;
  Data? data;
  String? requestId;
  bool? success;

  DropShippingProductModel({
    this.code,
    this.result,
    this.message,
    this.data,
    this.requestId,
    this.success,
  });

  DropShippingProductModel.fromJson(Map<String, dynamic> json) {
    code = json['code'] as int?;
    result = json['result'] as bool?;
    message = json['message'] as String?;
    data = (json['data'] as Map<String, dynamic>?) != null
        ? Data.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    requestId = json['requestId'] as String?;
    success = json['success'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['code'] = code;
    json['result'] = result;
    json['message'] = message;
    json['data'] = data?.toJson();
    json['requestId'] = requestId;
    json['success'] = success;
    return json;
  }
}

class Data {
  int? pageNum;
  int? pageSize;
  int? total;
  List<ProductsDrop>? list;

  Data({
    this.pageNum,
    this.pageSize,
    this.total,
    this.list,
  });

  Data.fromJson(Map<String, dynamic> json) {
    pageNum = json['pageNum'] as int?;
    pageSize = json['pageSize'] as int?;
    total = json['total'] as int?;
    list = (json['list'] as List?)
        ?.map((dynamic e) => ProductsDrop.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['pageNum'] = pageNum;
    json['pageSize'] = pageSize;
    json['total'] = total;
    json['list'] = list?.map((e) => e.toJson()).toList();
    return json;
  }
}

class ProductsDrop {
  String? pid;
  String? productName;
  String? productNameEn;
  String? productSku;
  String? productImage;
  String? productWeight;
  String? productType;
  dynamic productUnit;
  String? categoryName;
  int? listingCount;
  String? sellPrice;
  String? remark;
  dynamic addMarkStatus;
  int? createTime;
  dynamic isVideo;
  int? saleStatus;
  int? listedNum;
  dynamic supplierName;
  dynamic supplierId;
  String? categoryId;
  String? sourceFrom;
  List<String>? shippingCountryCodes;

  ProductsDrop({
    this.pid,
    this.productName,
    this.productNameEn,
    this.productSku,
    this.productImage,
    this.productWeight,
    this.productType,
    this.productUnit,
    this.categoryName,
    this.listingCount,
    this.sellPrice,
    this.remark,
    this.addMarkStatus,
    this.createTime,
    this.isVideo,
    this.saleStatus,
    this.listedNum,
    this.supplierName,
    this.supplierId,
    this.categoryId,
    this.sourceFrom,
    this.shippingCountryCodes,
  });

  ProductsDrop.fromJson(Map<String, dynamic> json) {
    pid = json['pid'] as String?;
    productName = json['productName'] as String?;
    productNameEn = json['productNameEn'] as String?;
    productSku = json['productSku'] as String?;
    productImage = json['productImage'] as String?;
    productWeight = json['productWeight'] as String?;
    productType = json['productType'] as String?;
    productUnit = json['productUnit'];
    categoryName = json['categoryName'] as String?;
    listingCount = json['listingCount'] as int?;
    sellPrice = json['sellPrice'] as String?;
    remark = json['remark'] as String?;
    addMarkStatus = json['addMarkStatus'];
    createTime = json['createTime'] as int?;
    isVideo = json['isVideo'];
    saleStatus = json['saleStatus'] as int?;
    listedNum = json['listedNum'] as int?;
    supplierName = json['supplierName'];
    supplierId = json['supplierId'];
    categoryId = json['categoryId'] as String?;
    sourceFrom = json['sourceFrom'] as String?;
    shippingCountryCodes = (json['shippingCountryCodes'] as List?)
        ?.map((dynamic e) => e as String)
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['pid'] = pid;
    json['productName'] = productName;
    json['productNameEn'] = productNameEn;
    json['productSku'] = productSku;
    json['productImage'] = productImage;
    json['productWeight'] = productWeight;
    json['productType'] = productType;
    json['productUnit'] = productUnit;
    json['categoryName'] = categoryName;
    json['listingCount'] = listingCount;
    json['sellPrice'] = sellPrice;
    json['remark'] = remark;
    json['addMarkStatus'] = addMarkStatus;
    json['createTime'] = createTime;
    json['isVideo'] = isVideo;
    json['saleStatus'] = saleStatus;
    json['listedNum'] = listedNum;
    json['supplierName'] = supplierName;
    json['supplierId'] = supplierId;
    json['categoryId'] = categoryId;
    json['sourceFrom'] = sourceFrom;
    json['shippingCountryCodes'] = shippingCountryCodes;
    return json;
  }
}
