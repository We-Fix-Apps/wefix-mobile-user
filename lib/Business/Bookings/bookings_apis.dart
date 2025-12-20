import 'dart:convert';

import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/http_request.dart';
import 'package:wefix/Data/model/active_ticket_model.dart' hide Ticket;
import 'package:wefix/Data/model/advantages_model.dart';
import 'package:wefix/Data/model/booking_details_model.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';

class BookingApi {
  static TicketModel? ticketModel;
  static Future<TicketModel?> getBookingsHistory({required String token, bool isCompanyAdmin = false}) async {
    try {
      // If company admin, use MMS endpoint
      if (isCompanyAdmin) {
        final ticketsData = await getCompanyTicketsFromMMS(token: token);
        
        if (ticketsData != null) {
          // Convert MMS tickets format to TicketModel format
          final allTickets = ticketsData['all']?['tickets'] ?? [];
          final tickets = allTickets.map<Ticket>((ticket) {
            final ticketDate = ticket['ticketDate'] != null
                ? DateTime.parse(ticket['ticketDate'])
                : DateTime.now();
            
            return Ticket(
              id: ticket['id'] ?? 0,
              customerId: 0, // Not available from MMS
              statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
              ticketTypeId: ticket['ticketType']?['id'] ?? 0,
              rating: null,
              icon: null,
              cancelButton: null,
              isRated: null,
              type: ticket['ticketType']?['name'],
              serviceprovideImage: null,
              promoCode: null,
              requestedDate: ticketDate,
              selectedDate: ticketDate,
              selectedDateTime: ticket['ticketTimeFrom'] != null && ticket['ticketTimeTo'] != null
                  ? '${ticket['ticketTimeFrom']} - ${ticket['ticketTimeTo']}'
                  : null,
              timeFrom: ticket['ticketTimeFrom'],
              timeTo: ticket['ticketTimeTo'],
              teamNo: null,
              status: ticket['ticketStatus']?['name'] ?? 'Pending',
              location: ticket['locationDescription'] ?? '',
              longitude: null,
              latitude: null,
              gender: null,
              isWithMaterial: ticket['withMaterial'] ?? false,
              priority: null,
              createdBy: 0,
              customerPackageId: null,
              totalPrice: 0.0,
              serviceprovide: ticket['technician']?['name'] ?? null,
              description: ticket['ticketDescription'] ?? '',
              descriptionAr: ticket['ticketDescription'] ?? '',
            );
          }).toList();

          ticketModel = TicketModel(tickets: tickets);
          return ticketModel;
        } else {
          ticketModel = TicketModel(tickets: []);
          return ticketModel;
        }
      } else {
        // Regular user - use OMS endpoint
      final response = await HttpHelper.getData(
        query: EndPoints.booking,
        token: token,
      );

        if (response.statusCode == 200) {
      final body = json.decode(response.body);
        ticketModel = TicketModel.fromJson(body);
        return ticketModel;
      } else {
          ticketModel = TicketModel(tickets: []);
          return ticketModel;
        }
      }
    } catch (e) {
      ticketModel = TicketModel(tickets: []);
      return ticketModel;
    }
  }

  static ActiveTicketModel? ticketActiveModel;
  static Future<ActiveTicketModel?> getActiveTicket({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.activeTickets,
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        ticketActiveModel = ActiveTicketModel.fromJson(body);

        return ticketActiveModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future cancleBooking({required String token, int? id}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.cancleBooking,
        data: {"id": id},
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static BookingDetailsModel? bookingDetailsModel;
  static Future getBookingDetails(
      {required String token, required String id, bool isCompanyAdmin = false}) async {
    try {
      // Use MMS endpoint for company admin, OMS endpoint for regular users
      final response = isCompanyAdmin
          ? await HttpHelper.getData2(
              query: EndPoints.mmsBaseUrl + EndPoints.mmsTicketDetails + id,
              token: token,
            )
          : await HttpHelper.getData(
        query: EndPoints.bookingDetails + id,
        token: token,
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        
        if (isCompanyAdmin) {
          // Handle MMS response format
          if (body['success'] == true && body['data'] != null) {
            // Convert MMS ticket format to BookingDetailsModel format
            final ticketData = body['data'];
            final ticketDate = ticketData['ticketDate'] != null
                ? DateTime.parse(ticketData['ticketDate']).toIso8601String()
                : DateTime.now().toIso8601String();
            
            final bookingDetails = {
              'objTickets': {
                'id': ticketData['id'] ?? 0,
                'title': ticketData['mainService']?['name'] ?? '',
                'titleAr': ticketData['mainService']?['nameArabic'] ?? '',
                'type': ticketData['ticketType']?['name']?.toLowerCase() ?? 'preventive',
                'typeAr': ticketData['ticketType']?['nameArabic']?.toLowerCase() ?? '',
                'date': ticketDate,
                'status': ticketData['ticketStatus']?['name'] ?? 'Pending',
                'totalPrice': null,
                'userId': null,
                'customerName': ticketData['customerName'] ?? '',
                'customerImage': '',
                'customerAddress': ticketData['locationDescription'] ?? '',
                'isWithFemale': ticketData['havingFemaleEngineer'] ?? false,
                'latitudel': '',
                'longitude': '',
                'mobile': '',
                'description': ticketData['ticketDescription'] ?? '',
                'isWithMaterial': ticketData['withMaterial'] ?? false,
                'esitmatedTime': '',
                'qrCodePath': '',
                'qrCode': '',
                'reportLink': '',
                'isRated': false,
                'ticketAttatchments': [],
                'ticketImages': [],
                'ticketTools': (ticketData['tools'] as List?)?.map((tool) {
                      if (tool is Map) {
                        return tool;
                      } else {
                        // If tool is just an ID, convert to map format
                        return {'id': tool, 'title': 'Tool $tool', 'titleAr': 'أداة $tool'};
                      }
                    }).toList() ?? [],
                'ticketMaterials': [],
                'maintenanceTickets': [],
                'servcieTickets': [],
                'advantageTickets': [],
              }
            };
            bookingDetailsModel = BookingDetailsModel.fromJson(bookingDetails);
            return bookingDetailsModel;
          } else {
            return null;
          }
        } else {
          // Handle OMS response format (existing)
        bookingDetailsModel = BookingDetailsModel.fromJson(body);
        return bookingDetailsModel;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static AdvantagesModel? advantagesModel;
  static Future getAdvantages({required String token}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.advantages,
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        advantagesModel = AdvantagesModel.fromJson(body);
        return advantagesModel;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static PackagesModel? packageModel;
  static Future getPackagesDetails({required String token, String? id}) async {
    try {
      final response = await HttpHelper.getData(
        query: EndPoints.packages + "${id ?? ""}",
        token: token,
      );

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
      return [];
    }
  }

  static Future subsicribeNow(
      {required String token,
      int? id,
      String? age,
      String? area,
      String? price}) async {
    try {
      final response = await HttpHelper.postData(
        query: EndPoints.subscribe,
        data: {
          "PackageId": id,
          "Age": 0,
          "Area": area,
          "Price": price,
        },
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return body["status"];
      } else {
        return false;
      }
    } catch (e) {
      return [];
    }
  }

  // * MMS API - Get company tickets from backend-mms
  static Future<Map<String, dynamic>?> getCompanyTicketsFromMMS({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = '?page=$page&limit=$limit';
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsTickets + queryParams,
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get ticket statistics from backend-mms
  static Future<Map<String, dynamic>?> getTicketStatisticsFromMMS({required String token}) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsTicketStatistics,
        token: token,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
