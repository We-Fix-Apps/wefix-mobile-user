import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Api/auth_helper.dart';
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

  // * MMS API - Create ticket
  static Future<Map<String, dynamic>?> createTicketInMMS({
    required String token,
    required Map<String, dynamic> ticketData,
    BuildContext? context,
  }) async {
    try {
      log('createTicketInMMS: Sending payload: $ticketData');
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCreateTicket,
        token: token,
        data: ticketData,
        headers: {'x-client-type': 'mobile'},
        context: context,
      );

      log('createTicketInMMS: Response Status: ${response.statusCode}');
      log('createTicketInMMS: Response Body: ${response.body}');

      final body = json.decode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return body['data'];
      } else {
        // Log the error response for debugging
        log('createTicketInMMS failed: Status ${response.statusCode}, Body: ${response.body}');
        // Return error details if available
        if (body['message'] != null) {
          throw Exception(body['message'] as String);
        }
        return null;
      }
    } catch (e) {
      log('createTicketInMMS exception: $e');
      rethrow; // Re-throw to show actual error in UI
    }
  }

  // * MMS API - Update ticket
  static Future<Map<String, dynamic>?> updateTicketInMMS({
    required String token,
    required int ticketId,
    required Map<String, dynamic> ticketData,
    BuildContext? context,
  }) async {
    try {
      final query = EndPoints.mmsBaseUrl + EndPoints.mmsUpdateTicket + ticketId.toString();
      
      // Use HttpHelper.putData2 if available, otherwise use http.put directly
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Connection': 'keep-alive',
        'Authorization': 'Bearer $token',
        'x-client-type': 'mobile',
      };
      
      final response = await http.put(
        Uri.parse(query),
        body: jsonEncode(ticketData),
        headers: headers,
      );

      final body = json.decode(response.body);

      // Check for auth errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthHelper.handleAuthError(context, isMMS: true);
      }

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get company contracts
  static Future<List<Map<String, dynamic>>?> getCompanyContracts({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyContracts,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get company branches
  static Future<List<Map<String, dynamic>>?> getCompanyBranches({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyBranches,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get company zones
  static Future<List<Map<String, dynamic>>?> getCompanyZones({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyZones,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get main services
  static Future<List<Map<String, dynamic>>?> getMainServices({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsMainServices,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get sub services
  static Future<List<Map<String, dynamic>>?> getSubServices({
    required String token,
    int? parentServiceId,
    BuildContext? context,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsSubServices;
      if (parentServiceId != null) {
        query += '?parentServiceId=$parentServiceId';
      }
      
      final response = await HttpHelper.getData2(
        query: query,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get company team leaders
  static Future<List<Map<String, dynamic>>?> getCompanyTeamLeaders({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyTeamLeaders,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get company technicians
  static Future<List<Map<String, dynamic>>?> getCompanyTechnicians({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCompanyTechnicians,
        token: token,
        context: context,
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // * MMS API - Get ticket types
  static Future<List<Map<String, dynamic>>?> getTicketTypes({
    required String token,
    BuildContext? context,
  }) async {
    try {
      log('getTicketTypes: Fetching from ${EndPoints.mmsBaseUrl + EndPoints.mmsTicketTypes}');
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsTicketTypes,
        token: token,
        context: context,
      );
      log('getTicketTypes: Response status: ${response.statusCode}');
      final body = json.decode(response.body);
      log('getTicketTypes: Response body: $body');
      if (response.statusCode == 200 && body['success'] == true) {
        final data = List<Map<String, dynamic>>.from(body['data'] ?? []);
        log('getTicketTypes: Returning ${data.length} ticket types');
        return data;
      } else {
        log('getTicketTypes: Failed - status: ${response.statusCode}, success: ${body['success']}');
        return null;
      }
    } catch (e) {
      log('getTicketTypes: Exception: $e');
      return null;
    }
  }

  // * MMS API - Upload multiple files
  static Future<List<int>?> uploadFilesToMMS({
    required String token,
    required List<String> filePaths, // List of file paths (images, audio, documents)
    BuildContext? context,
    required int ticketId, // Ticket ID to link files to (required for entity_id)
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(EndPoints.mmsBaseUrl + EndPoints.mmsUploadFiles),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-client-type'] = 'mobile';

      // Add ticket ID as referenceId (required for entity_id in database)
      request.fields['referenceId'] = ticketId.toString();
      request.fields['referenceType'] = 'TICKET_ATTACHMENT';

      // Add files to the request with metadata
      int fileIndex = 0;
      for (var filePath in filePaths) {
        final file = File(filePath);
        if (file.existsSync()) {
          // Get file stats
          final fileStats = await file.stat();
          final fileSizeBytes = fileStats.size;
          final fileSizeMB = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);
          
          // Get file extension
          final fileExtension = filePath.split('.').last.toLowerCase();
          
          // Determine file type
          String fileType;
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExtension)) {
            fileType = 'image';
          } else if (fileExtension == 'pdf') {
            fileType = 'pdf';
          } else if (['doc', 'docx'].contains(fileExtension)) {
            fileType = 'doc';
          } else if (['xls', 'xlsx'].contains(fileExtension)) {
            fileType = 'excel';
          } else if (['mp4', 'avi', 'mov', 'wmv'].contains(fileExtension)) {
            fileType = 'video';
          } else if (['mp3', 'wav', 'm4a', 'aac'].contains(fileExtension)) {
            fileType = 'audio';
          } else {
            fileType = 'other';
          }
          
          // Add file
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );
          
          // Add file metadata as fields (indexed by file)
          request.fields['fileMetadata[$fileIndex][extension]'] = fileExtension;
          request.fields['fileMetadata[$fileIndex][sizeMB]'] = fileSizeMB;
          request.fields['fileMetadata[$fileIndex][type]'] = fileType;
          request.fields['fileMetadata[$fileIndex][path]'] = filePath;
          request.fields['fileMetadata[$fileIndex][storageProvider]'] = 'LOCAL';
          request.fields['fileMetadata[$fileIndex][description]'] = '';
          
          fileIndex++;
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = json.decode(response.body);

      // Check for auth errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthHelper.handleAuthError(context, isMMS: true);
        return null;
      }

      if (response.statusCode == 201 && body['success'] == true) {
        // Extract file IDs from the response
        final files = body['data'] as List?;
        if (files != null) {
          return files.map<int>((file) => file['id'] as int).toList();
        }
        return null;
      } else {
        log('uploadFilesToMMS: Failed - status: ${response.statusCode}, body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('uploadFilesToMMS: Exception: $e');
      return null;
    }
  }
}
