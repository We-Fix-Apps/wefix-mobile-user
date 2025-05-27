import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Data/Api/http_request.dart';

import 'package:wefix/Data/model/drop_shipping_model.dart';

class AccessTokenApi {
  static Future getAccessToken({required String token}) async {
    try {
      final response = await HttpHelper.postData2(
          query:
              "https://developers.cjdropshipping.com/api2.0/v1/authentication/getAccessToken",
          token: token,
          data: {
            "email": "m.tenderjo@gmail.com",
            "password": "5b3ac7a305f743e28368a5bc2fc2bd5e"
          });

      log('getAccessToken() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        log(body["data"]["accessToken"].toString());

        return body["data"]["accessToken"];
      } else {
        return null;
      }
    } catch (e) {
      log('getAccessToken() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Get All Products
  static DropShippingProductModel? dropShippingProductModel;
  static List<ProductsDrop> products = [];
  static Future allProductsDrop(
      {required String token, required int page}) async {
    try {
      if (page == 1) {
        final response = await HttpHelper.getData2(
          query:
              "https://developers.cjdropshipping.com/api2.0/v1/product/list?pageNum=$page",
          token: token,
        );

        log('allProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          dropShippingProductModel = DropShippingProductModel.fromJson(body);
          if (dropShippingProductModel?.data?.list?.isNotEmpty ?? false) {
            products = dropShippingProductModel!.data?.list! ?? [];
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else if (page <= (dropShippingProductModel!.data?.pageNum ?? 0)) {
        final response = await HttpHelper.getData2(
          query:
              "https://developers.cjdropshipping.com/api2.0/v1/product/list?pageNum=$page",
          token: token,
        );

        log('allProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          dropShippingProductModel = DropShippingProductModel.fromJson(body);
          if (dropShippingProductModel?.data?.list?.isNotEmpty ?? false) {
            products.addAll(dropShippingProductModel!.data!.list!);
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      } else {
        final response = await HttpHelper.getData2(
          query:
              "https://developers.cjdropshipping.com/api2.0/v1/product/list?pageNum=$page",
          token: token,
        );

        log('allProducts() [ STATUS ] -> ${response.statusCode}');

        final body = json.decode(response.body);

        if (response.statusCode == 200) {
          dropShippingProductModel = DropShippingProductModel.fromJson(body);
          if (dropShippingProductModel?.data?.list?.isNotEmpty ?? false) {
            products.addAll(dropShippingProductModel!.data!.list!);
            return products;
          } else {
            return [];
          }
        } else {
          return [];
        }
      }
    } catch (e) {
      log('allProducts() [ ERROR ] -> $e');
      return [];
    }
  }
}
