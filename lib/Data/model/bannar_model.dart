class BannarModel {
  final List<String>? banners;

  BannarModel({
    this.banners,
  });

  BannarModel.fromJson(Map<String, dynamic> json)
      : banners = (json['banners'] as List?)
            ?.map((dynamic e) => e as String)
            .toList();

  Map<String, dynamic> toJson() => {'banners': banners};
}
