class AllCategoryModel {
  final List<AllCategory>? allCategory;

  AllCategoryModel({
    this.allCategory,
  });

  AllCategoryModel.fromJson(List<dynamic> json)
      : allCategory = json
            .map((dynamic e) => AllCategory.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() =>
      {'all_category': allCategory?.map((e) => e.toJson()).toList()};
}

class AllCategory {
  final int? categoryId;
  final String? categoryName;
  final String? icon;
  final int? count;

  AllCategory({
    this.categoryId,
    this.categoryName,
    this.icon,
    this.count,
  });

  AllCategory.fromJson(Map<String, dynamic> json)
      : categoryId = json['categoryId'] as int?,
        count = json['count'] as int?,
        categoryName = json['categoryName'] as String?,
        icon = json['icon'] as String?;

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'icon': icon,
        "count": count
      };
}
