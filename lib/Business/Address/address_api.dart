import 'dart:convert';
import 'dart:developer';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/address_model.dart';
import 'package:wefix/Data/model/all_products_model.dart';
import 'package:wefix/Data/model/shipping_info_model.dart';

class AddressApi {
  static AddressModel? addressModel;

  static Future<List<CustomerAddress>?> getAddress(
      {required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.address,
        token: token,
      );

      log('getAddress() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        addressModel = AddressModel.fromJson(body);
        if (addressModel?.customerAddress.isNotEmpty ?? false) {
          return addressModel!.customerAddress;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('getAddress() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future addAdress({required String token, required Map data}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.addAddress,
        token: token,
        data: {
          'IsDefault': data['IsDefault'],
          'Address': data['Address'],
          'Latitude': data['Latitude'],
          'Longitude': data['Longitude'],
          'AddressType': data['AddressType'],
        },
      );

      log('addAdress() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('addAdress() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future editAdress({required String token, required Map data}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.editAddress,
        token: token,
        data: {
          "customerAddressId": data["customerAddressId"],
          'Email': data['Email'],
          'FirstName': data['FirstName'],
          'Phone': data['Phone'],
          'City': data['City'],
          'LastName': data['LastName'],
          'Address': data['Address'],
          'Latitude': data['Latitude'],
          'Longitude': data['Longitude'],
          'Street': data['Street'],
          'Zipcode': data['Zipcode'],
          'Country': data['Country'],
          'State': data['State'],
          'HouseNumber': data['HouseNumber'],
          'AddressType': data['AddressType'],
          'isDefault': data['isDefault'],
        },
      );

      log('editAdress() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
      } else {
        return null;
      }
    } catch (e) {
      log('editAdress() [ ERROR ] -> $e');
      return null;
    }
  }

  static Future removeAddress(
      {required String token, required int customerAddressId}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.removeAddress,
        token: token,
        data: {
          "customerAddressId": customerAddressId,
        },
      );

      log('removeAddress() [ STATUS ] -> ${response.statusCode}');
    } catch (e) {
      log('removeAddress() [ ERROR ] -> $e');
      return null;
    }
  }

  static ShippingInfoModel? shippingInfoModel;
  static Future getShippingInfo(
      {required String token, required String? customerAddressId}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.getShippingInfo,
        token: token,
        data: {
          "CustomerAddressId": customerAddressId,
        },
      );

      log('getShippingInfo() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        shippingInfoModel = ShippingInfoModel.fromJson(body);
        return shippingInfoModel;
      } else {
        return null;
      }
    } catch (e) {
      log('getShippingInfo() [ ERROR ] -> $e');
      return null;
    }
  }
}
