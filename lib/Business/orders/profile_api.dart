import 'dart:convert';
import 'dart:developer';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/all_products_model.dart';
import 'package:wefix/Data/model/cart_model.dart';
import 'package:wefix/Data/model/order_deatils_model.dart';
import 'package:wefix/Data/model/order_model.dart';
import 'package:wefix/Data/model/profile_model.dart';
import 'package:wefix/Data/model/realstate_model.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';

class ProfileApis {
  static AllProductsModel? allProductsModel;
  static List<AllProducts> products = [];

  static OrdersModel? ordersModel;
  static List<Orders> orders = [];
  static Future getOrder({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.orders,
        token: token,
      );

      log('getOrder() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        ordersModel = OrdersModel.fromJson(body);
        if (ordersModel?.orders?.isNotEmpty ?? false) {
          orders = ordersModel!.orders!;
          return ordersModel;
        } else {
          return [];
        }
      } else {
        return null;
      }
    } catch (e) {
      log('getOrder() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future<List<AllProducts>> getWishList({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.wishlist,
        token: token,
      );

      log('getWishList() [ STATUS ] -> ${response.statusCode}');

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
    } catch (e) {
      log('getWishList() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future getAddress({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.address,
        token: token,
      );

      log('getAddress() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('getAddress() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future getCoupons({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.address,
        token: token,
      );

      log('getCoupons() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('getCoupons() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future contactUs({required String token, required Map user}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.contactUs,
        token: token,
        data: {
          'Email': user['Email'],
          'Name': user['Name'],
          'Phone': user['Phone'],
          'Comment': user['Comment'],
        },
      );

      log('contactUs() [ STATUS ] -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('contactUs() [ ERROR ] -> $e');
      return false;
    }
  }

  static Future addToCart({
    required String token,
    required String productId,
    String? qty,
    List? dataList,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.addToCart,
        token: token,
        data: {
          "ProductId": productId,
          "Quantity": qty,
          "VariationMetaDatalist": dataList
        },
      );

      log('addToCart() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('addToCart() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future removeFromCart({
    required String token,
    required int id,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.removeFromCart,
        data: {
          "Id": id,
        },
        token: token,
      );

      log('removeFromCart() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('removeFromCart() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future addReviewTech({
    required String token,
    required String comment,
    required int id,
    required double rate,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.rate,
        data: {
          "TicketId": id,
          "Rating": rate,
          "Comment": comment,
        },
        token: token,
      );

      log('addReviewTech() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('addReviewTech() [ ERROR ] -> $e');
      return null;
    }
  }

  static SubsicripeModel? subsicripeModel;

  static Future isSubsicribe({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.isSubsicribe,
        token: token,
      );

      log('isSubsicribe() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        subsicripeModel = SubsicripeModel.fromJson(body);
        return subsicripeModel;
      } else {
        return false;
      }
    } catch (e) {
      log('isSubsicribe() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future renew({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.renew,
        token: token,
      );

      log('renew() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body['status'];
      } else {
        return false;
      }
    } catch (e) {
      log('renew() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Products By Id
  static RealEstatesModel? realEstatesModel;
  static Future getRealState({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getRealState,
        token: token,
      );

      log('getRealState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        realEstatesModel = RealEstatesModel.fromJson(body);
        return realEstatesModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getRealState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future createRealeState({
    required String token,
    required String title,
    required String? area,
    required String? apartmentNo,
    required String? address,
    required String? latitude,
    required String? longitude,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.createRealState,
        data: {
          "Title": title,
          "Area": area,
          "ApartmentNo": apartmentNo,
          "Address": address,
          "Latitude": latitude,
          "Longitude": longitude,
        },
        token: token,
      );

      log('createRealeState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('createRealeState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editRealState({
    required String token,
    required int id,
    required String title,
    required String? area,
    required String? apartmentNo,
    required String? address,
    required String? latitude,
    required String? longitude,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.editRealState,
        data: {
          "Id": id,
          "Title": title,
          "Area": area,
          "ApartmentNo": apartmentNo,
          "Address": address,
          "Latitude": latitude,
          "Longitude": longitude,
        },
        token: token,
      );

      log('editRealState() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        return null;
      }
    } catch (e) {
      log('editRealState() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future promoCode({
    required String token,
    required String code,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.promoCode,
        data: {
          "Code": code,
        },
        token: token,
      );

      log('promoCode() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        return null;
      }
    } catch (e) {
      log('promoCode() [ ERROR ] -> $e');
      return null;
    }
  }

  // * Products By Id
  static ProfileModel? profileModel;
  static Future<ProfileModel?> getProfileData({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.getProfile,
        token: token,
      );

      log('getProfileData() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        profileModel = ProfileModel.fromJson(body);
        return profileModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getProfileData() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String image,
    required String email,
  }) async {
    try {
      final response = await HttpHelper.postData(
          query: EndPoints.editProfile,
          token: token,
          data: {
            "email": email,
            "firstname": firstName,
            "lastname": lastName,
            "profileImage": image,
          });

      log('editProfile() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
    } catch (e) {
      log('editProfile() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await HttpHelper.postData(
          query: EndPoints.changedPassword,
          token: token,
          data: {
            "OldPassword": oldPassword,
            "Password": newPassword,
          });

      log('changePassword() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
    } catch (e) {
      log('changePassword() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editPhone({
    required String token,
    required String phone,
  }) async {
    try {
      final response = await HttpHelper.postData(
          query: EndPoints.changedPhone,
          token: token,
          data: {
            "phone": phone,
          });

      log('editProfile() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (body['status'] == true) {
        return true;
      } else if (body['message'] == 'exist') {
        return false;
      } else {
        return 'The Phone Number is Exist';
      }
    } catch (e) {
      log('editProfile() [ ERROR ] -> $e');
      return false;
    }
  }

  static Future deleteAccount({
    required String token,
  }) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.deleteAccount,
        token: token,
      );

      log('deleteAccount() [ STATUS ] -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('deleteAccount() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future getAboutUs() async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.about,
      );

      log('getAboutUs() [ Status ] : ${response.statusCode} ');

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        log('Somthing Error');
      }
    } catch (e) {
      log('getAboutUs() [ Error ] : $e ');
    }
  }

  static Future getPrivacy() async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.privacy,
      );

      log('getPrivacy() [ Status ] : ${response.statusCode} ');

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return [body['pageName'], body['pageDescription']];
      } else {
        log('Somthing Error');
      }
    } catch (e) {
      log('getPrivacy() [ Error ] : $e ');
    }
  }

  static Future getTerms() async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.terms,
      );

      log('getTerms() [ Status ] : ${response.statusCode} ');

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return [body['pageName'], body['pageDescription']];
      } else {
        log('Somthing Error');
      }
    } catch (e) {
      log('getTerms() [ Error ] : $e ');
    }
  }

  static Future cancelOrder({
    required String token,
    required String orderId,
    required String note,
  }) async {
    try {
      final response = await HttpHelper.postData(
          query: EndPoints.cancelOrder,
          token: token,
          data: {
            "OrderId": orderId,
            "note": note,
          });

      log('cancelOrder() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('cancelOrder() [ ERROR ] -> $e');
      return false;
    }
  }
}
