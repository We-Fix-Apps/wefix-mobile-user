import 'dart:convert';
import 'dart:developer';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/brands_model.dart';
import 'package:wefix/Data/model/contacts_model.dart';
import 'package:wefix/Data/model/messges_model.dart';
import 'package:wefix/Data/model/review_model.dart';
import 'package:wefix/Data/model/shop_details_model.dart';
import 'package:wefix/Data/model/shops_model.dart';

class ShopApis {
  static ShopsModel? shopsModel;
  static List<Shops?>? shopsList;

  static Future getShop({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.shop,
        token: token,
      );

      log('getShop() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        shopsModel = ShopsModel.fromJson(body);
        shopsList = shopsModel?.shops;

        return shopsList;
      } else {
        return [];
      }
    } catch (e) {
      log('getShop() [ ERROR ] -> $e');
      return [];
    }
  }

  static ShopsDeatilsModel? shopsDetailsModel;
  static List<Seller?>? shopsDetailsList;

  static Future getShopDeatils(
      {required String token, required String id}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.shopDeatils + id,
        token: token,
      );

      log('getShopDeatils() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        shopsDetailsModel = ShopsDeatilsModel.fromJson(body);

        return shopsDetailsModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getShopDeatils() [ ERROR ] -> $e');
      return [];
    }
  }

  static BrandsModel? brandsModel;
  static List<Brands?>? brandsList;
  static Future getBrands({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.brands,
        token: token,
      );

      log('getBrands() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        brandsModel = BrandsModel.fromJson(body);
        brandsList = brandsModel?.brands;

        return brandsList;
      } else {
        return [];
      }
    } catch (e) {
      log('getBrands() [ ERROR ] -> $e');
      return [];
    }
  }

  static ReviewModel? reviewModel;
  static List<Review?>? reviewList;

  static Future getReveiw({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.review,
        token: token,
      );

      log('getReveiw() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        reviewModel = ReviewModel.fromJson(body);
        reviewList = reviewModel?.review;

        return reviewList;
      } else {
        return [];
      }
    } catch (e) {
      log('getReveiw() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future createChat({
    required String token,
    String? shopId,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.createChat + shopId!,
        token: token,
      );

      log('createChat() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["chatid"];
      } else {
        return [];
      }
    } catch (e) {
      log('createChat() [ ERROR ] -> $e');
      return [];
    }
  }

  static MassegesModel? massegesModel;
  static Future getMessagesList(
      {required String token, required String chatId}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.messagesList,
        token: token,
        data: {
          "chatid": chatId,
        },
      );

      log('getMessagesList() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
      massegesModel = MassegesModel.fromJson(body);
      if (response.statusCode == 200) {
        return massegesModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getMessagesList() [ ERROR ] -> $e');
      return null;
    }
  }

  static ContactsModel? contactsModel;
  static Future getContactsChat({
    required String token,
    String? shopId,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.contactlist,
        token: token,
      );

      log('getContactsChat() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
      contactsModel = ContactsModel.fromJson(body);
      if (response.statusCode == 200) {
        return contactsModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getContactsChat() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future sendMessages({
    required String token,
    required String chatId,
    required String message,
    required String attachment,
    required String attachmentName,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.sendMessage,
        token: token,
        data: {
          "chatid": chatId,
          "message": message,
          "attachment": attachment,
          "filename": attachmentName,
        },
      );

      log('sendMessages() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
      massegesModel = MassegesModel.fromJson(body);
      if (response.statusCode == 200) {
        return massegesModel;
      } else {
        return null;
      }
    } catch (e) {
      log('sendMessages() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future updateMessages({
    required String token,
    String? chatId,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.updateMessage + chatId!,
        token: token,
      );

      log('updateMessages() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return [];
      }
    } catch (e) {
      log('updateMessages() [ ERROR ] -> $e');
      return [];
    }
  }
}
