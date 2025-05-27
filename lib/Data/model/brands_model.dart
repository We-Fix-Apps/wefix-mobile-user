class BrandsModel {
  List<Brands>? brands;

  BrandsModel({
    this.brands,
  });

  BrandsModel.fromJson(List<dynamic> json) {
    brands = json
        .map((dynamic e) => Brands.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['brands'] = brands?.map((e) => e.toJson()).toList();
    return json;
  }
}

class Brands {
  int? id;
  String? title;
  dynamic image;

  Brands({
    this.id,
    this.title,
    this.image,
  });

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    title = json['title'] as String?;
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['id'] = id;
    json['title'] = title;
    json['image'] = image;
    return json;
  }
}
