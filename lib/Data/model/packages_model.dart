class PackagesModel {
  PackagesModel({
    required this.packages,
  });

  final List<PackagesModelPackage> packages;

  factory PackagesModel.fromJson(Map<String, dynamic> json) {
    return PackagesModel(
      packages: json["packages"] == null
          ? []
          : List<PackagesModelPackage>.from(
              json["packages"]!.map((x) => PackagesModelPackage.fromJson(x))),
    );
  }
}

class PackagesModelPackage {
  PackagesModelPackage({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.sortOder,
    required this.package,
  });

  final int? id;
  final String? title;
  final String? titleAr;
  final int? sortOder;
  final List<PackagePackage> package;

  factory PackagesModelPackage.fromJson(Map<String, dynamic> json) {
    return PackagesModelPackage(
      id: json["id"],
      title: json["title"],
      titleAr: json["titleAr"],
      sortOder: json["sortOder"],
      package: json["package"] == null
          ? []
          : List<PackagePackage>.from(
              json["package"]!.map((x) => PackagePackage.fromJson(x))),
    );
  }
}

class PackagePackage {
  PackagePackage({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.price,
    required this.priceAnnual,
    required this.duration,
    required this.features,
  });

  final int? id;
  final String? title;
  final String? titleAr;
  final int price;
  final int priceAnnual;
  final int? duration;
  final List<Feature> features;

  factory PackagePackage.fromJson(Map<String, dynamic> json) {
    return PackagePackage(
      id: json["id"],
      title: json["title"],
      titleAr: json["titleAr"],
      price: json["price"],
      priceAnnual: json["priceAnnual"],
      duration: json["duration"],
      features: json["features"] == null
          ? []
          : List<Feature>.from(
              json["features"]!.map((x) => Feature.fromJson(x))),
    );
  }
}

class Feature {
  Feature({
    required this.id,
    required this.feature,
    required this.featureAr,
    required this.status,
  });

  final int? id;
  final String? feature;
  final String? featureAr;
  final bool? status;

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json["id"],
      feature: json["feature"],
      featureAr: json["featureAR"],
      status: json["status"],
    );
  }
}
