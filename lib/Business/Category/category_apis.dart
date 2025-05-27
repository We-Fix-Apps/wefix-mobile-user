import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/Model/all_category_model.dart';

class CategoryApis {
  static AllCategoryModel? categoryModel;

  // * Get All Category
  static Future<List<AllCategory>> allCategory({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.category,
        token: token,
      );

      log('allCategory() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        categoryModel = AllCategoryModel.fromJson(body);
        if (categoryModel?.allCategory?.isNotEmpty ?? false) {
          return categoryModel!.allCategory!;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('allCategory() [ ERROR ] -> $e');
      return [];
    }
  }

  // * Get All Category
  static Future getColor({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.color,
        token: token,
      );

      log('getColor() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        log(body["color"]["websettingValue"]);

        return body["color"]["websettingValue"];
      } else {
        return [];
      }
    } catch (e) {
      log('getColor() [ ERROR ] -> $e');
      return [];
    }
  }

  // * Get All Subcategory
  static Future allSubcategory({required String token, required int id}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.subCategory + id.toString(),
        token: token,
      );

      log('allSubcategory() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        categoryModel = AllCategoryModel.fromJson(body);
        if (categoryModel?.allCategory?.isNotEmpty ?? false) {
          return categoryModel!.allCategory!;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('allSubcategory() [ ERROR ] -> $e');
      return [];
    }
  }
}
