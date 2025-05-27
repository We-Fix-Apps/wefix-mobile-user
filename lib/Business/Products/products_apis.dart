import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/all_products_model.dart';
import 'package:wefix/Data/model/product_question_model.dart';
import 'package:wefix/Data/model/products_details_model.dart';

class ProductsApis {
  static AllProductsModel? allProductsModel;
  static List<AllProducts> products = [];

  // * Get All Products
  static Future allProducts({required String token, required int page}) async {
    try {
      if (page == 1) {
        final response = await HttpHelper.getData(
          query: EndPoints.allProducts + page.toString(),
          token: token,
        );

        log('allProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products = allProductsModel!.allProducts!;
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (allProductsModel?.pagecount ?? 0)) {
        final response = await HttpHelper.getData(
          query: EndPoints.allProducts + page.toString(),
          token: token,
        );

        log('allProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products.addAll(allProductsModel!.allProducts!);
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        return products;
      }
    } catch (e) {
      log('allProducts() [ ERROR ] -> $e');
      return [];
    }
  }

  static AllProductsModel? allFeatueredProductsModel;
  static List<AllProducts> featuered = [];

  static Future allFeatueredProducts({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getFeatuered,
        token: token,
      );

      log('allFeatueredProducts() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        allFeatueredProductsModel = AllProductsModel.fromJson(body);
        if (allFeatueredProductsModel?.allProducts?.isNotEmpty ?? false) {
          featuered = allFeatueredProductsModel!.allProducts!;
          return featuered;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('allFeatueredProducts() [ ERROR ] -> $e');
      return [];
    }
  }

  static AllProductsModel? allProductsBySellerModel;
  static List<AllProducts> allProductsbySeller = [];
  static Future allProductsBySeller(
      {required String token, required int page, required int id}) async {
    try {
      if (page == 1) {
        final response = await HttpHelper.getData(
          query:
              "${EndPoints.allProductsBySeller + id.toString()}/${page.toString()}",
          token: token,
        );

        log('allProductsBySeller() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsBySellerModel = AllProductsModel.fromJson(body);
          if (allProductsBySellerModel?.allProducts?.isNotEmpty ?? false) {
            allProductsbySeller = allProductsBySellerModel!.allProducts!;
            return allProductsbySeller;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (allProductsBySellerModel?.pagecount ?? 0)) {
        final response = await HttpHelper.getData(
          query: EndPoints.allProductsBySeller + page.toString(),
          token: token,
        );

        log('allProductsBySeller() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsBySellerModel = AllProductsModel.fromJson(body);
          if (allProductsBySellerModel?.allProducts?.isNotEmpty ?? false) {
            allProductsbySeller.addAll(allProductsBySellerModel!.allProducts!);
            return allProductsbySeller;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        return allProductsbySeller;
      }
    } catch (e) {
      log('allProductsBySeller() [ ERROR ] -> $e');
      return [];
    }
  }

  static AllProductsModel? allProductsByBrandModel;
  static List<AllProducts> allProductsbyBrand = [];
  static Future allProductByBrand(
      {required String token, required int page, required String name}) async {
    try {
      if (page == 1) {
        final response = await HttpHelper.getData(
          query:
              "${EndPoints.allProductByBrand + name.toString()}/${page.toString()}",
          token: token,
        );

        log('allProductByBrand() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsByBrandModel = AllProductsModel.fromJson(body);
          if (allProductsByBrandModel?.allProducts?.isNotEmpty ?? false) {
            allProductsbyBrand = allProductsByBrandModel!.allProducts!;
            return allProductsbyBrand;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (allProductsBySellerModel?.pagecount ?? 0)) {
        final response = await HttpHelper.getData(
          query: EndPoints.allProductsBySeller + page.toString(),
          token: token,
        );

        log('allProductByBrand() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsByBrandModel = AllProductsModel.fromJson(body);
          if (allProductsByBrandModel?.allProducts?.isNotEmpty ?? false) {
            allProductsbyBrand = allProductsByBrandModel!.allProducts!;
            return allProductsbyBrand;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        return allProductsbyBrand;
      }
    } catch (e) {
      log('allProductByBrand() [ ERROR ] -> $e');
      return [];
    }
  }

  // * Get All Products By Category
  static Future<List<AllProducts>> allProductsByCategory({
    required String token,
    required int id,
    required int page,
    double? from,
    double? to,
    String? keyWord,
  }) async {
    try {
      if (page == 1) {
        final response = await HttpHelper.postData(
            query: EndPoints.productsByCategory,
            token: token,
            data: {
              "PageNumber": page,
              "Id": id,
              "keyword": keyWord,
              "pricefrom": from,
              "priceto": to
            });

        log('allProductsByCategory() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products = allProductsModel!.allProducts!;
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (allProductsModel?.pagecount ?? 0)) {
        final response = await HttpHelper.getData(
          query: '${EndPoints.productsByCategory}$id/$page',
          token: token,
        );

        log('allProductsByCategory() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products.addAll(allProductsModel!.allProducts!);
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        return products;
      }
    } catch (e) {
      log('allProductsByCategory() [ ERROR ] -> $e');
      return [];
    }
  }

  // * Products By Id
  static ProductsDetails? productsDetails;
  static Future<ProductsDetails?> productById({
    required String token,
    required String id,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.productsById + id,
        token: token,
      );

      log('Product By Id() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        productsDetails = ProductsDetails.fromJson(body);
        if (productsDetails != null) {
          return productsDetails;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('Product By Id() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Wishlist
  static Future addToWishList(
      {required String token, required int productId}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.addToWishlist,
        token: token,
        data: {
          "ProductId": productId,
        },
      );

      log('addToWishList() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('addToWishList() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Wishlist
  static Future askQuestion(
      {required String token,
      required String productId,
      required String question}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.askQuestion,
        token: token,
        data: {
          "ProductId": productId,
          "Question": question,
        },
      );

      log('askQuestion() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('askQuestion() [ ERROR ] -> $e');
      return null;
    }
  }

  static ProductQuestionModel? productQuestionModel;
  static Future<ProductQuestionModel?> getProductQuestions({
    required String token,
    required String id,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.productQuestion + id,
        token: token,
      );

      log('getProductQuestions() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        productQuestionModel = ProductQuestionModel.fromJson(body);
        if (productQuestionModel != null) {
          return productQuestionModel;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('getProductQuestions() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future getPopularWords({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getpopular,
        token: token,
      );

      log('getPopularWords() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["search"];
      } else {
        return null;
      }
    } catch (e) {
      log('getPopularWords() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future getLastWords({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getSearchLast,
        token: token,
      );

      log('getLastWords() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["search"];
      } else {
        return null;
      }
    } catch (e) {
      log('getLastWords() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future removeFromWishList(
      {required String token, required int productId}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.removeFromWishlist,
        token: token,
        data: {
          "ProductId": productId,
        },
      );

      log('removeFromWishList() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('removeFromWishList() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Get All Products By Category
  static Future<List<AllProducts>> searchProducts({
    required int page,
    String? keyWord,
  }) async {
    try {
      if (page == 1) {
        final response =
            await HttpHelper.postData(query: EndPoints.searchProducts, data: {
          "PageNumber": page,
          "keyword": keyWord,
        });

        log('searchProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products = allProductsModel!.allProducts!;
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (allProductsModel?.pagecount ?? 0)) {
        final response =
            await HttpHelper.postData(query: EndPoints.searchProducts, data: {
          "PageNumber": page,
          "keyword": keyWord,
        });

        log('searchProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          allProductsModel = AllProductsModel.fromJson(body);
          if (allProductsModel?.allProducts?.isNotEmpty ?? false) {
            products.addAll(allProductsModel!.allProducts!);
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        return products;
      }
    } catch (e) {
      log('searchProducts() [ ERROR ] -> $e');
      return [];
    }
  }
}
