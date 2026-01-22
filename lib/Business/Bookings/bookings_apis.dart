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
            final ticketDate = ticket['ticketDate'] != null ? DateTime.parse(ticket['ticketDate']) : DateTime.now();

            return Ticket(
              id: ticket['id'] ?? 0,
              customerId: 0, // Not available from MMS
              statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
              ticketTypeId: ticket['ticketType']?['id'] ?? 0,
              rating: ticket['rating'],
              icon: ticket['mainService']?['image'] ?? ticket['mainService']?['icon'] ?? null, // Main service image
              mainServiceTitle: ticket['mainService']?['name'] ?? null, // Main service name (English)
              mainServiceNameArabic: ticket['mainService']?['nameArabic'] ?? null, // Main service name (Arabic)
              ticketCodeId: ticket['ticketCodeId']?.toString() ?? null,
              cancelButton: ticket['canCancel'],
              isRated: ticket['isRated'],
              type: ticket['ticketType']?['name'],
              serviceprovideImage: ticket['technician']?['profileImage'] ?? null,
              promoCode: null,
              requestedDate: ticketDate,
              selectedDate: ticketDate,
              selectedDateTime: ticket['ticketTimeFrom'] != null && ticket['ticketTimeTo'] != null ? '${ticket['ticketTimeFrom']} - ${ticket['ticketTimeTo']}' : null,
              timeFrom: ticket['ticketTimeFrom'],
              timeTo: ticket['ticketTimeTo'],
              teamNo: null,
              status: ticket['ticketStatus']?['name'] ?? 'Pending',
              location: ticket['ticketTitle'] ?? '',
              longitude: null,
              latitude: null,
              gender: null,
              isWithMaterial: ticket['withMaterial'] ?? false,
              priority: null,
              createdBy: 0,
              customerPackageId: null,
              totalPrice: (ticket['totalPrice'] as num?)?.toDouble() ?? 0.0,
              serviceprovide: ticket['technician']?['name'] ?? null, // Keep for backward compatibility
              serviceprovideName: ticket['technician']?['name'] ?? null, // Technician name (Arabic)
              serviceprovideNameEnglish: ticket['technician']?['nameEnglish'] ?? null, // Technician name (English)
              description: ticket['ticketDescription'] ?? '',
              descriptionAr: ticket['ticketDescription'] ?? '',
              delegatedToCompanyId: ticket['delegatedToCompanyId'],
              delegatedToCompanyTitle: ticket['delegatedToCompany']?['title'] ?? null,
              companyId: ticket['companyId'],
              companyTitle: ticket['company']?['title'] ?? null, // Keep for fallback
              companyNameArabic: ticket['company']?['nameArabic'] ?? null, // Company name in Arabic
              companyNameEnglish: ticket['company']?['nameEnglish'] ?? null, // Company name in English
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
      log('getBookingsHistory exception: $e');
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
  static Future getBookingDetails({required String token, required String id, bool isCompanyAdmin = false}) async {
    try {
      // Use MMS endpoint for company admin, OMS endpoint for regular users
      final url = isCompanyAdmin ? EndPoints.mmsBaseUrl + EndPoints.mmsTicketDetails + id : EndPoints.bookingDetails + id;

      final response = isCompanyAdmin
          ? await HttpHelper.getData2(
              query: url,
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
            final ticketDate = ticketData['ticketDate'] != null ? DateTime.parse(ticketData['ticketDate']).toIso8601String() : DateTime.now().toIso8601String();

            // Calculate estimated time from time slot (ticketTimeFrom and ticketTimeTo)
            String estimatedTime = '';
            if (ticketData['ticketTimeFrom'] != null && ticketData['ticketTimeTo'] != null) {
              try {
                final timeFrom = ticketData['ticketTimeFrom'].toString();
                final timeTo = ticketData['ticketTimeTo'].toString();

                // Parse time strings (format: "HH:MM:SS" or "HH:MM")
                final fromParts = timeFrom.split(':');
                final toParts = timeTo.split(':');

                if (fromParts.length >= 2 && toParts.length >= 2) {
                  final fromHour = int.tryParse(fromParts[0]) ?? 0;
                  final fromMinute = int.tryParse(fromParts[1]) ?? 0;
                  final toHour = int.tryParse(toParts[0]) ?? 0;
                  final toMinute = int.tryParse(toParts[1]) ?? 0;

                  // Calculate difference in minutes
                  final fromTotalMinutes = fromHour * 60 + fromMinute;
                  final toTotalMinutes = toHour * 60 + toMinute;
                  final diffMinutes = toTotalMinutes - fromTotalMinutes;

                  // Convert to hours (if >= 60 minutes, show as hours)
                  if (diffMinutes >= 60) {
                    final hours = diffMinutes ~/ 60;
                    final minutes = diffMinutes % 60;
                    if (minutes > 0) {
                      estimatedTime = '$hours.${(minutes / 60 * 10).round()}';
                    } else {
                      estimatedTime = hours.toString();
                    }
                  } else {
                    estimatedTime = (diffMinutes / 60).toStringAsFixed(1);
                  }
                }
              } catch (e) {
                log('Error calculating estimated time: $e');
                estimatedTime = '2'; // Default to 2 hours if calculation fails
              }
            } else {
              estimatedTime = '2'; // Default to 2 hours if time slot not available
            }

            final bookingDetails = {
              'objTickets': {
                // Basic ticket info
                'id': ticketData['id'] ?? 0,
                'title': ticketData['ticketTitle'] ?? '',
                'titleAr': ticketData['ticketTitle'] ?? '',
                'type': ticketData['ticketType']?['name']?.toLowerCase() ?? 'preventive',
                'typeAr': ticketData['ticketType']?['nameArabic']?.toLowerCase() ?? '',
                'date': ticketData['ticketDate'] ?? '',
                'status': ticketData['ticketStatus']?['name'] ?? 'Pending',
                'statusAr': ticketData['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',

                // Price and user info
                'totalPrice': null, // Not in API response
                'userId': null, // Not in API response

                // Customer info
                'customerName': ticketData['customerName'] ?? '',
                'customerImage': '', // Not in API response
                'customerAddress': ticketData['ticketTitle'] ?? '',

                // Location info (from locationMap)
                'latitudel': '', // Extract from locationMap URL if needed
                'longitude': '', // Extract from locationMap URL if needed
                'mobile': '', // Not in API response

                // Ticket details
                'description': ticketData['ticketDescription'] ?? '',
                'isWithFemale': ticketData['havingFemaleEngineer'] ?? false,
                'isWithMaterial': ticketData['withMaterial'] ?? false,

                // Time info
                'esitmatedTime': '${ticketData['ticketTimeFrom'] ?? ''} - ${ticketData['ticketTimeTo'] ?? ''}',

                // QR and report
                'qrCodePath': '', // Not in API response
                'qrCode': '', // Not in API response
                'reportLink': '', // Not in API response
                'isRated': false, // Not in API response

                // Tools (already empty in API)
                'ticketTools': (ticketData['tools'] as List?)?.map((tool) {
                      if (tool is Map) {
                        return {
                          'id': tool['id'] ?? 0,
                          'title': tool['title'] ?? '',
                          'titleAr': tool['titleAr'] ?? '',
                        };
                      } else {
                        return {'id': tool, 'title': 'Tool $tool', 'titleAr': 'أداة $tool'};
                      }
                    }).toList() ??
                    [],

                // Materials (not in API response)
                'ticketMaterials': [],

                // Ticket categories (not in API response)
                'maintenanceTickets': [],
                'servcieTickets': [],
                'advantageTickets': [],

                // Files and attachments
                'ticketAttatchments': (ticketData['files'] as List?)?.map((file) {
                      return {
                        'filePath': file['filePath'] ?? '',
                        'fileName': file['fileName'] ?? '',
                        'category': file['category'] ?? '',
                      };
                    }).toList() ??
                    [],

                // Extract only image files
                'ticketImages': (ticketData['files'] as List?)
                        ?.where((file) {
                          final category = file['category']?.toString().toLowerCase() ?? '';
                          return category == 'image';
                        })
                        .map((file) => file['filePath'] ?? '')
                        .toList() ??
                    [],

                // Additional fields from API
                'ticketCodeId': ticketData['ticketCodeId'] ?? '',
                'companyId': ticketData['companyId'] ?? 0,
                'contractId': ticketData['contractId'] ?? 0,
                'branchId': ticketData['branchId'] ?? 0,
                'branchName': ticketData['branch']?['title'] ?? '',
                'branchNameArabic': ticketData['branch']?['nameArabic'] ?? '',
                'zoneId': ticketData['zoneId'] ?? 0,
                'locationMap': ticketData['locationMap'] ?? '',
                'teamLeader': ticketData['teamLeader'] != null
                    ? {
                        'id': ticketData['teamLeader']['id'] ?? 0,
                        'name': ticketData['teamLeader']['name'] ?? '',
                        'userNumber': ticketData['teamLeader']['userNumber'] ?? '',
                        'profileImage': ticketData['teamLeader']['profileImage'] ?? '',
                      }
                    : null,
                'technician': ticketData['technician'] != null
                    ? {
                        'id': ticketData['technician']['id'] ?? 0,
                        'name': ticketData['technician']['name'] ?? '',
                        'userNumber': ticketData['technician']['userNumber'] ?? '',
                        'profileImage': ticketData['technician']['profileImage'] ?? '',
                      }
                    : null,
                'source': ticketData['source'] ?? '',
                'createdAt': ticketData['createdAt'] ?? '',
                'updatedAt': ticketData['updatedAt'] ?? '',
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

  static Future subsicribeNow({required String token, int? id, String? age, String? area, String? price}) async {
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
      final response = await HttpHelper.postData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsCreateTicket,
        token: token,
        data: ticketData,
        headers: {'x-client-type': 'mobile'},
        context: context,
      );

      final body = json.decode(response.body);

      // Check for auth errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthHelper.handleAuthError(context, isMMS: true);
        return null;
      }

      if (response.statusCode == 201 && body['success'] == true) {
        return body['data'];
      } else {
        // Extract error message from different possible locations
        String errorMessage = 'Failed to create ticket';
        List<String> missingFields = [];

        // Try to extract detailed error information
        if (body['error'] != null) {
          if (body['error'] is Map) {
            final errorMap = body['error'] as Map;
            if (errorMap['message'] != null) {
              errorMessage = errorMap['message'].toString();
            }
            // Check for validation errors with field names
            if (errorMap['details'] != null) {
              final details = errorMap['details'];
              if (details is Map) {
                // Extract field-level errors
                details.forEach((key, value) {
                  if (value != null) {
                    missingFields.add(key.toString());
                  }
                });
              } else if (details is List) {
                // Extract error messages from array
                missingFields.addAll(details.map((e) => e.toString()).toList());
              }
            }
            // Check for missingFields array
            if (errorMap['missingFields'] != null && errorMap['missingFields'] is List) {
              missingFields.addAll((errorMap['missingFields'] as List).map((e) => e.toString()).toList());
            }
          } else if (body['error'] is String) {
            errorMessage = body['error'] as String;
          }
        } else if (body['message'] != null) {
          errorMessage = body['message'].toString();
        }

        // Check for validation errors in body directly
        if (body['validationErrors'] != null && body['validationErrors'] is Map) {
          final validationErrors = body['validationErrors'] as Map;
          validationErrors.forEach((key, value) {
            if (value != null) {
              missingFields.add(key.toString());
            }
          });
        }

        // Check for errors array in body
        if (body['errors'] != null && body['errors'] is List) {
          final errors = body['errors'] as List;
          missingFields.addAll(errors.map((e) => e.toString()).toList());
        }

        // Build detailed error message
        if (missingFields.isNotEmpty) {
          errorMessage = 'Missing required fields: ${missingFields.join(', ')}';
        }

        // Show error message to user
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      // Only rethrow if it's not already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create ticket: $e');
    }
  }

  // * MMS API - Update ticket
  // Only Company Admin (18) and Team Leader (20) can update tickets
  // Rejects unauthorized updates with clear error messages
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

      // Check for auth/authorization errors
      if (response.statusCode == 401) {
        // Unauthorized - token expired or invalid
        await AuthHelper.handleAuthError(context, isMMS: true);
        return null;
      } else if (response.statusCode == 403) {
        // Forbidden - user doesn't have permission to update tickets
        // Only Company Admins and Team Leaders can update tickets
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'You do not have permission to update tickets. Only Company Admins and Team Leaders can update tickets.'),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return null;
      } else if (response.statusCode == 404) {
        // Ticket not found or access denied
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Ticket not found or you do not have access to update this ticket.'),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return null;
      } else if (response.statusCode == 400) {
        // Validation error

        // Extract error message from different possible locations
        String errorMessage = 'Invalid ticket data. Please check all fields.';

        if (body['error'] != null) {
          if (body['error'] is Map && body['error']['message'] != null) {
            errorMessage = body['error']['message'] as String;
          } else if (body['error'] is String) {
            errorMessage = body['error'] as String;
          }
        } else if (body['message'] != null) {
          errorMessage = body['message'] as String;
        }

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.orange[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return null;
      }

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data'];
      } else {
        // Extract error message from different possible locations
        String errorMessage = 'Failed to update ticket';

        if (body['error'] != null) {
          if (body['error'] is Map && body['error']['message'] != null) {
            errorMessage = body['error']['message'] as String;
          } else if (body['error'] is String) {
            errorMessage = body['error'] as String;
          }
        } else if (body['message'] != null) {
          errorMessage = body['message'] as String;
        }

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      log('Update ticket exception: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ticket: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return null;
    }
  }

  // * MMS API - Get company contracts
  static Future<List<Map<String, dynamic>>?> getCompanyContracts({
    required String token,
    BuildContext? context,
    int? ticketId,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsCompanyContracts;
      if (ticketId != null) {
        query += '?ticketId=$ticketId';
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

  // * MMS API - Get company branches
  static Future<List<Map<String, dynamic>>?> getCompanyBranches({
    required String token,
    BuildContext? context,
    int? ticketId,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsCompanyBranches;
      if (ticketId != null) {
        query += '?ticketId=$ticketId';
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

  // * MMS API - Get company zones
  // Optionally filter by branchId if provided
  // Optionally filter by ticketId - if provided and ticket is delegated, get zones from delegated company
  static Future<List<Map<String, dynamic>>?> getCompanyZones({
    required String token,
    BuildContext? context,
    int? branchId,
    int? ticketId,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsCompanyZones;
      List<String> queryParams = [];
      if (branchId != null) {
        queryParams.add('branchId=$branchId');
      }
      if (ticketId != null) {
        queryParams.add('ticketId=$ticketId');
      }
      if (queryParams.isNotEmpty) {
        query += '?${queryParams.join('&')}';
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

  // * MMS API - Get main services
  static Future<List<Map<String, dynamic>>?> getMainServices({
    required String token,
    BuildContext? context,
    int? contractId,
    int? ticketId,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsMainServices;
      List<String> queryParams = [];
      if (contractId != null) {
        queryParams.add('contractId=$contractId');
      }
      if (ticketId != null) {
        queryParams.add('ticketId=$ticketId');
      }
      if (queryParams.isNotEmpty) {
        query += '?${queryParams.join('&')}';
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

  // * MMS API - Get sub services
  static Future<List<Map<String, dynamic>>?> getSubServices({
    required String token,
    int? parentServiceId,
    BuildContext? context,
    int? contractId,
  }) async {
    try {
      String query = EndPoints.mmsBaseUrl + EndPoints.mmsSubServices;
      List<String> queryParams = [];
      if (parentServiceId != null) {
        queryParams.add('parentServiceId=$parentServiceId');
      }
      if (contractId != null) {
        queryParams.add('contractId=$contractId');
      }
      if (queryParams.isNotEmpty) {
        query += '?${queryParams.join('&')}';
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
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsTicketTypes,
        token: token,
        context: context,
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final data = List<Map<String, dynamic>>.from(body['data'] ?? []);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      log('getTicketTypes: Exception: $e');
      return null;
    }
  }

  // * MMS API - Get ticket statuses
  static Future<List<Map<String, dynamic>>?> getTicketStatuses({
    required String token,
    BuildContext? context,
  }) async {
    try {
      final response = await HttpHelper.getData2(
        query: EndPoints.mmsBaseUrl + EndPoints.mmsTicketStatuses,
        token: token,
        context: context,
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        final data = List<Map<String, dynamic>>.from(body['data'] ?? []);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      log('getTicketStatuses: Exception: $e');
      return null;
    }
  }

  // * MMS API - Upload multiple files
  static Future<List<String>?> uploadFilesToMMS({
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

      // Add entity fields for legacy database columns
      // For ticket attachments, use 'ticket' as entityType (now supported in enum)
      request.fields['entityId'] = ticketId.toString();
      request.fields['entityType'] = 'ticket'; // Use 'ticket' for ticket attachments

      // Add files to the request with metadata
      int fileIndex = 0;
      for (var filePath in filePaths) {
        final file = File(filePath);
        if (file.existsSync()) {
          // Get file stats
          final fileStats = await file.stat();
          final fileSizeBytes = fileStats.size;
          final fileSizeMB = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

          // Get original filename from path
          final originalFilename = filePath.split('/').last;

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

          // Determine category (legacy field)
          String category;
          if (fileType == 'image') {
            category = 'image';
          } else if (fileType == 'pdf') {
            category = 'document';
          } else if (fileType == 'doc' || fileType == 'excel') {
            category = 'document';
          } else if (fileType == 'video') {
            category = 'video';
          } else if (fileType == 'audio') {
            category = 'audio';
          } else {
            category = 'other';
          }

          // Determine MIME type
          String mimeType;
          if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
            mimeType = 'image/jpeg';
          } else if (fileExtension == 'png') {
            mimeType = 'image/png';
          } else if (fileExtension == 'gif') {
            mimeType = 'image/gif';
          } else if (fileExtension == 'bmp') {
            mimeType = 'image/bmp';
          } else if (fileExtension == 'webp') {
            mimeType = 'image/webp';
          } else if (fileExtension == 'pdf') {
            mimeType = 'application/pdf';
          } else if (fileExtension == 'doc') {
            mimeType = 'application/msword';
          } else if (fileExtension == 'docx') {
            mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          } else if (fileExtension == 'xls') {
            mimeType = 'application/vnd.ms-excel';
          } else if (fileExtension == 'xlsx') {
            mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          } else if (fileExtension == 'mp4') {
            mimeType = 'video/mp4';
          } else if (fileExtension == 'avi') {
            mimeType = 'video/x-msvideo';
          } else if (fileExtension == 'mov') {
            mimeType = 'video/quicktime';
          } else if (fileExtension == 'mp3') {
            mimeType = 'audio/mpeg';
          } else if (fileExtension == 'wav') {
            mimeType = 'audio/wav';
          } else if (fileExtension == 'm4a') {
            mimeType = 'audio/mp4';
          } else if (fileExtension == 'aac') {
            mimeType = 'audio/aac';
          } else {
            mimeType = 'application/octet-stream';
          }

          // Add file
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path),
          );

          // Add file metadata as fields (indexed by file) - for new columns
          request.fields['fileMetadata[$fileIndex][extension]'] = fileExtension;
          request.fields['fileMetadata[$fileIndex][sizeMB]'] = fileSizeMB;
          request.fields['fileMetadata[$fileIndex][type]'] = fileType;
          request.fields['fileMetadata[$fileIndex][path]'] = filePath;
          request.fields['fileMetadata[$fileIndex][storageProvider]'] = 'LOCAL';
          request.fields['fileMetadata[$fileIndex][description]'] = '';

          // Add legacy column fields (indexed by file)
          request.fields['fileMetadata[$fileIndex][originalFilename]'] = originalFilename;
          request.fields['fileMetadata[$fileIndex][mimeType]'] = mimeType;
          request.fields['fileMetadata[$fileIndex][size]'] = fileSizeBytes.toString();
          request.fields['fileMetadata[$fileIndex][category]'] = category;
          request.fields['fileMetadata[$fileIndex][entityType]'] = 'ticket'; // Use 'ticket' for ticket attachments
          request.fields['fileMetadata[$fileIndex][entityId]'] = ticketId.toString();

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
        // Extract file IDs from the response (UUIDs as strings)
        final files = body['data'] as List?;
        if (files != null) {
          return files.map<String>((file) => file['id'].toString()).toList();
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      log('uploadFilesToMMS: Exception: $e');
      return null;
    }
  }
}
