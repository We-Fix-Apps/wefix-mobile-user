import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/appitment_model.dart';

class CreateOrderApi {
  static AppointmentModel? appointmentModel;
  static Future requestService(
      {required String token, required Map data}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.createOrder,
        token: token,
        data: {
          "TicketTypeId": data['TicketTypeId'],
          "PromoCode": data['PromoCode'],
          "SelectedDate": data['SelectedDate'],
          "SelectedDateTime": data['SelectedDateTime'],
          "Description": data['Description'],
          "Location": data['Location'],
          'Latitude': data['Latitude'],
          'Longitude': data['Longitude'],
          "IsWithFemale": data["IsWithFemale"], 
          "IsWithMaterial": data["IsWithMaterial"],
          "CustomerPackageId": data["CustomerPackageId"],
          "TotalPrice": data["TotalPrice"],
          "ServiceTicket": data["ServiceTicket"],
          "Attachments": data["Attachments"],
          "RealEstateId": data["RealEstateId"],
        },
      );

      log('requestService() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        appointmentModel = AppointmentModel.fromJson(body);

        return appointmentModel;
      } else {
        return null;
      }
    } catch (e) {
      log('requestService() [ ERROR ] -> $e');
      return null;
    }
  }
}
