import 'dart:convert';
import 'dart:developer';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/active_ticket_model.dart';
import 'package:wefix/Data/model/booking_details_model.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';

class BookingApi {
  static TicketModel? ticketModel;
  static Future getBookingsHistory({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.booking,
        token: token,
      );

      log('getBookingsHistory() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        ticketModel = TicketModel.fromJson(body);

        return ticketModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getBookingsHistory() [ ERROR ] -> $e');
      return [];
    }
  }

  static ActiveTicketModel? ticketActiveModel;
  static Future getActiveTicket({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.activeTickets,
        token: token,
      );

      log('getActiveTicket() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        ticketActiveModel = ActiveTicketModel.fromJson(body);

        return ticketActiveModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getActiveTicket() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future cancleBooking({required String token, int? id}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.cancleBooking,
        data: {"id": id},
        token: token,
      );

      log('cancleBooking() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        return [];
      }
    } catch (e) {
      log('cancleBooking() [ ERROR ] -> $e');
      return [];
    }
  }

  static BookingDetailsModel? bookingDetailsModel;
  static Future getBookingDetails(
      {required String token, required String id}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.bookingDetails + id,
        token: token,
      );

      log('getBookingDetails() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        bookingDetailsModel = BookingDetailsModel.fromJson(body);
        return bookingDetailsModel;
      } else {
        return [];
      }
    } catch (e) {
      log('getBookingDetails() [ ERROR ] -> $e');
      return [];
    }
  }

  static PackagesModel? packageModel;
  static Future getPackagesDetails({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.packages,
        token: token,
      );

      log('getPackagesDetails() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        packageModel = PackagesModel.fromJson(body);
        if (packageModel?.packages.isNotEmpty ?? false) {
          return packageModel;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      log('getPackagesDetails() [ ERROR ] -> $e');
      return [];
    }
  }

  static Future subsicribeNow({required String token, int? id}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.subscribe,
        data: {
          "PackageId": id,
        },
        token: token,
      );

      log('subsicribeNow() [ STATUS ] -> ${response.statusCode}');

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return [];
      }
    } catch (e) {
      log('subsicribeNow() [ ERROR ] -> $e');
      return [];
    }
  }
}
