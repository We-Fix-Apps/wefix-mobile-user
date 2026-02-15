import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/B2B/ticket/components/draggable_card_bottom_sheet.dart';
import 'package:wefix/Presentation/B2B/ticket/components/dropdown_card_item.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart' show UploadOptionsScreen;
import 'package:wefix/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:http/http.dart' as http;

class CreateUpdateTicketScreenV2 extends StatefulWidget {
  final Map<String, dynamic>? ticketData;
  final bool isTechnician; // If true, only allow status updates

  const CreateUpdateTicketScreenV2({super.key, this.ticketData, this.isTechnician = false});

  @override
  State<CreateUpdateTicketScreenV2> createState() => _CreateUpdateTicketScreenV2State();
}

class _CreateUpdateTicketScreenV2State extends State<CreateUpdateTicketScreenV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _tab1ScrollController = ScrollController();
  final ScrollController _tab2ScrollController = ScrollController();

  // GlobalKeys for scrolling to error fields
  final GlobalKey _contractKey = GlobalKey();
  final GlobalKey _branchKey = GlobalKey();
  final GlobalKey _zoneKey = GlobalKey();
  final GlobalKey _ticketTypeKey = GlobalKey();
  final GlobalKey _ticketTitleKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _teamLeaderKey = GlobalKey();
  final GlobalKey _technicianKey = GlobalKey();
  final GlobalKey _mainServiceKey = GlobalKey();
  final GlobalKey _subServiceKey = GlobalKey();
  final GlobalKey _serviceDescriptionKey = GlobalKey();

  bool isLoading = false;

  // Controllers
  final TextEditingController ticketTitle = TextEditingController();
  final TextEditingController serviceDescription = TextEditingController();
  final TextEditingController ticketDescription = TextEditingController();
  final TextEditingController materialsNote = TextEditingController();

  // State variable to store service description for summary tab
  String _serviceDescriptionText = '';

  // Selected items
  DropdownCardItem? selectedContract;
  DropdownCardItem? selectedBranch;
  DropdownCardItem? selectedZone;
  DropdownCardItem? selectedMainService;
  DropdownCardItem? selectedSubService;
  DropdownCardItem? selectedTeamLeader;
  DropdownCardItem? selectedTechnician;
  DropdownCardItem? selectedTicketStatus; // For editing only
  DropdownCardItem? selectedTicketType; // Selected ticket type

  // Validation state
  Map<String, String?> fieldErrors = {}; // Field name -> error message
  bool isTeamLeaderVisible = true; // Show/hide Team Leader DDL based on role
  bool isDelegatedToWeFix = false; // Track if ticket is delegated to WeFix (B2B business model)
  bool isWeFixUser = false; // Track if current user is from WeFix company (ID: 39)
  bool shouldHideAssignmentFields = false; // Single flag for hiding team leader/technician (following frontend-OMS pattern)
  
  // Toggle states
  bool withMaterial = false;
  bool withFemaleEngineer = false;

  // Materials list
  List<Map<String, dynamic>> materials = [];
  bool isLoadingMaterials = false;

  // Lists (these should be fetched from APIs)
  List<DropdownCardItem> contracts = [];
  List<DropdownCardItem> branches = [];
  List<DropdownCardItem> zones = [];
  List<DropdownCardItem> mainServices = [];
  List<DropdownCardItem> subServices = [];
  List<DropdownCardItem> teamLeaders = [];
  List<DropdownCardItem> technicians = [];
  List<DropdownCardItem> ticketStatuses = [];
  List<DropdownCardItem> ticketTypes = [];

  // Location and time
  LatLng? selectedLocation; // Store location coordinates
  String? selectedTimeFrom; // e.g., "08:00:00"
  String? selectedTimeTo; // e.g., "10:00:00"
  DateTime? selectedTicketDate;

  // Generate time slots from 8:00 to 18:00 in 2-hour intervals
  List<Map<String, String>> get allTimeSlots => [
        {'from': '08:00:00', 'to': '10:00:00', 'display': '8:00 - 10:00'},
        {'from': '10:00:00', 'to': '12:00:00', 'display': '10:00 - 12:00'},
        {'from': '12:00:00', 'to': '14:00:00', 'display': '12:00 - 14:00'},
        {'from': '14:00:00', 'to': '16:00:00', 'display': '14:00 - 16:00'},
        {'from': '16:00:00', 'to': '18:00:00', 'display': '16:00 - 18:00'},
      ];

  // Get available time slots based on current time
  // For emergency tickets on today: shows slots within 120 minutes from current time
  // For corrective/preventive tickets on today: shows all slots that haven't started yet
  // For future dates: shows all available slots (8:00-18:00)
  List<Map<String, String>> getAvailableTimeSlots() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTimeInMinutes = currentHour * 60 + currentMinute;
    final maxMinutes = currentTimeInMinutes + 120; // 120 minutes from now

    // Check if this is an emergency ticket
    final isEmergency = selectedTicketType?.title.toLowerCase() == 'emergency' || selectedTicketType?.data?['name']?.toString().toLowerCase() == 'emergency';

    // If no date is selected, show all slots
    if (selectedTicketDate == null) {
      return allTimeSlots;
    }

    // Compare dates by year, month, and day only (ignore time component)
    final selectedDateOnly = DateTime(
      selectedTicketDate!.year,
      selectedTicketDate!.month,
      selectedTicketDate!.day,
    );
    final todayDateOnly = DateTime(now.year, now.month, now.day);
    final isToday = selectedDateOnly.isAtSameMomentAs(todayDateOnly);

    // For future dates, show all available time slots
    if (!isToday) {
      return allTimeSlots;
    }

    // For today, filter slots based on ticket type
    return allTimeSlots.where((slot) {
      final fromTime = slot['from']!;
      final toTime = slot['to']!;

      final fromParts = fromTime.split(':');
      final fromHour = int.parse(fromParts[0]);
      final fromMinute = int.parse(fromParts[1]);
      final fromTimeInMinutes = fromHour * 60 + fromMinute;

      final toParts = toTime.split(':');
      final toHour = int.parse(toParts[0]);
      final toMinute = int.parse(toParts[1]);
      final toTimeInMinutes = toHour * 60 + toMinute;

      // Don't show past slots
      if (fromTimeInMinutes < currentTimeInMinutes) {
        return false;
      }

      // For emergency tickets: only show slots that start within 120 minutes
      // and have duration of 90-120 minutes
      if (isEmergency) {
        if (fromTimeInMinutes > maxMinutes || fromTimeInMinutes >= toTimeInMinutes) {
          return false;
        }
        final duration = toTimeInMinutes - fromTimeInMinutes;
        return duration >= 90 && duration <= 120;
      }

      // For corrective/preventive tickets: show all future slots (no 120-minute restriction)
      return fromTimeInMinutes < toTimeInMinutes;
    }).toList();
  }

  // Attachments
  List<Map<String, dynamic>> uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize service description text
    _serviceDescriptionText = serviceDescription.text;

    // Add listener to serviceDescription controller to update state variable
    serviceDescription.addListener(() {
      if (_serviceDescriptionText != serviceDescription.text) {
        setState(() {
          _serviceDescriptionText = serviceDescription.text;
        });
      }
    });

    // Check role immediately to set isTeamLeaderVisible before UI renders
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentUserRoleId = appProvider.userModel?.customer.roleId;

    // Parse roleId - handle int, string, or null
    int? roleIdInt;
    if (currentUserRoleId == null) {
      roleIdInt = null;
    } else if (currentUserRoleId is int) {
      roleIdInt = currentUserRoleId;
    } else if (currentUserRoleId is String) {
      roleIdInt = int.tryParse(currentUserRoleId);
    } else {
      // Try to convert to string then parse
      try {
        roleIdInt = int.tryParse(currentUserRoleId.toString());
      } catch (e) {
        roleIdInt = null;
      }
    }

    // Set visibility immediately based on role
    // Role IDs: 18 = Admin, 20 = Team Leader
    if (mounted) {
      setState(() {
        if (roleIdInt == 20) {
          // Team Leader: Hide dropdown
          isTeamLeaderVisible = false;
        } else if (roleIdInt == 18) {
          // Admin: Show dropdown
          isTeamLeaderVisible = true;
        } else {
          // Unknown role: Show dropdown by default
          isTeamLeaderVisible = true;
        }
      });
    }

    // Load initial data first, then populate from ticket data
    _loadInitialData().then((_) {
      if (widget.ticketData != null && mounted) {
        _populateFieldsFromTicketData(widget.ticketData!);
        // Fetch materials when editing (always load, but only show if withMaterial is true)
        final ticketId = widget.ticketData!['id'];
        if (ticketId != null) {
          _loadMaterialsForTicket(ticketId);
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    // Get user's company ID directly from user model/profile (following frontend-OMS pattern)
    const WEFIX_COMPANY_ID = 39;
    int? userCompanyId;
    
    // Try to get companyId from profile first (if available)
    // This will be populated after profile is loaded with the new companyId field
    // For now, we'll fetch it or infer it from the data
    
    // Check if ticket is delegated to WeFix - if so, use ticket's contract for services
    int? contractIdForServices;
    bool isDelegatedTicket = false;
    bool isDelegatedToWeFixTicket = false;
    
    if (widget.ticketData != null) {
      final delegatedToCompanyId = widget.ticketData!['delegatedToCompanyId'] as int?;
      if (delegatedToCompanyId != null) {
        // Ticket is delegated - use the ticket's contract to get services from original company
        isDelegatedTicket = true;
        isDelegatedToWeFixTicket = (delegatedToCompanyId == WEFIX_COMPANY_ID);
        final ticketContract = widget.ticketData!['contract'];
        if (ticketContract != null && ticketContract['id'] != null) {
          contractIdForServices = ticketContract['id'] as int?;
          log('🔍 Delegated ticket detected (delegatedToCompanyId: $delegatedToCompanyId) - using contract ID ${contractIdForServices} from original company for services');
        }
        log('🔍 Ticket delegated - isDelegatedToWeFix: $isDelegatedToWeFixTicket');
      }
    }

    // Get ticketId if editing
    int? ticketIdForServices;
    if (widget.ticketData != null && widget.ticketData!['id'] != null) {
      ticketIdForServices = widget.ticketData!['id'] as int?;
    }

    // Load contracts first, then load services based on selected contract
    // Pass ticketId to fetch contracts from the original company for delegated tickets
    final contractsData = await BookingApi.getCompanyContracts(
      token: token,
      context: context,
      ticketId: ticketIdForServices,
    );
    
    // Get contract ID for filtering services (use ticket's contract if delegated, otherwise use first contract)
    if (!isDelegatedTicket) {
      if (contractsData != null && contractsData.isNotEmpty) {
        contractIdForServices = contractsData.first['id'] as int?;
      }
    }

    // Load all data in parallel (zones will be loaded when branch is selected)
    final results = await Future.wait([
      Future.value(contractsData),
      BookingApi.getCompanyBranches(token: token, context: context, ticketId: ticketIdForServices),
      // Zones will be loaded when branch is selected, so we don't load them here
      Future.value(null), // Placeholder for zones
      BookingApi.getMainServices(token: token, context: context, contractId: contractIdForServices, ticketId: ticketIdForServices),
      Future.value(null), // Sub services will be loaded when main service is selected
      BookingApi.getCompanyTeamLeaders(token: token, context: context),
      BookingApi.getCompanyTechnicians(token: token, context: context),
      BookingApi.getTicketTypes(token: token, context: context), // Fetch ticket types
      BookingApi.getTicketStatuses(token: token, context: context), // Fetch ticket statuses
    ]);

    if (!mounted) return;

    setState(() {
      // Contracts
      final contractsData = results[0];
      if (contractsData != null) {
        contracts = contractsData
            .map((item) {
              // Log contract data to verify businessModelLookupId is present
              log('📋 Contract data: ${item['id']} - businessModelLookupId: ${item['businessModelLookupId']}');
              return DropdownCardItem(
                id: item['id'] as int,
                title: item['title'] as String? ?? item['contractReference'] as String? ?? '',
                subtitle: item['subtitle'] as String? ?? item['contractTitle'] as String?,
                icon: Icons.description,
                data: item,
              );
            })
            .toList();
      }

      // Branches
      final branchesData = results[1];
      if (branchesData is List<Map<String, dynamic>> && branchesData.isNotEmpty) {
        branches = branchesData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['branchTitle'] as String? ?? '',
                  subtitle: item['subtitle'] as String?,
                  icon: Icons.business,
                  data: item,
                ))
            .toList();
      }

      // Zones - will be loaded when branch is selected, so skip here
      // zones will be populated by _loadZonesForBranch()

      // Main Services
      final mainServicesData = results[3];
      if (mainServicesData is List<Map<String, dynamic>> && mainServicesData.isNotEmpty) {
        mainServices = mainServicesData
            .map((item) {
              // Get icon URL from API response
              final iconUrl = item['icon'] as String? ?? item['image'] as String?;
              
              // Create icon widget - use network image if URL is available, otherwise use default icon
              Widget? iconWidget;
              if (iconUrl != null && iconUrl.isNotEmpty) {
                String fullIconUrl;
                if (iconUrl.startsWith('http')) {
                  fullIconUrl = iconUrl;
                } else {
                  // Extract base domain from mmsBaseUrl (remove /api/v1/ part)
                  final baseUrlForFiles = EndPoints.mmsBaseUrl.split('/api/')[0];
                  fullIconUrl = Uri.encodeFull('$baseUrlForFiles$iconUrl');
                }
                
                iconWidget = CachedNetworkImage(
                  imageUrl: fullIconUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Icon(Icons.build, size: 70, color: Colors.grey),
                  errorWidget: (context, url, error) => const Icon(Icons.build, size: 70, color: Colors.grey),
                );
              }
              
              return DropdownCardItem(
                id: item['id'] as int,
                title: item['title'] as String? ?? item['name'] as String? ?? '',
                subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                icon: iconWidget == null ? Icons.build : null,
                iconWidget: iconWidget,
                data: item,
              );
            })
            .toList();
      }

      // Sub Services
      final subServicesData = results[4];
      if (subServicesData is List<Map<String, dynamic>> && subServicesData.isNotEmpty) {
        subServices = subServicesData
            .map((item) {
              // Get icon URL from API response
              final iconUrl = item['icon'] as String? ?? item['image'] as String?;
              
              // Create icon widget - use network image if URL is available, otherwise use default icon
              Widget? iconWidget;
              if (iconUrl != null && iconUrl.isNotEmpty) {
                String fullIconUrl;
                if (iconUrl.startsWith('http')) {
                  fullIconUrl = iconUrl;
                } else {
                  // Extract base domain from mmsBaseUrl (remove /api/v1/ part)
                  final baseUrlForFiles = EndPoints.mmsBaseUrl.split('/api/')[0];
                  fullIconUrl = Uri.encodeFull('$baseUrlForFiles$iconUrl');
                }
                
                iconWidget = CachedNetworkImage(
                  imageUrl: fullIconUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Icon(Icons.settings, size: 70, color: Colors.grey),
                  errorWidget: (context, url, error) => const Icon(Icons.settings, size: 70, color: Colors.grey),
                );
              }
              
              return DropdownCardItem(
                id: item['id'] as int,
                title: item['title'] as String? ?? item['name'] as String? ?? '',
                subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                icon: iconWidget == null ? Icons.settings : null,
                iconWidget: iconWidget,
                data: item,
              );
            })
            .toList();
      }

      // Team Leaders
      final teamLeadersData = results[5];
      if (teamLeadersData is List<Map<String, dynamic>> && teamLeadersData.isNotEmpty) {
        teamLeaders = teamLeadersData
            .map((item) {
              final profileImage = item['profileImage'] as String?;
              final imageUrl = profileImage != null && profileImage.isNotEmpty
                  ? _buildImageUrl(profileImage)
                  : null;
              
              final fullName = item['fullName'] as String? ?? '';
              final fullNameEnglish = item['fullNameEnglish'] as String? ?? '';
              
              // Title: English name (orange color)
              final title = fullNameEnglish.isNotEmpty ? fullNameEnglish : fullName;
              
              // Subtitle: Arabic name only (gray color)
              final subtitle = fullName.isNotEmpty && fullName != fullNameEnglish ? fullName : null;
              
              return DropdownCardItem(
                id: item['id'] as int,
                title: title,
                subtitle: subtitle,
                icon: imageUrl == null ? Icons.person_outline : null,
                iconWidget: imageUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline, color: Colors.grey[400], size: 35),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline, color: Colors.grey[400], size: 35),
                          ),
                        ),
                      )
                    : null,
                data: item,
              );
            })
            .toList();
      }

      // Technicians
      final techniciansData = results[6];
      if (techniciansData is List<Map<String, dynamic>> && techniciansData.isNotEmpty) {
        technicians = techniciansData
            .map((item) {
              final profileImage = item['profileImage'] as String?;
              final imageUrl = profileImage != null && profileImage.isNotEmpty
                  ? _buildImageUrl(profileImage)
                  : null;
              
              final fullName = item['fullName'] as String? ?? '';
              final fullNameEnglish = item['fullNameEnglish'] as String? ?? '';
              
              // Title: English name (orange color)
              final title = fullNameEnglish.isNotEmpty ? fullNameEnglish : fullName;
              
              // Subtitle: Arabic name only (gray color)
              final subtitle = fullName.isNotEmpty && fullName != fullNameEnglish ? fullName : null;
              
              return DropdownCardItem(
                id: item['id'] as int,
                title: title,
                subtitle: subtitle,
                icon: imageUrl == null ? Icons.engineering : null,
                iconWidget: imageUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.engineering, color: Colors.grey[400], size: 35),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.engineering, color: Colors.grey[400], size: 35),
                          ),
                        ),
                      )
                    : null,
                data: item,
              );
            })
            .toList();
      }

      // Determine if user is from WeFix
      // Priority 1: Check profile (if available)
      // Priority 2: Check team leaders' companyId
      // Priority 3: Check technicians' companyId
      const WEFIX_COMPANY_ID_FILTER = 39;
      bool userIsFromWeFix = false;
      
      // Try to get companyId from profile first (if profile was loaded)
      // Note: This requires profile to be fetched separately, which we'll add later
      // For now, we'll detect from the data we have
      
      // Check team leaders first
      if (teamLeaders.isNotEmpty) {
        for (var leader in teamLeaders) {
          final leaderData = leader.data;
          if (leaderData is Map<String, dynamic>) {
            final leaderCompanyId = leaderData['companyId'] as int?;
            if (leaderCompanyId == WEFIX_COMPANY_ID_FILTER) {
              userIsFromWeFix = true;
              userCompanyId = WEFIX_COMPANY_ID_FILTER;
              log('✅ User is from WeFix (detected from team leaders list, companyId: $leaderCompanyId)');
              break;
            } else if (leaderCompanyId != null && userCompanyId == null) {
              // Store the first non-null companyId we find
              userCompanyId = leaderCompanyId;
              log('📋 Detected user companyId from team leader: $leaderCompanyId');
            }
          }
        }
      }
      
      // If not detected from team leaders, check technicians
      if (!userIsFromWeFix && technicians.isNotEmpty) {
        for (var technician in technicians) {
          final technicianData = technician.data;
          if (technicianData is Map<String, dynamic>) {
            final technicianCompanyId = technicianData['companyId'] as int?;
            if (technicianCompanyId == WEFIX_COMPANY_ID_FILTER) {
              userIsFromWeFix = true;
              userCompanyId = WEFIX_COMPANY_ID_FILTER;
              log('✅ User is from WeFix (detected from technicians list, companyId: $technicianCompanyId)');
              break;
            } else if (technicianCompanyId != null && userCompanyId == null) {
              // Store the first non-null companyId we find
              userCompanyId = technicianCompanyId;
              log('📋 Detected user companyId from technician: $technicianCompanyId');
            }
          }
        }
      }
      
      // Log detection result
      if (!userIsFromWeFix) {
        log('⚠️ Could not detect if user is from WeFix. userCompanyId: $userCompanyId, teamLeaders count: ${teamLeaders.length}, technicians count: ${technicians.length}');
        // If we have a delegated ticket to WeFix and we couldn't detect, assume user is NOT from WeFix
        // This is safer - we'll hide the fields rather than show them incorrectly
      }
      
      // Set isWeFixUser flag based on detection
      isWeFixUser = userIsFromWeFix;
      
      // Filter team leaders and technicians based on delegation
      // Following frontend-OMS pattern: If ticket is delegated to WeFix AND user is from WeFix,
      // filter to only show WeFix team members
      if (widget.ticketData != null) {
        final delegatedToCompanyId = widget.ticketData!['delegatedToCompanyId'] as int?;
        if (delegatedToCompanyId == WEFIX_COMPANY_ID_FILTER) {
          if (userIsFromWeFix) {
            // Ticket is delegated to WeFix AND user is from WeFix - filter to only show WeFix team members
            final beforeFilterCountTL = teamLeaders.length;
            final beforeFilterCountTech = technicians.length;
            
            teamLeaders = teamLeaders.where((leader) {
              final leaderData = leader.data;
              if (leaderData is Map<String, dynamic>) {
                final leaderCompanyId = leaderData['companyId'] as int?;
                return leaderCompanyId == WEFIX_COMPANY_ID_FILTER;
              }
              return false;
            }).toList();
            
            technicians = technicians.where((technician) {
              final technicianData = technician.data;
              if (technicianData is Map<String, dynamic>) {
                final technicianCompanyId = technicianData['companyId'] as int?;
                return technicianCompanyId == WEFIX_COMPANY_ID_FILTER;
              }
              return false;
            }).toList();
            
            log('✅ WeFix user editing delegated ticket - filtered team leaders and technicians to only show WeFix team members');
            log('📊 Team Leaders: $beforeFilterCountTL → ${teamLeaders.length}, Technicians: $beforeFilterCountTech → ${technicians.length}');
          } else {
            log('⚠️ Ticket delegated to WeFix but user detection failed - userIsFromWeFix: $userIsFromWeFix, userCompanyId: $userCompanyId');
            log('📊 Team Leaders count: ${teamLeaders.length}, Technicians count: ${technicians.length}');
            // Log first team leader's companyId for debugging
            if (teamLeaders.isNotEmpty) {
              final firstLeaderData = teamLeaders.first.data;
              if (firstLeaderData is Map<String, dynamic>) {
                log('🔍 First team leader companyId: ${firstLeaderData['companyId']}');
              }
            }
          }
        }
      }

      // Ticket Types
      final ticketTypesData = results[7];
      if (ticketTypesData != null) {
        final ticketTypesList = List<Map<String, dynamic>>.from(ticketTypesData as List);
        if (ticketTypesList.isNotEmpty) {
          ticketTypes = ticketTypesList
              .map((item) => DropdownCardItem(
                    id: item['id'] as int,
                    title: item['title'] as String? ?? item['name'] as String? ?? '',
                    subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                    icon: Icons.category,
                    data: item,
                  ))
              .toList();

          // Find "Corrective" ticket type (case-insensitive) or use first one
          // Only auto-select ticket type when creating a new ticket (not editing)
          if (widget.ticketData == null) {
            try {
              selectedTicketType = ticketTypes.firstWhere(
                (type) => type.title.toLowerCase().contains('corrective'),
              );
            } catch (e) {
              // If "Corrective" not found, use first ticket type
              if (ticketTypes.isNotEmpty) {
                selectedTicketType = ticketTypes.first;
              }
            }
          }
        }
      }

      // Ticket Statuses
      final ticketStatusesData = results[8];
      if (ticketStatusesData != null) {
        final ticketStatusesList = List<Map<String, dynamic>>.from(ticketStatusesData as List);
        if (ticketStatusesList.isNotEmpty) {
          ticketStatuses = ticketStatusesList
              .map((item) => DropdownCardItem(
                    id: item['id'] as int,
                    title: item['title'] as String? ?? item['name'] as String? ?? '',
                    subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                    icon: Icons.info_outline,
                    data: item,
                  ))
              .toList();
        }
      }

      // Only auto-select first items if NOT editing a ticket (ticket data will be populated later)
      if (widget.ticketData == null) {
        // Auto-select first contract only when creating new ticket
        if (contracts.isNotEmpty) {
          selectedContract = contracts.first;
          
          // Check if auto-selected contract is B2B (delegated to WeFix Team)
          // Hide Team Leader and Technician for B2B business model
          final contractData = selectedContract?.data;
          final businessModelLookupId = contractData?['businessModelLookupId'] as int?;
          
          log('🔍 Auto-selected contract - businessModelLookupId: $businessModelLookupId');
          
          const B2B_BUSINESS_MODEL_ID = 24;
          const WHITE_LABEL_BUSINESS_MODEL_ID = 25;
          
          // B2B (24) -> delegated to WeFix Team, White Label (25) -> Client Team
          final isContractB2B = (businessModelLookupId == B2B_BUSINESS_MODEL_ID);
          isDelegatedToWeFix = isContractB2B;
          
          log('🔍 Auto-selected contract isDelegatedToWeFix: $isContractB2B (B2B=${businessModelLookupId == B2B_BUSINESS_MODEL_ID}, White Label=${businessModelLookupId == WHITE_LABEL_BUSINESS_MODEL_ID})');
        }
        if (branches.isNotEmpty) {
          selectedBranch = branches.first;
          // Load zones for the first branch
          _loadZonesForBranch(branches.first.id);
        }
        if (mainServices.isNotEmpty) {
          selectedMainService = mainServices.first;
          // Load sub services for the first main service (auto-select first sub service for new tickets)
          _loadSubServices(mainServices.first.id, autoSelectFirst: true);
        }
      }

      // Role-based UI control: Hide/show Team Leader DDL based on role
      // Strategy: Check if current user is in the team leaders list
      // If user is in the list, they are a Team Leader - hide dropdown and auto-select themselves
      // If user is NOT in the list, they are likely an Admin - show dropdown
      final currentUserId = appProvider.userModel?.customer.id;
      final currentUserRoleId = appProvider.userModel?.customer.roleId;

      // Parse roleId for logging
      int? roleIdInt;
      if (currentUserRoleId != null) {
        if (currentUserRoleId is int) {
          roleIdInt = currentUserRoleId;
        } else if (currentUserRoleId is String) {
          roleIdInt = int.tryParse(currentUserRoleId);
        } else {
          try {
            roleIdInt = int.tryParse(currentUserRoleId.toString());
          } catch (e) {
            roleIdInt = null;
          }
        }
      }

      // Check if current user is in the team leaders list
      // Strategy: Check by ID first, then by name as fallback
      bool isCurrentUserTeamLeader = false;
      final currentUserName = appProvider.userModel?.customer.name;

      if (teamLeaders.isNotEmpty) {
        // First, try to find by ID
        if (currentUserId != null) {
          try {
            teamLeaders.firstWhere(
              (leader) => leader.id == currentUserId,
            );
            isCurrentUserTeamLeader = true;
            log('✅ Current user (ID: $currentUserId) found in Team Leaders list by ID - User is a Team Leader');
          } catch (e) {
            // If not found by ID, try to find by name
            if (currentUserName != null && currentUserName.isNotEmpty) {
              try {
                teamLeaders.firstWhere(
                  (leader) =>
                      leader.title.toLowerCase().contains(currentUserName.toLowerCase()) ||
                      (leader.data?['fullName'] as String?)?.toLowerCase().contains(currentUserName.toLowerCase()) == true,
                );
                isCurrentUserTeamLeader = true;
                log('✅ Current user (Name: $currentUserName) found in Team Leaders list by name - User is a Team Leader');
              } catch (e2) {
                isCurrentUserTeamLeader = false;
                log('ℹ️ Current user (ID: $currentUserId, Name: $currentUserName) NOT found in Team Leaders list - User is likely an Admin');
              }
            } else {
              isCurrentUserTeamLeader = false;
              log('ℹ️ Current user (ID: $currentUserId) NOT found in Team Leaders list - User is likely an Admin');
            }
          }
        } else {
          log('⚠️ Current user ID is null - cannot determine role');
        }
      }

      // Compute single visibility flag following frontend-OMS pattern
      // Rule: 
      // 1. B2B contracts: Hide fields for ALL users (including admins) UNLESS user is from WeFix AND ticket is delegated to WeFix
      // 2. Non-B2B contracts: Admins can always assign team leaders/technicians
      // 3. Non-B2B delegated tickets: Hide if user is NOT from WeFix (unless admin)
      // 4. Non-B2B non-delegated tickets: Show based on role (Admin/Team Leader can assign)
      bool computedShouldHide = false;
      
      // Check user role
      const ADMIN_ROLE_ID = 18;
      final isAdmin = (roleIdInt == ADMIN_ROLE_ID);
      
      // Check if contract is B2B
      const B2B_BUSINESS_MODEL_ID = 24;
      final contractData = selectedContract?.data;
      final businessModelLookupId = contractData?['businessModelLookupId'] as int?;
      final isB2BContract = (businessModelLookupId == B2B_BUSINESS_MODEL_ID);
      
      // Check if ticket is delegated to WeFix
      final delegatedToCompanyId = widget.ticketData?['delegatedToCompanyId'] as int?;
      final isTicketDelegatedToWeFix = (delegatedToCompanyId == WEFIX_COMPANY_ID);
      
      if (isB2BContract) {
        // B2B contract - hide fields for ALL users (including admins) UNLESS user is from WeFix AND ticket is delegated to WeFix
        if (isTicketDelegatedToWeFix && isWeFixUser) {
          // WeFix user editing delegated ticket - show fields
          computedShouldHide = false;
          log('✅ B2B contract with ticket delegated to WeFix - WeFix user can modify team leader/technician');
        } else {
          // B2B contract - hide for ALL users (including admins)
          computedShouldHide = true;
          log('🔒 B2B contract detected (businessModelLookupId: $businessModelLookupId) - hiding Team Leader and Technician fields for ALL users (including admins)');
        }
      } else if (isAdmin) {
        // Non-B2B contract: Company Admin can always assign team leaders/technicians
        computedShouldHide = false;
        log('✅ Company Admin detected - can always assign team leader/technician for non-B2B contracts');
      } else if (widget.ticketData != null && delegatedToCompanyId != null) {
        // Not a B2B contract but ticket is delegated
        if (isTicketDelegatedToWeFix) {
          // Delegated to WeFix - hide fields only if user is NOT from WeFix
          computedShouldHide = !isWeFixUser;
          log('🔍 Delegation check - delegatedToCompanyId: $delegatedToCompanyId, isWeFixUser: $isWeFixUser, shouldHideAssignmentFields: $computedShouldHide');
          if (computedShouldHide) {
            log('🔒 Ticket delegated to WeFix but user is from B2B company - hiding assignment fields');
          } else {
            log('✅ Ticket delegated to WeFix and user is from WeFix - showing assignment fields');
          }
        } else {
          // Delegated to another company - always hide for non-admin users
          computedShouldHide = true;
          log('🔒 Ticket delegated to company $delegatedToCompanyId - hiding assignment fields');
        }
      }
      
      // Store shouldHideAssignmentFields in state for UI rendering
      setState(() {
        shouldHideAssignmentFields = computedShouldHide;
      });

      // Determine team leader visibility (delegation restriction takes precedence)
      // Following frontend-OMS pattern: combine delegation and role-based logic
      if (shouldHideAssignmentFields) {
        // Hide due to delegation restriction
        setState(() {
          isTeamLeaderVisible = false;
        });
        selectedTeamLeader = null;
        selectedTechnician = null;
        log('🔒 Assignment fields hidden due to delegation restriction');
      } else {
        // Only auto-select team leader/technician when creating a new ticket (not editing)
        if (widget.ticketData == null) {
          // No delegation restriction - apply role-based logic
          if ((isCurrentUserTeamLeader || roleIdInt == 20) && teamLeaders.isNotEmpty) {
            // Team Leader: Hide dropdown, auto-select themselves
            setState(() {
              isTeamLeaderVisible = false;
            });
            // Find current user in team leaders list
            try {
              selectedTeamLeader = teamLeaders.firstWhere(
                (leader) => leader.id == currentUserId,
              );
            } catch (e) {
              // If current user not found in team leaders list, use first one
              if (teamLeaders.isNotEmpty) {
                selectedTeamLeader = teamLeaders.first;
              }
            }
          } else {
            // Admin or other role: Show dropdown if team leaders are available
            if (teamLeaders.isNotEmpty) {
              setState(() {
                isTeamLeaderVisible = true;
              });
              selectedTeamLeader = teamLeaders.first;
            } else {
              // No team leaders available - hide dropdown
              setState(() {
                isTeamLeaderVisible = false;
              });
              log('⚠️ No team leaders available - hiding team leader dropdown');
            }
          }

          // Auto-select first technician only when creating new ticket
          if (technicians.isNotEmpty) {
            selectedTechnician = technicians.first;
          }
        }
      }

      // Set default date and time only when creating a new ticket (not editing)
      if (widget.ticketData == null) {
        selectedTicketDate = DateTime.now();
        // Set default time from available slots based on current time
        final now = DateTime.now();
        final currentTimeInMinutes = now.hour * 60 + now.minute;
        final sixteenHundredInMinutes = 16 * 60; // 16:00 = 960 minutes

        final availableSlots = getAvailableTimeSlots();
        if (availableSlots.isNotEmpty) {
          // Select the first available slot (which will be the next slot after current time)
          selectedTimeFrom = availableSlots.first['from'];
          selectedTimeTo = availableSlots.first['to'];
        } else if (currentTimeInMinutes >= sixteenHundredInMinutes) {
          // If current time exceeds 16:00 and no slots are available, default to the latest slot (16:00-18:00)
          final lastSlot = allTimeSlots.last;
          selectedTimeFrom = lastSlot['from'];
          selectedTimeTo = lastSlot['to'];
        }
      }
    });
  }

  void _populateFieldsFromTicketData(Map<String, dynamic> data) {
    setState(() {
      ticketTitle.text = data['ticketTitle'] ?? '';
      ticketDescription.text = data['ticketDescription'] ?? '';
      serviceDescription.text = data['serviceDescription'] ?? '';
      _serviceDescriptionText = serviceDescription.text;

      // Populate contract
      if (data['contract'] != null && contracts.isNotEmpty) {
        try {
          final contractId = data['contract']['id'] as int?;
          if (contractId != null) {
            selectedContract = contracts.firstWhere(
              (contract) => contract.id == contractId,
            );
            
            // Check if contract is B2B (delegated to WeFix Team)
            // Hide Team Leader and Technician for B2B business model
            final contractData = selectedContract?.data;
            final businessModelLookupId = contractData?['businessModelLookupId'] as int?;
            
            log('🔍 Contract loaded from ticket data - businessModelLookupId: $businessModelLookupId');
            
            const B2B_BUSINESS_MODEL_ID = 24;
            const WHITE_LABEL_BUSINESS_MODEL_ID = 25;
            
            // B2B (24) -> delegated to WeFix Team, White Label (25) -> Client Team
            isDelegatedToWeFix = (businessModelLookupId == B2B_BUSINESS_MODEL_ID);
            
            log('🔍 isDelegatedToWeFix: $isDelegatedToWeFix (B2B=${businessModelLookupId == B2B_BUSINESS_MODEL_ID}, White Label=${businessModelLookupId == WHITE_LABEL_BUSINESS_MODEL_ID})');
            
            // Check if ticket is delegated (has delegatedToCompanyId)
            const WEFIX_COMPANY_ID = 39;
            final delegatedToCompanyId = data['delegatedToCompanyId'] as int?;
            
            // If ticket is delegated and user is NOT from WeFix, clear Team Leader and Technician selections
            // If user IS from WeFix, they can assign WeFix team members
            if (delegatedToCompanyId != null) {
              if (delegatedToCompanyId == WEFIX_COMPANY_ID) {
                // Ticket delegated to WeFix - only WeFix users can assign
                // isWeFixUser will be determined when team leaders are loaded
                log('🔍 Ticket is delegated to WeFix - team leader assignment will be restricted based on user company');
              } else {
                // Ticket delegated to another company - B2B users cannot assign
                selectedTeamLeader = null;
                selectedTechnician = null;
                log('🔍 Ticket is delegated to company $delegatedToCompanyId - clearing team leader/technician selections');
              }
            } else if (isDelegatedToWeFix && !isWeFixUser) {
              // Contract is B2B but ticket not yet delegated - clear selections
              selectedTeamLeader = null;
              selectedTechnician = null;
            }
          }
        } catch (e) {
          log('Could not find matching contract: $e');
        }
      }

      // Populate branch and load zones
      if (data['branch'] != null) {
        final branchId = data['branch']['id'] as int?;
        if (branchId != null) {
          log('🔍 Looking for branch with ID: $branchId');
          log('📋 Available branches count: ${branches.length}');
          
          // Try to find the branch in the list
          try {
            selectedBranch = branches.firstWhere(
              (branch) => branch.id == branchId,
            );
            log('✅ Found branch: ${selectedBranch?.title} (ID: ${selectedBranch?.id})');
            
            // Load zones for the selected branch (don't auto-select, we'll select from ticket data)
            _loadZonesForBranch(branchId, autoSelectFirst: false).then((_) {
              // After zones are loaded, select the zone from ticket data
              if (data['zone'] != null && zones.isNotEmpty) {
                try {
                  final zoneId = data['zone']['id'] as int?;
                  if (zoneId != null) {
                    log('🔍 Looking for zone with ID: $zoneId');
                    log('📋 Available zones count: ${zones.length}');
                    
                    setState(() {
                      selectedZone = zones.firstWhere(
                        (zone) => zone.id == zoneId,
                      );
                      log('✅ Found zone: ${selectedZone?.title} (ID: ${selectedZone?.id})');
                    });
                  }
                } catch (e) {
                  log('⚠️ Zone not found in list: $e');
                  // Zone not found - leave unselected
                  if (mounted) {
                    setState(() {
                      selectedZone = null;
                      log('⚠️ Zone from ticket not found in available list - leaving unselected');
                    });
                  }
                }
              }
            });
          } catch (e) {
            log('⚠️ Branch not found in list: $e');
            log('📋 Branch IDs in list: ${branches.map((b) => b.id).toList()}');
            // Branch not found - leave unselected
            setState(() {
              selectedBranch = null;
              selectedZone = null;
              log('⚠️ Branch from ticket not found in available list - leaving unselected');
            });
          }
        }
      }

      // Populate main service and sub service
      // Check both 'mainService' and 'mainServiceLookup' for compatibility
      final mainServiceData = data['mainService'] ?? data['mainServiceLookup'];
      if (mainServiceData != null && mainServices.isNotEmpty) {
        final mainServiceId = mainServiceData['id'] as int?;
        if (mainServiceId != null) {
          log('🔍 Looking for main service with ID: $mainServiceId');
          log('📋 Available main services count: ${mainServices.length}');
          
          // Try to find the main service in the list
          try {
            final foundMainService = mainServices.firstWhere(
              (service) => service.id == mainServiceId,
            );
            
            setState(() {
              selectedMainService = foundMainService;
            });
            log('✅ Found main service: ${selectedMainService?.title} (ID: ${selectedMainService?.id})');
            
            // Load sub services for the selected main service (don't auto-select, we'll select from ticket data)
            _loadSubServices(mainServiceId, autoSelectFirst: false).then((_) {
              // After sub services are loaded, select the sub service from ticket data
              // Check both 'subService' and 'subServiceLookup' for compatibility
              final subServiceData = data['subService'] ?? data['subServiceLookup'];
              if (subServiceData != null && subServices.isNotEmpty) {
                final subServiceId = subServiceData['id'] as int?;
                if (subServiceId != null) {
                  log('🔍 Looking for sub service with ID: $subServiceId');
                  log('📋 Available sub services count: ${subServices.length}');
                  
                  try {
                    final foundSubService = subServices.firstWhere(
                      (service) => service.id == subServiceId,
                    );
                    setState(() {
                      selectedSubService = foundSubService;
                    });
                    log('✅ Found sub service: ${selectedSubService?.title} (ID: ${selectedSubService?.id})');
                  } catch (e) {
                    log('⚠️ Sub service not found in list: $e');
                    // Sub service not found - don't auto-select, leave it empty
                    if (mounted) {
                      setState(() {
                        selectedSubService = null;
                        log('⚠️ Sub service from ticket not found in available list - leaving unselected');
                      });
                    }
                  }
                }
              }
            });
          } catch (e) {
            log('⚠️ Main service not found in list: $e');
            log('📋 Main service IDs in list: ${mainServices.map((s) => s.id).toList()}');
            // Main service not found - don't auto-select, leave it empty
            setState(() {
              selectedMainService = null;
              selectedSubService = null;
            });
            log('⚠️ Main service from ticket not found in available list - leaving unselected');
          }
        }
      } else if (mainServices.isNotEmpty && widget.ticketData == null) {
        // Only auto-select first main service if creating a new ticket (not editing)
        setState(() {
          selectedMainService = mainServices.first;
          // Load sub services for the first main service (auto-select first sub service for new tickets)
          _loadSubServices(mainServices.first.id, autoSelectFirst: true);
        });
      }

      // Populate ticket type from ticket data
      if (data['ticketType'] != null && ticketTypes.isNotEmpty) {
        try {
          final ticketTypeId = data['ticketType']['id'] as int?;
          if (ticketTypeId != null) {
            selectedTicketType = ticketTypes.firstWhere(
              (type) => type.id == ticketTypeId,
            );
            log('✅ Populated ticket type: ${selectedTicketType?.title} (ID: ${selectedTicketType?.id})');
          }
        } catch (e) {
          log('⚠️ Ticket type from ticket not found in available list: $e');
        }
      } else if (data['ticketTypeId'] != null && ticketTypes.isNotEmpty) {
        // Try alternative field name
        try {
          final ticketTypeId = data['ticketTypeId'] as int?;
          if (ticketTypeId != null) {
            selectedTicketType = ticketTypes.firstWhere(
              (type) => type.id == ticketTypeId,
            );
            log('✅ Populated ticket type from ticketTypeId: ${selectedTicketType?.title} (ID: ${selectedTicketType?.id})');
          }
        } catch (e) {
          log('⚠️ Ticket type from ticketTypeId not found in available list: $e');
        }
      }

      // Populate ticket status if editing
      if (data['ticketStatus'] != null && ticketStatuses.isNotEmpty) {
        try {
          final statusId = data['ticketStatus']['id'] as int?;
          if (statusId != null) {
            selectedTicketStatus = ticketStatuses.firstWhere(
              (status) => status.id == statusId,
            );
          }
        } catch (e) {
          // Status not found - leave unselected
          selectedTicketStatus = null;
          log('⚠️ Ticket status from ticket not found in available list - leaving unselected');
        }
      }

      // Populate date from ticket data
      if (data['ticketDate'] != null) {
        try {
          final ticketDateStr = data['ticketDate'] as String?;
          if (ticketDateStr != null && ticketDateStr.isNotEmpty) {
            selectedTicketDate = DateTime.parse(ticketDateStr);
            log('✅ Populated ticket date: $selectedTicketDate');
          }
        } catch (e) {
          log('⚠️ Error parsing ticket date: $e');
        }
      }

      // Populate time from ticket data
      if (data['ticketTimeFrom'] != null) {
        selectedTimeFrom = data['ticketTimeFrom'] as String?;
        log('✅ Populated ticket time from: $selectedTimeFrom');
      }
      if (data['ticketTimeTo'] != null) {
        selectedTimeTo = data['ticketTimeTo'] as String?;
        log('✅ Populated ticket time to: $selectedTimeTo');
      }

      // Populate team leader from ticket data
      if (data['teamLeader'] != null && teamLeaders.isNotEmpty) {
        try {
          final teamLeaderId = data['teamLeader']['id'] as int?;
          if (teamLeaderId != null) {
            selectedTeamLeader = teamLeaders.firstWhere(
              (leader) => leader.id == teamLeaderId,
            );
            log('✅ Populated team leader: ${selectedTeamLeader?.title} (ID: ${selectedTeamLeader?.id})');
          }
        } catch (e) {
          log('⚠️ Team leader from ticket not found in available list: $e');
        }
      } else if (data['assignToTeamLeaderId'] != null && teamLeaders.isNotEmpty) {
        // Try alternative field name
        try {
          final teamLeaderId = data['assignToTeamLeaderId'] as int?;
          if (teamLeaderId != null) {
            selectedTeamLeader = teamLeaders.firstWhere(
              (leader) => leader.id == teamLeaderId,
            );
            log('✅ Populated team leader from assignToTeamLeaderId: ${selectedTeamLeader?.title} (ID: ${selectedTeamLeader?.id})');
          }
        } catch (e) {
          log('⚠️ Team leader from assignToTeamLeaderId not found in available list: $e');
        }
      }

      // Populate technician from ticket data
      if (data['technician'] != null && technicians.isNotEmpty) {
        try {
          final technicianId = data['technician']['id'] as int?;
          if (technicianId != null) {
            selectedTechnician = technicians.firstWhere(
              (tech) => tech.id == technicianId,
            );
            log('✅ Populated technician: ${selectedTechnician?.title} (ID: ${selectedTechnician?.id})');
          }
        } catch (e) {
          log('⚠️ Technician from ticket not found in available list: $e');
        }
      } else if (data['assignToTechnicianId'] != null && technicians.isNotEmpty) {
        // Try alternative field name
        try {
          final technicianId = data['assignToTechnicianId'] as int?;
          if (technicianId != null) {
            selectedTechnician = technicians.firstWhere(
              (tech) => tech.id == technicianId,
            );
            log('✅ Populated technician from assignToTechnicianId: ${selectedTechnician?.title} (ID: ${selectedTechnician?.id})');
          }
        } catch (e) {
          log('⚠️ Technician from assignToTechnicianId not found in available list: $e');
        }
      }

      // Populate toggle states
      withMaterial = data['withMaterial'] == true || data['isWithMaterial'] == true;
      withFemaleEngineer = data['havingFemaleEngineer'] == true || data['isWithFemale'] == true || data['isWithFemaleEngineer'] == true;
      
      // Populate materials note
      if (data['materialsNote'] != null) {
        materialsNote.text = data['materialsNote'] as String;
      } else if (data['materials_note'] != null) {
        // Try alternative field name (snake_case)
        materialsNote.text = data['materials_note'] as String;
      } else if (data['note'] != null && withMaterial) {
        // Try generic 'note' field if withMaterial is true
        materialsNote.text = data['note'] as String;
      }

      // Populate location map
      if (data['locationMap'] != null) {
        try {
          final locationMapStr = data['locationMap'] as String?;
          if (locationMapStr != null && locationMapStr.isNotEmpty) {
            // Parse "latitude,longitude" format
            final parts = locationMapStr.split(',');
            if (parts.length == 2) {
              final latitude = double.tryParse(parts[0].trim());
              final longitude = double.tryParse(parts[1].trim());
              if (latitude != null && longitude != null) {
                selectedLocation = LatLng(latitude, longitude);
                log('✅ Populated location map: $selectedLocation');
              }
            }
          }
        } catch (e) {
          log('⚠️ Error parsing location map: $e');
        }
      } else if (data['latitudel'] != null && data['longitude'] != null) {
        // Try alternative field names (from booking details model)
        try {
          final latitudeStr = data['latitudel'] as String?;
          final longitudeStr = data['longitude'] as String?;
          if (latitudeStr != null && longitudeStr != null) {
            final latitude = double.tryParse(latitudeStr);
            final longitude = double.tryParse(longitudeStr);
            if (latitude != null && longitude != null) {
              selectedLocation = LatLng(latitude, longitude);
              log('✅ Populated location from latitudel/longitude: $selectedLocation');
            }
          }
        } catch (e) {
          log('⚠️ Error parsing location from latitudel/longitude: $e');
        }
      }

      // Populate attachments (files)
      // Backend returns: fileName, filePath, category
      // UploadOptionsScreen expects: file/image/audio (path), filename (optional)
      if (data['files'] != null && data['files'] is List) {
        try {
          final filesList = data['files'] as List;
          // Convert relative backend paths to full URLs
          final mmsBaseUrl = 'https://wefix-backend-mms-dev.ngrok.app'; // Base URL without /api/v1/
          
          uploadedFiles = filesList.map((file) {
            if (file is Map<String, dynamic>) {
              final fileName = (file['fileName'] ?? file['originalFilename'] ?? file['filename'] ?? '').toString();
              var filePath = (file['filePath'] ?? file['path'] ?? '').toString();
              final category = (file['category'] ?? '').toString().toLowerCase();
              
              // Convert relative path to full URL
              if (filePath.startsWith('/WeFixFiles/') || filePath.startsWith('/')) {
                filePath = mmsBaseUrl + filePath;
              }
              
              log('📎 Mapping file: $fileName, category: $category, path: $filePath');
              
              // Map to the format expected by UploadOptionsScreen
              // Based on category, put the path in the correct field
              if (category == 'audio' || fileName.toLowerCase().endsWith('.mp3') || fileName.toLowerCase().endsWith('.m4a') || fileName.toLowerCase().endsWith('.wav')) {
                return <String, dynamic>{
                  'audio': filePath,
                  'file': null,
                  'image': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              } else if (category == 'image' || category == 'video' || 
                         fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg') || 
                         fileName.toLowerCase().endsWith('.png') || fileName.toLowerCase().endsWith('.mp4') || 
                         fileName.toLowerCase().endsWith('.mov')) {
                return <String, dynamic>{
                  'image': filePath,
                  'file': null,
                  'audio': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              } else {
                // Default to 'file' for documents and other types
                return <String, dynamic>{
                  'file': filePath,
                  'image': null,
                  'audio': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              }
            }
            return <String, dynamic>{};
          }).where((file) => file.isNotEmpty).toList().cast<Map<String, dynamic>>();
          log('✅ Populated ${uploadedFiles.length} attachment(s) from ticket data');
        } catch (e) {
          log('⚠️ Error parsing attachments: $e');
        }
      } else if (data['ticketAttatchments'] != null && data['ticketAttatchments'] is List) {
        // Try alternative field name
        try {
          final attachmentsList = data['ticketAttatchments'] as List;
          uploadedFiles = attachmentsList.map((file) {
            if (file is Map<String, dynamic>) {
              final fileName = (file['originalFilename'] ?? file['filename'] ?? file['name'] ?? '').toString();
              final filePath = (file['path'] ?? file['url'] ?? '').toString();
              final fileType = (file['type'] ?? file['mimeType'] ?? '').toString().toLowerCase();
              
              // Map to the format expected by UploadOptionsScreen
              if (fileType.contains('audio') || fileName.toLowerCase().endsWith('.mp3') || fileName.toLowerCase().endsWith('.m4a')) {
                return <String, dynamic>{
                  'audio': filePath,
                  'file': null,
                  'image': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              } else if (fileType.contains('image') || fileType.contains('video') || 
                         fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.png') || 
                         fileName.toLowerCase().endsWith('.mp4')) {
                return <String, dynamic>{
                  'image': filePath,
                  'file': null,
                  'audio': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              } else {
                return <String, dynamic>{
                  'file': filePath,
                  'image': null,
                  'audio': null,
                  'filename': fileName,
                  'isNew': false, // Mark existing files from ticket as not new
                };
              }
            }
            return <String, dynamic>{};
          }).where((file) => file.isNotEmpty).toList().cast<Map<String, dynamic>>();
          log('✅ Populated ${uploadedFiles.length} attachment(s) from ticketAttatchments');
        } catch (e) {
          log('⚠️ Error parsing ticketAttatchments: $e');
        }
      }
    });
  }

  Future<void> _loadMaterialsForTicket(dynamic ticketId) async {
    if (ticketId == null) return;

    setState(() {
      isLoadingMaterials = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final result = await BookingApi.getMaterialsByTicketId(
        ticketId: ticketId is int ? ticketId : int.parse(ticketId.toString()),
        token: appProvider.accessToken ?? appProvider.userModel?.token ?? "",
        context: context,
      );

      if (mounted) {
        setState(() {
          if (result != null && result['materials'] != null) {
            materials = List<Map<String, dynamic>>.from(result['materials']);
          } else {
            materials = [];
          }
          isLoadingMaterials = false;
        });
      }
    } catch (e) {
      log('Error loading materials: $e');
      if (mounted) {
        setState(() {
          materials = [];
          isLoadingMaterials = false;
        });
      }
    }
  }

  Future<void> _loadSubServices(int mainServiceId, {bool autoSelectFirst = false}) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    // Get contract ID for filtering sub services
    // When editing a ticket, always use ticket's contract (from original company)
    int? contractId;
    
    if (widget.ticketData != null) {
      // When editing a ticket, always use the ticket's original contract for services
      final ticketContract = widget.ticketData!['contract'];
      if (ticketContract != null && ticketContract['id'] != null) {
        contractId = ticketContract['id'] as int?;
        log('🔍 Loading sub-services for ticket - using contract ID ${contractId} from ticket data');
      }
    }
    
    // If not editing a ticket or contract not found in ticket, use selected contract
    if (contractId == null && selectedContract != null) {
      contractId = selectedContract!.id;
      log('🔍 Loading sub-services - using selected contract ID ${contractId}');
    }

    final subServicesData = await BookingApi.getSubServices(
      token: token,
      parentServiceId: mainServiceId,
      context: context,
      contractId: contractId,
    );

    if (!mounted) return;

    setState(() {
      if (subServicesData != null) {
        subServices = subServicesData
            .map((item) {
              // Get icon URL from API response
              final iconUrl = item['icon'] as String? ?? item['image'] as String?;
              
              // Create icon widget - use network image if URL is available, otherwise use default icon
              Widget? iconWidget;
              if (iconUrl != null && iconUrl.isNotEmpty) {
                String fullIconUrl;
                if (iconUrl.startsWith('http')) {
                  fullIconUrl = iconUrl;
                } else {
                  // Extract base domain from mmsBaseUrl (remove /api/v1/ part)
                  final baseUrlForFiles = EndPoints.mmsBaseUrl.split('/api/')[0];
                  fullIconUrl = Uri.encodeFull('$baseUrlForFiles$iconUrl');
                }
                
                iconWidget = CachedNetworkImage(
                  imageUrl: fullIconUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Icon(Icons.settings, size: 70, color: Colors.grey),
                  errorWidget: (context, url, error) => const Icon(Icons.settings, size: 70, color: Colors.grey),
                );
              }
              
              return DropdownCardItem(
                id: item['id'] as int,
                title: item['title'] as String? ?? item['name'] as String? ?? '',
                subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                icon: iconWidget == null ? Icons.settings : null,
                iconWidget: iconWidget,
                data: item,
              );
            })
            .toList();
        // Auto-select first sub service if available and autoSelectFirst is true
        if (subServices.isNotEmpty && autoSelectFirst) {
          selectedSubService = subServices.first;
        }
      }
    });
  }

  Future<void> _loadZonesForBranch(int branchId, {bool autoSelectFirst = true}) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    // Get ticketId if editing
    int? ticketIdForZones;
    if (widget.ticketData != null && widget.ticketData!['id'] != null) {
      ticketIdForZones = widget.ticketData!['id'] as int?;
    }

    final zonesData = await BookingApi.getCompanyZones(
      token: token,
      branchId: branchId,
      ticketId: ticketIdForZones,
      context: context,
    );

    if (!mounted) return;

    setState(() {
      if (zonesData != null) {
        zones = zonesData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['zoneTitle'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['zoneNumber'] as String?,
                  icon: Icons.map,
                  data: item,
                ))
            .toList();
        // Auto-select first zone only if autoSelectFirst is true and no zone is currently selected
        if (autoSelectFirst && zones.isNotEmpty && selectedZone == null) {
          selectedZone = zones.first;
        } else if (zones.isEmpty) {
          selectedZone = null;
        }
      } else {
        zones = [];
        selectedZone = null;
      }
    });
  }

  void _showDropdownBottomSheet({
    required String title,
    required List<DropdownCardItem> items,
    required DropdownCardItem? selectedItem,
    required Function(DropdownCardItem) onSelected,
  }) {
    DraggableCardBottomSheet.show(
      context: context,
      title: title,
      items: items,
      selectedItem: selectedItem,
      onItemSelected: onSelected,
    );
  }

  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    
    // If already a full URL (http/https), return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Build base URL from backend-mms
    // mmsBaseUrl format: https://wefix-backend-mms.ngrok.app/api/v1/
    String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
    
    // Normalize path - backend-mms stores images in /WeFixFiles/Users/ or /WeFixFiles/Images/
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    
    // If path already starts with /WeFixFiles, use it as is
    if (cleanPath.startsWith('/WeFixFiles')) {
      return '$baseUrl$cleanPath';
    }
    
    // For backward compatibility: if path is /uploads/filename, convert to /WeFixFiles/Images/filename
    if (cleanPath.startsWith('/uploads/')) {
      String filename = cleanPath.replaceFirst('/uploads/', '');
      return '$baseUrl/WeFixFiles/Images/$filename';
    }
    
    // If just a filename, assume it's in /WeFixFiles/Images/
    return '$baseUrl/WeFixFiles/Images/$cleanPath';
  }

  // Helper function to convert time string (HH:mm:ss) to minutes from midnight
  int _timeStringToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  // Validate that selected times are within 120 minutes from current time
  // For Emergency tickets: duration must be 90-120 minutes
  // Both selectedTimeFrom and selectedTimeTo must be from current time to 120 minutes after current time
  bool _validateTimeRange(String? timeFrom, String? timeTo, {bool isEmergency = false}) {
    if (timeFrom == null || timeTo == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;
      final maxMinutes = currentMinutes + 120; // 120 minutes from now

      final fromMinutes = _timeStringToMinutes(timeFrom);
      final toMinutes = _timeStringToMinutes(timeTo);

      // Check: from time must be >= current time
      if (fromMinutes < currentMinutes) {
        return false;
      }

      // Check: from time must be <= current time + 120 minutes
      if (fromMinutes > maxMinutes) {
        return false;
      }

      // Check: to time must be >= current time
      if (toMinutes < currentMinutes) {
        return false;
      }

      // Check: to time must be <= current time + 120 minutes
      if (toMinutes > maxMinutes) {
        return false;
      }

      // Check: from time must be < to time
      if (fromMinutes >= toMinutes) {
        return false;
      }

      // For Emergency tickets: duration must be 90-120 minutes
      if (isEmergency) {
        final duration = toMinutes - fromMinutes;
        if (duration < 90 || duration > 120) {
          return false;
        }
      }

      return true;
    } catch (e) {
      log('Error validating time range: $e');
      return false;
    }
  }

  // Validate current step before navigation
  bool _validateCurrentStep() {
    final localizations = AppLocalizations.of(context)!;
    fieldErrors.clear();
    bool isValid = true;

    // Validate form fields first (TextFields with validators)
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      isValid = false;
    }

    // For Technicians, only validate ticket status
    if (widget.isTechnician) {
      if (selectedTicketStatus == null) {
        fieldErrors['ticketStatus'] = 'Ticket status is required';
        isValid = false;
      }
      return isValid;
    }

    if (_tabController.index == 0) {
      // Tab 1: Basic Info validation
      if (selectedContract == null) {
        fieldErrors['contract'] = '${localizations.contractId} ${localizations.required}';
        isValid = false;
      }
      if (selectedBranch == null) {
        fieldErrors['branch'] = '${localizations.branchId} ${localizations.required}';
        isValid = false;
      }
      if (selectedZone == null) {
        fieldErrors['zone'] = '${localizations.zoneId} ${localizations.required}';
        isValid = false;
      }
      if (selectedTicketType == null) {
        fieldErrors['ticketType'] = '${localizations.ticketType} ${localizations.required}';
        isValid = false;
      }
      // Ticket title is required
      if (ticketTitle.text.trim().isEmpty) {
        fieldErrors['ticketTitle'] = localizations.ticketTitleRequired;
        isValid = false;
      } else if (ticketTitle.text.trim().length > 100) {
        fieldErrors['ticketTitle'] = localizations.ticketTitleMustNotExceed;
        isValid = false;
      }
      // Location map is optional - no validation needed
      if (selectedTicketDate == null) {
        fieldErrors['date'] = '${localizations.date} ${localizations.required}';
        isValid = false;
      }

      // Time slots are required for all ticket types (Corrective, Preventive, Emergency)
      // Emergency tickets will auto-generate times if not selected, but validation still checks
      final isEmergency = selectedTicketType?.title.toLowerCase() == 'emergency' || selectedTicketType?.data?['name']?.toString().toLowerCase() == 'emergency';

      // For non-emergency tickets (Corrective, Preventive), time selection is required
      if (!isEmergency && (selectedTimeFrom == null || selectedTimeTo == null)) {
        fieldErrors['time'] = '${localizations.timeLabel} ${localizations.required}';
        isValid = false;
      } else if (isEmergency && selectedTimeFrom != null && selectedTimeTo != null) {
        // For emergency tickets only: validate time range must be within 120 minutes from current time
        // and duration must be 90-120 minutes
        if (!_validateTimeRange(selectedTimeFrom, selectedTimeTo, isEmergency: true)) {
          fieldErrors['time'] = localizations.emergencyTimeMustBe90To120Minutes;
          isValid = false;
        }
      }
      // Note: Emergency tickets will have time auto-generated in _submit() if not selected
      // Note: Corrective and Preventive tickets can select any available time slot (no 120-minute restriction)
      // Team Leader and Technician validation (following frontend-OMS pattern)
      // Only validate if fields are visible (not hidden due to delegation)
      if (!shouldHideAssignmentFields) {
        if (isTeamLeaderVisible && selectedTeamLeader == null) {
          fieldErrors['teamLeader'] = '${localizations.teamLeaderId} ${localizations.required}';
          isValid = false;
        }
        if (selectedTechnician == null) {
          fieldErrors['technician'] = '${localizations.technicianId} ${localizations.required}';
          isValid = false;
        }
      }
    } else if (_tabController.index == 1) {
      // Tab 2: Service Details validation
      if (selectedMainService == null) {
        fieldErrors['mainService'] = '${localizations.mainService} ${localizations.required}';
        isValid = false;
      }
      if (selectedSubService == null) {
        fieldErrors['subService'] = '${localizations.subService} ${localizations.required}';
        isValid = false;
      }
    }
    // Tab 3 (Summary) doesn't need validation - it's read-only

    if (!isValid) {
      setState(() {});

      // Scroll to the first field with error
      _scrollToFirstError();

      // Show error message
      final errorMessages = fieldErrors.values.where((e) => e != null).cast<String>().toList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessages.length == 1 ? errorMessages.first : errorMessages.join(', ')),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red[600],
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }

    return isValid;
  }

  // Scroll to the first field with error
  void _scrollToFirstError() {
    if (fieldErrors.isEmpty) return;

    // Get the first error key
    final firstErrorKey = fieldErrors.keys.first;
    GlobalKey? targetKey;
    ScrollController? scrollController;
    int targetTabIndex = _tabController.index;

    // Determine which tab contains the error and which scroll controller to use
    // Check if error is in Tab 1 (Basic Info)
    if (['contract', 'branch', 'zone', 'ticketType', 'ticketTitle', 'date', 'time', 'teamLeader', 'technician'].contains(firstErrorKey)) {
      targetTabIndex = 0;
      scrollController = _tab1ScrollController;
      // Map error keys to GlobalKeys for Tab 1
      switch (firstErrorKey) {
        case 'contract':
          targetKey = _contractKey;
          break;
        case 'branch':
          targetKey = _branchKey;
          break;
        case 'zone':
          targetKey = _zoneKey;
          break;
        case 'ticketType':
          targetKey = _ticketTypeKey;
          break;
        case 'ticketTitle':
          targetKey = _ticketTitleKey;
          break;
        case 'date':
          targetKey = _dateKey;
          break;
        case 'time':
          targetKey = _timeKey;
          break;
        case 'teamLeader':
          targetKey = _teamLeaderKey;
          break;
        case 'technician':
          targetKey = _technicianKey;
          break;
      }
    }
    // Check if error is in Tab 2 (Service Details)
    else if (['mainService', 'subService', 'serviceDescription'].contains(firstErrorKey)) {
      targetTabIndex = 1;
      scrollController = _tab2ScrollController;
      // Map error keys to GlobalKeys for Tab 2
      switch (firstErrorKey) {
        case 'mainService':
          targetKey = _mainServiceKey;
          break;
        case 'subService':
          targetKey = _subServiceKey;
          break;
        case 'serviceDescription':
          targetKey = _serviceDescriptionKey;
          break;
      }
    }

    // Switch to the target tab if needed
    if (targetTabIndex != _tabController.index) {
      _tabController.animateTo(targetTabIndex);
      // Wait for tab animation to complete before scrolling
      Future.delayed(const Duration(milliseconds: 350), () {
        _scrollToField(targetKey, scrollController);
      });
    } else {
      // Already on the correct tab, scroll immediately
      _scrollToField(targetKey, scrollController);
    }
  }

  // Helper method to scroll to a specific field
  void _scrollToField(GlobalKey? targetKey, ScrollController? scrollController) {
    if (targetKey != null && scrollController != null && scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderObject? renderObject = targetKey.currentContext?.findRenderObject();
        if (renderObject != null && renderObject is RenderBox) {
          final box = renderObject;
          final position = renderObject.localToGlobal(Offset.zero);
          final fieldHeight = box.size.height;

          // Calculate scroll offset to show field label, field, and error message below it
          // Increased padding (200px) to ensure field label and error message are fully visible
          // 60px for error message below (accounting for error text height)
          final scrollOffset = scrollController.offset + position.dy - 200 - fieldHeight - 60;

          scrollController.animateTo(
            scrollOffset.clamp(0.0, scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (scrollController != null && scrollController.hasClients) {
      // If no specific field key, scroll to top
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToNextTab() {
    if (_validateCurrentStep()) {
      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      }
    }
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  Future<void> _submit() async {
    // Validate all tabs before submission
    // First check Tab 1 (Basic Info)
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!_validateCurrentStep()) {
      // Get list of missing fields for Tab 1
      final localizations = AppLocalizations.of(context)!;
      final missingFields = fieldErrors.keys.map((key) {
        switch (key) {
          case 'contract':
            return localizations.contractId;
          case 'branch':
            return localizations.branchId;
          case 'zone':
            return localizations.zoneId;
          case 'ticketType':
            return localizations.ticketType;
          case 'ticketTitle':
            return localizations.ticketTitle;
          case 'date':
            return localizations.date;
          case 'time':
            return localizations.timeLabel;
          case 'teamLeader':
            return localizations.teamLeaderId;
          case 'technician':
            return localizations.technicianId;
          default:
            return key;
        }
      }).toList();
      log('Missing required fields in Tab 1 (Basic Info): ${missingFields.join(', ')}');
      return; // Validation will scroll to error and show message
    }

    // Then check Tab 2 (Service Details)
    if (_tabController.index != 1) {
      _tabController.animateTo(1);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!_validateCurrentStep()) {
      // Get list of missing fields for Tab 2
      final localizations = AppLocalizations.of(context)!;
      final missingFields = fieldErrors.keys.map((key) {
        switch (key) {
          case 'mainService':
            return localizations.mainService;
          case 'subService':
            return localizations.subService;
          case 'serviceDescription':
            return localizations.serviceDescription;
          default:
            return key;
        }
      }).toList();
      log('Missing required fields in Tab 2 (Service Details): ${missingFields.join(', ')}');
      return; // Validation will scroll to error and show message
    }

    // All validations passed, proceed with submission

    setState(() {
      isLoading = true;
    });

    final localizations = AppLocalizations.of(context)!;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent back button from dismissing
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secoundryColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.ticketData != null ? localizations.updateTicket : localizations.createTicket,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

      // For Technicians, only allow status updates
      final ticketData = <String, dynamic>{};

      // Extract file paths from uploaded files (only used for Admin/Team Leader)
      final List<String> attachmentPaths = [];

      if (widget.isTechnician) {
        // Technicians can ONLY update ticket status and add notes
        if (widget.ticketData != null && selectedTicketStatus != null) {
          ticketData['ticketStatusId'] = selectedTicketStatus!.id;
          // Add notes/comments if provided
          if (serviceDescription.text.trim().isNotEmpty) {
            ticketData['serviceDescription'] = serviceDescription.text.trim();
          }
        } else {
          throw Exception('Missing required fields: Ticket Status');
        }
      } else {
        // For Admin/Team Leader, process all fields
        // Extract file paths from uploaded files
        for (var file in uploadedFiles) {
          if (file['image'] != null && file['image']!.isNotEmpty) {
            attachmentPaths.add(file['image']!);
          }
          if (file['file'] != null && file['file']!.isNotEmpty) {
            attachmentPaths.add(file['file']!);
          }
          if (file['audio'] != null && file['audio']!.isNotEmpty) {
            attachmentPaths.add(file['audio']!);
          }
        }

        // Format location map as "latitude,longitude" (optional)
        final locationMapStr = selectedLocation != null ? '${selectedLocation!.latitude},${selectedLocation!.longitude}' : null;

        // Check if Emergency ticket type is selected
        final isEmergency = selectedTicketType?.title.toLowerCase() == 'emergency' || selectedTicketType?.data?['name']?.toString().toLowerCase() == 'emergency';

        // Format date
        final ticketDateStr = selectedTicketDate != null ? DateFormat('yyyy-MM-dd').format(selectedTicketDate!) : DateFormat('yyyy-MM-dd').format(DateTime.now());

        // For emergency tickets, if time is not selected, generate default time (current time to +90 minutes)
        // Duration must be 90-120 minutes for Emergency tickets
        String? timeFromStr = selectedTimeFrom;
        String? timeToStr = selectedTimeTo;

        if (isEmergency && (selectedTimeFrom == null || selectedTimeTo == null)) {
          final now = DateTime.now();
          final currentMinutes = now.hour * 60 + now.minute;
          // Generate 90-minute duration by default (minimum required)
          final endMinutes = currentMinutes + 90; // 90 minutes from now (minimum duration)

          final fromHour = (currentMinutes ~/ 60).toString().padLeft(2, '0');
          final fromMinute = (currentMinutes % 60).toString().padLeft(2, '0');
          final toHour = (endMinutes ~/ 60).toString().padLeft(2, '0');
          final toMinute = (endMinutes % 60).toString().padLeft(2, '0');

          timeFromStr = '$fromHour:$fromMinute:00';
          timeToStr = '$toHour:$toMinute:00';

          log('Emergency ticket: Generated default time slots from $timeFromStr to $timeToStr (90 minutes duration)');
        }

        // Final validation: Check all required fields before building ticket data
        final localizations = AppLocalizations.of(context)!;
        final List<String> missingFields = [];

        if (selectedContract == null) missingFields.add(localizations.contractId);
        if (selectedBranch == null) missingFields.add(localizations.branchId);
        if (selectedZone == null) missingFields.add(localizations.zoneId);
        if (selectedTicketType == null) missingFields.add(localizations.ticketType);
        if (ticketTitle.text.trim().isEmpty) {
          missingFields.add(localizations.ticketTitle);
        } else if (ticketTitle.text.trim().length > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.ticketTitleMustNotExceed),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (selectedTicketDate == null) missingFields.add(localizations.date);
        // Time fields are now required for all tickets (backend requirement)
        if (timeFromStr == null || timeToStr == null) {
          missingFields.add(localizations.timeLabel);
        }
        // Team Leader and Technician validation (following frontend-OMS pattern)
        // Only validate if fields are visible (not hidden due to delegation)
        if (!shouldHideAssignmentFields) {
          if (isTeamLeaderVisible && selectedTeamLeader == null) {
            missingFields.add(localizations.teamLeaderId);
          }
          if (selectedTechnician == null) {
            missingFields.add(localizations.technicianId);
          }
        }
        if (selectedMainService == null) missingFields.add(localizations.mainService);
        if (selectedSubService == null) missingFields.add(localizations.subService);

        if (missingFields.isNotEmpty) {
          final errorMsg = 'Missing required fields: ${missingFields.join(', ')}';
          log(errorMsg);
          throw Exception(errorMsg);
        }

        // Safety check: For Team Leaders, ensure they can only assign to themselves
        final currentAppProvider = Provider.of<AppProvider>(context, listen: false);
        final currentUserRoleId = currentAppProvider.userModel?.customer.roleId;
        final roleIdInt = currentUserRoleId is int ? currentUserRoleId : (currentUserRoleId is String ? int.tryParse(currentUserRoleId.toString()) : null);
        final currentUserId = currentAppProvider.userModel?.customer.id;

        int? teamLeaderId;
        // Team Leader assignment logic (following frontend-OMS pattern)
        // Only include if fields are visible (not hidden due to delegation)
        if (!shouldHideAssignmentFields) {
          // Validate and assign Team Leader
          if (roleIdInt == 20) {
            // Team Leader: Must assign to themselves
            if (selectedTeamLeader == null || selectedTeamLeader!.id != currentUserId) {
              // Force assign to current user (currentUserId should not be null for authenticated users)
              if (currentUserId == null) {
                throw Exception('Current user ID is null. Please log in again.');
              }
              teamLeaderId = currentUserId;
              log('Team Leader: Forcing assignment to current user (ID: $teamLeaderId)');
            } else {
              teamLeaderId = selectedTeamLeader!.id;
            }
          } else {
            // Admin: Can assign to any Team Leader
            if (selectedTeamLeader == null) {
              throw Exception('Team Leader selection is required');
            }
            teamLeaderId = selectedTeamLeader!.id;
          }
        } else {
          // When delegated to WeFix and user is NOT from WeFix, Team Leader ID should be null
          teamLeaderId = null;
          log('Ticket delegated to WeFix (user not from WeFix): Team Leader ID set to null');
        }
        // Admin/Team Leader can update all fields
        // Remove subServiceId if it's null (backend doesn't accept undefined fields)
        ticketData.addAll({
          'contractId': selectedContract!.id,
          'branchId': selectedBranch!.id,
          'zoneId': selectedZone!.id,
          'ticketTitle': ticketTitle.text.trim(),
          if (locationMapStr != null) 'locationMap': locationMapStr, // Optional: latitude,longitude format
          'ticketTypeId': selectedTicketType!.id,
          'ticketDate': ticketDateStr,
          'ticketTimeFrom': timeFromStr!,
          'ticketTimeTo': timeToStr!,
          'ticketDescription': ticketDescription.text.trim(),
          'havingFemaleEngineer': withFemaleEngineer,
          'withMaterial': withMaterial,
          // Always send materialsNote when withMaterial is true (even if empty, to allow clearing)
          if (withMaterial) 'materialsNote': materialsNote.text.trim(),
          'mainServiceId': selectedMainService!.id,
          if (selectedSubService != null) 'subServiceId': selectedSubService!.id,
          if (serviceDescription.text.trim().isNotEmpty) 'serviceDescription': serviceDescription.text.trim(),
          // Note: fileIds will be sent separately after uploading files
          // Note: customerName, tools can be added later
        });
        
        // Include Team Leader and Technician (following frontend-OMS pattern)
        // Only include if fields are visible (not hidden due to delegation)
        // IMPORTANT: Do NOT send these fields at all (not even as null) when hidden
        // Sending null triggers backend validation which blocks B2B admins from editing delegated tickets
        if (!shouldHideAssignmentFields) {
          if (teamLeaderId != null) {
            ticketData['assignToTeamLeaderId'] = teamLeaderId;
          }
          if (selectedTechnician != null) {
            ticketData['assignToTechnicianId'] = selectedTechnician!.id;
          }
        }
        // When fields are hidden, simply don't include them in the request
        // This allows B2B admins to update other ticket fields without triggering validation errors

        // Add ticket status if editing
        if (widget.ticketData != null && selectedTicketStatus != null) {
          ticketData['ticketStatusId'] = selectedTicketStatus!.id;
        }
      }

      // Step 1: Create or update the ticket first
      // Technicians can only update existing tickets, not create new ones
      if (widget.isTechnician && widget.ticketData == null) {
        throw Exception('Technicians can only update existing tickets, not create new ones');
      }

      Map<String, dynamic>? result;
      if (widget.ticketData != null) {
        result = await BookingApi.updateTicketInMMS(
          token: token,
          ticketId: widget.ticketData!['id'],
          ticketData: ticketData,
          context: context,
        );
      } else {
        result = await BookingApi.createTicketInMMS(
          token: token,
          ticketData: ticketData,
          context: context,
        );
      }

      // Step 2: If ticket created successfully and there are attachments, upload them with the ticket ID
      // Only upload files for Admin/Team Leader (not for Technicians)
      if (!widget.isTechnician && result != null && attachmentPaths.isNotEmpty) {
        final ticketId = result['id'] as int;

        // Upload files with the ticket ID so they're linked immediately
        final uploadedFileIds = await BookingApi.uploadFilesToMMS(
          token: token,
          filePaths: attachmentPaths,
          context: context,
          ticketId: ticketId, // Pass ticket ID for immediate linking
        );

        if (uploadedFileIds == null || uploadedFileIds.isEmpty) {
          // Files upload failed, but ticket was created
          log('Ticket created but file upload failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.ticketData != null ? 'Ticket updated but attachments failed to upload' : 'Ticket created but attachments failed to upload'),
              ),
            );
          }
        }
      }

      setState(() {
        isLoading = false;
      });

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.ticketData != null ? AppLocalizations.of(context)!.ticketUpdatedSuccessfully : AppLocalizations.of(context)!.ticketCreatedSuccessfully),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
        // Small delay before navigating back to show success message
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        // Log the error for debugging
        log('Ticket creation/update failed - check backend response');
        // Error message is already shown by updateTicketInMMS/createTicketInMMS
        // Only show generic message if no specific error was shown
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.ticketData != null ? AppLocalizations.of(context)!.ticketUpdateFailed : AppLocalizations.of(context)!.ticketCreateFailed),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (mounted) {
        log('_submit error: $e');
        log('_submit error type: ${e.runtimeType}');
        log('_submit error toString: ${e.toString()}');

        // Extract error message from exception
        String errorMessage = e.toString();
        if (e is Exception) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        // Log full error details for debugging
        try {
          log('Full error details: ${e.toString()}');
          if (e.toString().contains('Missing required fields')) {
            log('Error contains "Missing required fields" - detailed message should be available');
          }
        } catch (logError) {
          log('Error logging error details: $logError');
        }

        // Show clear error message to user (the API should already show a detailed message)
        // Only show generic message if the detailed message wasn't already shown
        if (!errorMessage.contains('Missing required fields') || errorMessage == 'Missing required fields') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage.isNotEmpty && errorMessage != 'null' && !errorMessage.contains('Missing required fields')
                  ? errorMessage
                  : (widget.ticketData != null ? AppLocalizations.of(context)!.ticketUpdateFailed : AppLocalizations.of(context)!.ticketCreateFailed)),
              backgroundColor: Colors.red[600],
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tab1ScrollController.dispose();
    _tab2ScrollController.dispose();
    ticketTitle.dispose();
    serviceDescription.dispose();
    ticketDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.isTechnician ? 'Change Ticket Status' : (widget.ticketData != null ? localizations.editTicket : localizations.createTicket)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: widget.isTechnician
            ? null // Hide TabBar for Technicians
            : PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Text(
                          localizations.basicInfo,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11,
                            fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          localizations.serviceDetails,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          localizations.ticketSummary,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: widget.isTechnician
                  ? _buildTab1(localizations) // Show only status dropdown for Technicians
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTab1(localizations),
                        _buildTab2(localizations),
                        // Wrap summary in AnimatedBuilder to rebuild when tab becomes visible
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            // Force rebuild when summary tab is visible
                            return _buildTab3Summary(localizations);
                          },
                        ),
                      ],
                    ),
            ),
            // Navigation buttons
            widget.isTechnician
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: CustomBotton(
                      title: localizations.updateTicket,
                      onTap: _submit,
                    ),
                  )
                : AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      final isLastTab = _tabController.index == 2; // Tab 3 (summary) is index 2
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (_tabController.index > 0)
                              Expanded(
                                child: CustomBotton(
                                  title: localizations.previous,
                                  onTap: _goToPreviousTab,
                                ),
                              ),
                            if (_tabController.index > 0) const SizedBox(width: 16),
                            Expanded(
                              child: CustomBotton(
                                title: isLastTab ? (widget.ticketData != null ? localizations.updateTicket : localizations.createTicket) : localizations.next,
                                onTap: isLastTab ? _submit : _goToNextTab,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab1(AppLocalizations localizations) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.lang == "ar";
    
    // For Technicians, only show ticket status dropdown and notes field
    if (widget.isTechnician) {
      return SingleChildScrollView(
        controller: _tab1ScrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'You can only change the ticket status and add notes.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // Ticket Status Dropdown (only field for Technicians)
            if (ticketStatuses.isNotEmpty) ...[
              _buildDropdownCard(
                title: 'Ticket Status *',
                selectedItem: selectedTicketStatus,
                items: ticketStatuses,
                onTap: () => _showDropdownBottomSheet(
                  title: 'Ticket Status',
                  items: ticketStatuses,
                  selectedItem: selectedTicketStatus,
                  onSelected: (item) {
                    setState(() {
                      selectedTicketStatus = item;
                      fieldErrors.remove('ticketStatus');
                    });
                  },
                ),
                errorMessage: fieldErrors['ticketStatus'],
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Show loading indicator if statuses are being loaded
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greyColorback,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Loading ticket statuses...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Notes/Comments Field for Technicians
            Text(
              'Notes/Comments',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            WidgetTextField(
              'Add notes or comments about the status change',
              controller: serviceDescription,
              maxLines: 4,
              fillColor: AppColors.greyColorback,
              haveBorder: false,
              radius: 5,
            ),
          ],
        ),
      );
    }

    // For Admin/Team Leader, show all fields
    return SingleChildScrollView(
      controller: _tab1ScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ticket Title Field
          Container(
            key: _ticketTitleKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    WidgetTextField(
                      '${localizations.ticketTitle} *',
                      controller: ticketTitle,
                      maxLines: 2,
                      maxLength: 100,
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      radius: 5,
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            fieldErrors.remove('ticketTitle');
                          }
                        });
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: isArabic ? null : 12,
                      left: isArabic ? 12 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${ticketTitle.text.length} / 100',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (fieldErrors['ticketTitle'] != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      fieldErrors['ticketTitle']!,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Ticket Description Field
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    WidgetTextField(
                      localizations.problemDescription,
                      controller: ticketDescription,
                      maxLines: 3,
                      maxLength: 500,
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      radius: 5,
                      onChanged: (value) {
                        setState(() {
                          // Clear any errors when user starts typing
                        });
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: isArabic ? null : 12,
                      left: isArabic ? 12 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${ticketDescription.text.length} / 500',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Ticket Type Dropdown
          Container(
            key: _ticketTypeKey,
            child: _buildDropdownCard(
              title: '${localizations.ticketType} *',
              selectedItem: selectedTicketType,
              items: ticketTypes,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.ticketType,
                items: ticketTypes,
                selectedItem: selectedTicketType,
                onSelected: (item) {
                  setState(() {
                    selectedTicketType = item;
                    fieldErrors.remove('ticketType');

                    // If Emergency is selected, auto-select today's date
                    final isEmergency = item.title.toLowerCase() == 'emergency' || item.data?['name']?.toString().toLowerCase() == 'emergency';
                    if (isEmergency) {
                      selectedTicketDate = DateTime.now();
                      // Clear time slots for Emergency
                      selectedTimeFrom = null;
                      selectedTimeTo = null;
                      // Clear time field error if it exists
                      fieldErrors.remove('time');
                    }
                  });
                },
              ),
              errorMessage: fieldErrors['ticketType'],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Date and Time on the same line
          Container(
            key: _dateKey,
            child: _buildDateAndTimeRow(localizations),
          ),
          const SizedBox(height: 16),

          // 5. Team Leader Dropdown 
          // - Hidden for Team Leaders (they assign to themselves)
          // - Visible for Admins
          // - Hidden for B2B users when ticket is delegated (unless user is from WeFix)
          // - Visible for WeFix users when ticket is delegated to WeFix
          // Following frontend-OMS pattern: check both role-based visibility AND delegation restriction
          if (isTeamLeaderVisible && !shouldHideAssignmentFields) ...[
            Container(
              key: _teamLeaderKey,
              child: _buildDropdownCard(
                title: '${localizations.teamLeaderId} *',
                selectedItem: selectedTeamLeader,
                items: teamLeaders,
                onTap: () => _showDropdownBottomSheet(
                  title: localizations.teamLeaderId,
                  items: teamLeaders,
                  selectedItem: selectedTeamLeader,
                  onSelected: (item) {
                    setState(() {
                      selectedTeamLeader = item;
                      fieldErrors.remove('teamLeader');
                    });
                  },
                ),
                errorMessage: fieldErrors['teamLeader'],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 6. Technician Dropdown 
          // - Hidden when shouldHideAssignmentFields is true (delegation restriction)
          // - Visible otherwise
          // Following frontend-OMS pattern: use same visibility logic as team leader
          if (!shouldHideAssignmentFields) ...[
            Container(
              key: _technicianKey,
              child: _buildDropdownCard(
                title: '${localizations.technicianId} *',
                selectedItem: selectedTechnician,
                items: technicians,
                onTap: () => _showDropdownBottomSheet(
                  title: localizations.technicianId,
                  items: technicians,
                  selectedItem: selectedTechnician,
                  onSelected: (item) {
                    setState(() {
                      selectedTechnician = item;
                      fieldErrors.remove('technician');
                    });
                  },
                ),
                errorMessage: fieldErrors['technician'],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 7. Contract Reference Dropdown
          Container(
            key: _contractKey,
            child: _buildDropdownCard(
              title: '${localizations.contractId} *',
              selectedItem: selectedContract,
              items: contracts,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.contractId,
                items: contracts,
                selectedItem: selectedContract,
              onSelected: (item) async {
                setState(() {
                  selectedContract = item;
                  fieldErrors.remove('contract');
                  
                  // Check if contract is B2B (delegated to WeFix Team)
                  // Hide Team Leader and Technician for B2B business model (for ALL users)
                  final contractData = item.data;
                  final businessModelLookupId = contractData?['businessModelLookupId'] as int?;
                  
                  log('🔍 Contract selected - businessModelLookupId: $businessModelLookupId');
                  
                  const B2B_BUSINESS_MODEL_ID = 24;
                  const WHITE_LABEL_BUSINESS_MODEL_ID = 25;
                  
                  // B2B (24) -> delegated to WeFix Team, White Label (25) -> Client Team
                  isDelegatedToWeFix = (businessModelLookupId == B2B_BUSINESS_MODEL_ID);
                  
                  log('🔍 isDelegatedToWeFix: $isDelegatedToWeFix (B2B=${businessModelLookupId == B2B_BUSINESS_MODEL_ID}, White Label=${businessModelLookupId == WHITE_LABEL_BUSINESS_MODEL_ID})');
                  
                  // Check user role - Admins can always assign
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  final currentUserRoleId = appProvider.userModel?.customer.roleId;
                  int? roleIdInt;
                  if (currentUserRoleId is int) {
                    roleIdInt = currentUserRoleId;
                  } else if (currentUserRoleId is String) {
                    roleIdInt = int.tryParse(currentUserRoleId);
                  }
                  const ADMIN_ROLE_ID = 18;
                  final isAdmin = (roleIdInt == ADMIN_ROLE_ID);
                  
                  // B2B contract: Hide fields for ALL users (including admins) UNLESS user is from WeFix AND ticket is delegated to WeFix
                  const WEFIX_COMPANY_ID = 39;
                  final delegatedToCompanyId = widget.ticketData?['delegatedToCompanyId'] as int?;
                  final isTicketDelegatedToWeFix = (delegatedToCompanyId == WEFIX_COMPANY_ID);
                  
                  if (isDelegatedToWeFix) {
                    // B2B contract - hide for ALL users (including admins) UNLESS user is from WeFix AND ticket is delegated to WeFix
                    if (isTicketDelegatedToWeFix && isWeFixUser) {
                      // WeFix user editing delegated ticket - can modify team leader/technician
                      setState(() {
                        shouldHideAssignmentFields = false;
                        isTeamLeaderVisible = (roleIdInt != 20); // Show for Team Leader role, hide for others
                      });
                      log('✅ B2B contract with ticket delegated to WeFix - WeFix user can modify team leader/technician');
                    } else {
                      // B2B contract - hide for ALL users (including admins)
                      selectedTeamLeader = null;
                      selectedTechnician = null;
                      setState(() {
                        shouldHideAssignmentFields = true;
                        isTeamLeaderVisible = false;
                      });
                      log('🔒 B2B contract selected - hiding Team Leader and Technician fields for ALL users (including admins)');
                    }
                  } else {
                    // Not B2B contract - check delegation logic for existing tickets
                    if (isAdmin) {
                      // Admin can always assign for non-B2B contracts
                      setState(() {
                        shouldHideAssignmentFields = false;
                        isTeamLeaderVisible = true;
                      });
                      log('✅ Non-B2B contract - Admin can assign team leader/technician');
                    } else if (widget.ticketData != null && isTicketDelegatedToWeFix) {
                      // Ticket is delegated to WeFix - hide only if user is NOT from WeFix
                      setState(() {
                        shouldHideAssignmentFields = !isWeFixUser;
                      });
                    } else {
                      // Not delegated or delegated to other company - show fields
                      setState(() {
                        shouldHideAssignmentFields = false;
                      });
                    }
                  }
                  
                  // Clear main service and sub service selections when contract changes
                  selectedMainService = null;
                  selectedSubService = null;
                });
                
                // Reload main services and sub services filtered by contract
                // If ticket is delegated to WeFix, use ticket's contract instead of selected contract
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
                
                if (token.isNotEmpty) {
                  // Determine which contract to use for services
                  int? contractIdForServices = item.id;
                  const WEFIX_COMPANY_ID = 39;
                  
                  if (widget.ticketData != null) {
                    final delegatedToCompanyId = widget.ticketData!['delegatedToCompanyId'] as int?;
                    if (delegatedToCompanyId == WEFIX_COMPANY_ID) {
                      // Ticket is delegated to WeFix - use ticket's contract (from original company)
                      final ticketContract = widget.ticketData!['contract'];
                      if (ticketContract != null && ticketContract['id'] != null) {
                        contractIdForServices = ticketContract['id'] as int?;
                        log('🔍 Contract changed but ticket is delegated - using ticket contract ID ${contractIdForServices} for services');
                      }
                    }
                  }
                  
                  // Get ticketId if editing
                  int? ticketIdForServices;
                  if (widget.ticketData != null && widget.ticketData!['id'] != null) {
                    ticketIdForServices = widget.ticketData!['id'] as int?;
                  }
                  
                  // Reload main services for the contract (ticket's contract if delegated, otherwise selected contract)
                  final mainServicesData = await BookingApi.getMainServices(
                    token: token,
                    context: context,
                    contractId: contractIdForServices,
                    ticketId: ticketIdForServices,
                  );
                  
                  if (mounted && mainServicesData != null) {
                    setState(() {
                      mainServices = mainServicesData
                          .map((serviceItem) {
                            // Get icon URL from API response
                            final iconUrl = serviceItem['icon'] as String? ?? serviceItem['image'] as String?;
                            
                            // Create icon widget - use network image if URL is available, otherwise use default icon
                            Widget? iconWidget;
                            if (iconUrl != null && iconUrl.isNotEmpty) {
                              String fullIconUrl;
                              if (iconUrl.startsWith('http')) {
                                fullIconUrl = iconUrl;
                              } else {
                                // Extract base domain from mmsBaseUrl (remove /api/v1/ part)
                                final baseUrlForFiles = EndPoints.mmsBaseUrl.split('/api/')[0];
                                fullIconUrl = Uri.encodeFull('$baseUrlForFiles$iconUrl');
                              }
                              
                              iconWidget = CachedNetworkImage(
                                imageUrl: fullIconUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Icon(Icons.build, size: 70, color: Colors.grey),
                                errorWidget: (context, url, error) => const Icon(Icons.build, size: 70, color: Colors.grey),
                              );
                            }
                            
                            return DropdownCardItem(
                              id: serviceItem['id'] as int,
                              title: serviceItem['title'] as String? ?? serviceItem['name'] as String? ?? '',
                              subtitle: serviceItem['subtitle'] as String? ?? serviceItem['nameArabic'] as String?,
                              icon: iconWidget == null ? Icons.build : null,
                              iconWidget: iconWidget,
                              data: serviceItem,
                            );
                          })
                          .toList();
                      
                      // Auto-select first main service if available (only for new tickets)
                      if (mainServices.isNotEmpty && widget.ticketData == null) {
                        selectedMainService = mainServices.first;
                        // Load sub services for the first main service (auto-select first sub service for new tickets)
                        _loadSubServices(mainServices.first.id, autoSelectFirst: true);
                      }
                    });
                  }
                }
              },
              ),
              errorMessage: fieldErrors['contract'],
            ),
          ),
          const SizedBox(height: 16),

          // 8. Branch Dropdown
          Container(
            key: _branchKey,
            child: _buildDropdownCard(
              title: '${localizations.branchId} *',
              selectedItem: selectedBranch,
              items: branches,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.branchId,
                items: branches,
                selectedItem: selectedBranch,
                onSelected: (item) {
                  setState(() {
                    selectedBranch = item;
                    selectedZone = null; // Reset zone when branch changes
                    zones = []; // Clear zones list
                    fieldErrors.remove('branch');
                    fieldErrors.remove('zone');
                  });
                  // Load zones for the selected branch
                  _loadZonesForBranch(item.id);
                },
              ),
              errorMessage: fieldErrors['branch'],
            ),
          ),
          const SizedBox(height: 16),

          // 9. Zone Dropdown
          Container(
            key: _zoneKey,
            child: _buildDropdownCard(
              title: '${localizations.zoneId} *',
              selectedItem: selectedZone,
              items: zones,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.zoneId,
                items: zones,
                selectedItem: selectedZone,
                onSelected: (item) {
                  setState(() {
                    selectedZone = item;
                    fieldErrors.remove('zone');
                  });
                },
              ),
              errorMessage: fieldErrors['zone'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab2(AppLocalizations localizations) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.lang == "ar";
    
    return SingleChildScrollView(
      controller: _tab2ScrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Description (moved to top)
          Container(
            key: _serviceDescriptionKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    WidgetTextField(
                      localizations.serviceDescription,
                      controller: serviceDescription,
                      maxLines: 4,
                      maxLength: 500,
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      radius: 5,
                      onChanged: (value) {
                        setState(() {
                          // Clear error when user starts typing
                          if (fieldErrors.containsKey('serviceDescription')) {
                            fieldErrors.remove('serviceDescription');
                          }
                        });
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: isArabic ? null : 12,
                      left: isArabic ? 12 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${serviceDescription.text.length} / 500',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (fieldErrors['serviceDescription'] != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      fieldErrors['serviceDescription']!,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Main Service Dropdown
          Container(
            key: _mainServiceKey,
            child: _buildDropdownCard(
              title: '${localizations.mainService} *',
              selectedItem: selectedMainService,
              items: mainServices,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.mainService,
                items: mainServices,
                selectedItem: selectedMainService,
                onSelected: (item) async {
                  setState(() {
                    selectedMainService = item;
                    selectedSubService = null; // Reset sub service when main service changes
                    fieldErrors.remove('mainService');
                  });
                  // Load sub services based on selected main service (auto-select first sub service when user selects)
                  await _loadSubServices(item.id, autoSelectFirst: true);
                },
              ),
              errorMessage: fieldErrors['mainService'],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Sub Service Dropdown
          Container(
            key: _subServiceKey,
            child: _buildDropdownCard(
              title: '${localizations.subService} *',
              selectedItem: selectedSubService,
              items: subServices,
              onTap: () => _showDropdownBottomSheet(
                title: localizations.subService,
                items: subServices,
                selectedItem: selectedSubService,
                onSelected: (item) {
                  setState(() {
                    selectedSubService = item;
                    fieldErrors.remove('subService');
                  });
                },
              ),
              errorMessage: fieldErrors['subService'],
            ),
          ),
          const SizedBox(height: 16),

          // Toggle: With Material
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greyColorback,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.withMaterial,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: withMaterial,
                  onChanged: (value) async {
                    // If toggling from true to false, show confirmation and delete materials
                    if (withMaterial && !value && widget.ticketData != null && widget.ticketData!['id'] != null) {
                      // First, fetch all materials for this ticket
                      final appProvider = Provider.of<AppProvider>(context, listen: false);
                      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
                      
                      try {
                        final materialsResult = await BookingApi.getMaterialsByTicketId(
                          ticketId: widget.ticketData!['id'] as int,
                          token: token,
                          context: context,
                        );
                        
                        final materials = materialsResult?['materials'] as List? ?? [];
                        final materialsCount = materials.length;
                        
                        if (materialsCount > 0) {
                          // Show confirmation dialog
                          final localizations = AppLocalizations.of(context);
                          final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                          final isArabic = languageProvider.lang == "ar";
                          
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
                              content: Text(
                                isArabic
                                    ? 'سيتم حذف جميع المواد المرتبطة بهذا التذكرة ($materialsCount ${materialsCount == 1 ? 'مادة' : 'مواد'}). هل أنت متأكد؟'
                                    : 'This will delete all materials associated with this ticket ($materialsCount material${materialsCount > 1 ? 's' : ''}). Are you sure?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(localizations?.cancel ?? 'Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: Text(localizations?.delete ?? 'Delete'),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldDelete != true) {
                            // User cancelled, don't change the toggle
                            return;
                          }
                          
                          // Delete all materials
                          bool allDeleted = true;
                          for (var material in materials) {
                            final materialId = material['id'] as int?;
                            if (materialId != null) {
                              final deleted = await BookingApi.deleteMaterial(
                                token: token,
                                materialId: materialId,
                                context: context,
                              );
                              if (!deleted) {
                                allDeleted = false;
                              }
                            }
                          }
                          
                          if (allDeleted && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'تم حذف $materialsCount ${materialsCount == 1 ? 'مادة' : 'مواد'} بنجاح'
                                      : 'Successfully deleted $materialsCount material${materialsCount > 1 ? 's' : ''}',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'حدث خطأ أثناء حذف بعض المواد'
                                      : 'An error occurred while deleting some materials',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                        
                        // Update the toggle
                        if (mounted) {
                          setState(() {
                            withMaterial = value;
                            // Clear materials note when disabling
                            if (!value) {
                              materialsNote.clear();
                            }
                          });
                        }
                      } catch (e) {
                        log('Error deleting materials: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic
                                    ? 'حدث خطأ أثناء حذف المواد'
                                    : 'An error occurred while deleting materials',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        // Don't update the toggle if there was an error
                        return;
                      }
                    } else {
                      // Toggling from false to true, or no materials to delete - just update normally
                      setState(() {
                        withMaterial = value;
                        // Clear materials note when disabling
                        if (!value) {
                          materialsNote.clear();
                        }
                      });
                    }
                  },
                  activeColor: Colors.orange,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Materials Note (only shown when withMaterial is true)
          if (withMaterial) ...[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.materialsNote ?? 'Materials Note',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      WidgetTextField(
                        AppLocalizations.of(context)?.materialsNotePlaceholder ?? 'Add notes about materials...',
                        controller: materialsNote,
                        maxLines: 4,
                        maxLength: 500,
                        fillColor: AppColors.greyColorback,
                        haveBorder: false,
                        radius: 5,
                        onChanged: (value) {
                          setState(() {
                            // Clear any errors when user starts typing
                          });
                        },
                      ),
                      Positioned(
                        bottom: 8,
                        right: isArabic ? null : 12,
                        left: isArabic ? 12 : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${materialsNote.text.length} / 500',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Materials List Section (only shown when editing) - HIDDEN
          ],

          // Toggle: With Female Engineer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greyColorback,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.havingFemaleEngineer,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: withFemaleEngineer,
                  onChanged: (value) {
                    setState(() {
                      withFemaleEngineer = value;
                    });
                  },
                  activeColor: Colors.orange,
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attachments
          _buildAttachmentsSection(localizations),
        ],
      ),
    );
  }

  Widget _buildTab3Summary(AppLocalizations localizations) {
    // Get display text for time slot
    String getTimeSlotDisplay() {
      if (selectedTimeFrom != null && selectedTimeTo != null) {
        try {
          final slot = allTimeSlots.firstWhere(
            (slot) => slot['from'] == selectedTimeFrom && slot['to'] == selectedTimeTo,
          );
          return slot['display'] ?? '${selectedTimeFrom} - ${selectedTimeTo}';
        } catch (e) {
          return '${selectedTimeFrom} - ${selectedTimeTo}';
        }
      }
      return '-';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ticket Title
          if (ticketTitle.text.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.ticketTitle,
              value: ticketTitle.text,
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
          ],

          // 2. Ticket Description
          if (ticketDescription.text.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.problemDescription,
              value: ticketDescription.text,
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
          ],
          // 3. Service Description
          if (_serviceDescriptionText.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.serviceDescription,
              value: _serviceDescriptionText,
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
          ],
          // 4. Ticket Type
          if (selectedTicketType != null && selectedTicketType!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.ticketType,
              value: selectedTicketType!.title,
              icon: Icons.category,
            ),
            const SizedBox(height: 16),
          ],

          // 5. Date and Time (same line)
          if (selectedTicketDate != null || (selectedTimeFrom != null && selectedTimeTo != null)) ...[
            _buildSummaryDateTimeRow(localizations, getTimeSlotDisplay()),
            const SizedBox(height: 16),
          ],

          // 6. Main Service
          if (selectedMainService != null && selectedMainService!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.mainService,
              value: selectedMainService!.title,
              icon: Icons.build,
            ),
            const SizedBox(height: 16),
          ],

          // 7. Sub Service
          if (selectedSubService != null && selectedSubService!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.subService,
              value: selectedSubService!.title,
              icon: Icons.settings,
            ),
            const SizedBox(height: 16),
          ],


          // 8. Team Leader (show if not delegated to WeFix, or if delegated and user is from WeFix)
          if ((!isDelegatedToWeFix || (isDelegatedToWeFix && isWeFixUser)) && selectedTeamLeader != null && selectedTeamLeader!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.teamLeaderId,
              value: selectedTeamLeader!.title,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
          ],

          // 9. Technician (show if not delegated to WeFix, or if delegated and user is from WeFix)
          if ((!isDelegatedToWeFix || (isDelegatedToWeFix && isWeFixUser)) && selectedTechnician != null && selectedTechnician!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.technicianId,
              value: selectedTechnician!.title,
              icon: Icons.engineering,
            ),
            const SizedBox(height: 16),
          ],
          
          // Show delegation message if delegated to WeFix
          if (isDelegatedToWeFix) ...[
            _buildSummaryRow(
              label: 'Delegation',
              value: 'Delegated to WeFix Team',
              icon: Icons.how_to_reg,
            ),
            const SizedBox(height: 16),
          ],

          // 10. Contract Reference
          if (selectedContract != null && selectedContract!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.contractId,
              value: selectedContract!.title,
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
          ],

          // 11. Branch
          if (selectedBranch != null && selectedBranch!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.branchId,
              value: selectedBranch!.title,
              icon: Icons.business,
            ),
            const SizedBox(height: 16),
          ],

          // 12. Zone
          if (selectedZone != null && selectedZone!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.zoneId,
              value: selectedZone!.title,
              icon: Icons.map,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryDateTimeRow(AppLocalizations localizations, String timeDisplay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyColorback,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedTicketDate != null
                                ? DateFormat('yyyy-MM-dd').format(selectedTicketDate!)
                                : '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.timeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeDisplay != '-' ? timeDisplay : '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    // Don't show row if value is empty, null, or just '-'
    if (value.isEmpty || value.trim().isEmpty || value.trim() == '-') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyColorback,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndTimeRow(AppLocalizations localizations) {
    final isEmergency = selectedTicketType?.title.toLowerCase() == 'emergency' || selectedTicketType?.data?['name']?.toString().toLowerCase() == 'emergency';
    final availableSlots = getAvailableTimeSlots();
    
    // Get display text for selected time slot
    String getTimeDisplayText() {
      if (selectedTimeFrom != null && selectedTimeTo != null) {
        try {
          final slot = allTimeSlots.firstWhere(
            (slot) => slot['from'] == selectedTimeFrom && slot['to'] == selectedTimeTo,
          );
          return slot['display'] ?? '${selectedTimeFrom} - ${selectedTimeTo}';
        } catch (e) {
          return '${selectedTimeFrom} - ${selectedTimeTo}';
        }
      }
      return localizations.selectTime;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations.date} *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: isEmergency
                        ? null
                        : () async {
                            // Normalize dates to start of day for comparison
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final firstDate = today;
                            final lastDate = today.add(const Duration(days: 365));
                            
                            // Ensure initialDate is not before firstDate
                            DateTime initialDate;
                            final currentSelectedDate = selectedTicketDate;
                            if (currentSelectedDate != null) {
                              final selectedDate = DateTime(
                                currentSelectedDate.year,
                                currentSelectedDate.month,
                                currentSelectedDate.day,
                              );
                              initialDate = selectedDate.isBefore(firstDate) ? firstDate : selectedDate;
                            } else {
                              initialDate = firstDate;
                            }
                            
                            final date = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: firstDate,
                              lastDate: lastDate,
                            );

                            if (date != null && mounted) {
                              setState(() {
                                selectedTicketDate = date;
                                // Reset time selection and get available slots for new date
                                final now = DateTime.now();
                                final currentTimeInMinutes = now.hour * 60 + now.minute;
                                final sixteenHundredInMinutes = 16 * 60; // 16:00 = 960 minutes

                                // Check if selected date is today
                                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                                final availableSlots = getAvailableTimeSlots();
                                if (availableSlots.isNotEmpty) {
                                  selectedTimeFrom = availableSlots.first['from'];
                                  selectedTimeTo = availableSlots.first['to'];
                                } else if (isToday && currentTimeInMinutes >= sixteenHundredInMinutes) {
                                  // If current time exceeds 16:00 and no slots are available, default to the latest slot (16:00-18:00)
                                  final lastSlot = allTimeSlots.last;
                                  selectedTimeFrom = lastSlot['from'];
                                  selectedTimeTo = lastSlot['to'];
                                } else {
                                  selectedTimeFrom = null;
                                  selectedTimeTo = null;
                                }
                              });
                            }
                          },
                    child: Opacity(
                      opacity: isEmergency ? 0.6 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greyColorback,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedTicketDate != null ? DateFormat('yyyy-MM-dd').format(selectedTicketDate!) : localizations.selectDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedTicketDate != null ? Colors.black87 : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isEmergency)
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations.timeLabel} *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // For Emergency tickets, show fixed 90-120 minutes display
                  if (isEmergency)
                    Opacity(
                      opacity: 0.6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greyColorback,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                localizations.emergencyResponseTime,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () {
                        if (selectedTicketDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.pleaseSelectDateFirst),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        
                        if (availableSlots.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.noAvailableTimeSlots),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        // Convert available time slots to DropdownCardItem list
                        final items = availableSlots.map((slot) {
                          final displayText = slot['display']!;
                          final from = slot['from']!;
                          final to = slot['to']!;

                          return DropdownCardItem(
                            id: availableSlots.indexOf(slot),
                            title: displayText,
                            icon: Icons.access_time,
                            data: {'from': from, 'to': to},
                          );
                        }).toList();

                        DropdownCardItem? currentSelected;
                        if (selectedTimeFrom != null && selectedTimeTo != null) {
                          try {
                            currentSelected = items.firstWhere(
                              (item) => item.data!['from'] == selectedTimeFrom && item.data!['to'] == selectedTimeTo,
                            );
                          } catch (e) {
                            currentSelected = items.isNotEmpty ? items.first : null;
                          }
                        }

                        DraggableCardBottomSheet.show(
                          context: context,
                          title: localizations.timeLabel,
                          items: items,
                          selectedItem: currentSelected,
                          onItemSelected: (item) {
                            final from = item.data!['from'] as String;
                            final to = item.data!['to'] as String;
                            setState(() {
                              selectedTimeFrom = from;
                              selectedTimeTo = to;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.greyColorback,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                getTimeDisplayText(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selectedTimeFrom != null && selectedTimeTo != null ? Colors.black87 : Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        // Show error messages if validation failed
        if (fieldErrors['date'] != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              fieldErrors['date']!,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
        if (fieldErrors['time'] != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              fieldErrors['time']!,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownCard({
    required String title,
    required DropdownCardItem? selectedItem,
    required List<DropdownCardItem> items,
    required VoidCallback onTap,
    String? errorMessage,
    bool isDisabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyColorback,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: errorMessage != null ? Colors.red : Colors.grey[300]!,
                  width: errorMessage != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (selectedItem?.icon != null) ...[
                    Icon(
                      selectedItem!.icon,
                      color: AppColors(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedItem?.title ?? 'Select',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: selectedItem != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        if (selectedItem?.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            selectedItem!.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentsSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.attachment} (${localizations.optional})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadOptionsScreen(
                  data: {
                    'uploadedFiles': uploadedFiles,
                    'fromTicketCreation': true, // Flag to indicate this is from ticket creation
                  },
                ),
              ),
            ).then((result) {
              // Handle returned uploaded files from attachment screen
              if (result != null && result is Map<String, dynamic>) {
                final returnedFiles = result['uploadedFiles'] as List<Map<String, dynamic>>?;
                if (returnedFiles != null) {
                  setState(() {
                    uploadedFiles = returnedFiles;
                  });
                }
                // Ensure we stay on Tab 2 (Service Details) after returning
                if (_tabController.index != 1) {
                  _tabController.animateTo(1);
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greyColorback,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: AppColors(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    uploadedFiles.isEmpty ? localizations.addAttachment : '${uploadedFiles.length} file(s) attached',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        // Display uploaded files list (matching add_attachment_widget design)
        if (uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            AppText(context).attachments,
            style: TextStyle(
              fontSize: AppSize(context).smallText1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uploadedFiles.length,
              itemBuilder: (context, index) {
                final file = uploadedFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.greyColor1),
                    ),
                    leading: InkWell(
                      onTap: () async {
                        final file = uploadedFiles[index];
                        // Get the file path from any possible field
                        final path = file["file"] ?? file["audio"] ?? file["image"];

                        if (path != null && path.isNotEmpty) {
                          await _openFilePreviewForEditTicket(context, file, path);
                        }
                      },
                      child: _getFileIconForEditTicket(file),
                    ),
                    title: InkWell(
                      onTap: () async {
                        final file = uploadedFiles[index];
                        // Get the file path from any possible field
                        final path = file["file"] ?? file["audio"] ?? file["image"];

                        if (path != null && path.isNotEmpty) {
                          await _openFilePreviewForEditTicket(context, file, path);
                        }
                      },
                      child: Text(
                        _getFileNameForEditTicket(file, index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(file["audio"] != null ? Icons.play_arrow : Icons.remove_red_eye, color: AppColors(context).primaryColor),
                          onPressed: () async {
                            final file = uploadedFiles[index];
                            // Get the file path from any possible field
                            final path = file["file"] ?? file["audio"] ?? file["image"];

                            if (path != null && path.isNotEmpty) {
                              await _openFilePreviewForEditTicket(context, file, path);
                            }
                          },
                        ),
                        // Only show delete button for new files
                        if (file["isNew"] == true)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                uploadedFiles.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
          ),
        ],
      ],
    );
  }

  // Helper functions for attachments (matching add_attachment_widget.dart)
  bool _isAudioFileForEditTicket(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.m4a') ||
        lowerPath.endsWith('.mp3') ||
        lowerPath.endsWith('.wav') ||
        lowerPath.endsWith('.aac') ||
        lowerPath.endsWith('.ogg');
  }

  bool _isVideoFileForEditTicket(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.mp4') ||
        lowerPath.endsWith('.mov') ||
        lowerPath.endsWith('.avi') ||
        lowerPath.endsWith('.mkv') ||
        lowerPath.endsWith('.m4v') ||
        lowerPath.endsWith('.webm');
  }

  bool _isImageFileForEditTicket(String? path) {
    if (path == null || path.isEmpty) return false;
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif') ||
        lowerPath.endsWith('.bmp') ||
        lowerPath.endsWith('.webp');
  }

  String _getFileNameForEditTicket(Map<String, dynamic> file, int index) {
    // Try filename field first
    if (file["filename"] != null && file["filename"]!.isNotEmpty) {
      return file["filename"]!;
    }
    
    // Try to extract from paths
    final filePath = file["file"] ?? file["image"] ?? file["audio"];
    if (filePath != null && filePath.isNotEmpty) {
      final parts = filePath.split('/');
      if (parts.isNotEmpty) {
        final fileName = parts.last;
        if (fileName.isNotEmpty) {
          return fileName;
        }
      }
    }
    
    // Fallback to generic name based on type
    if (file["audio"] != null) {
      return "${AppText(context).audio} ${index + 1}";
    } else if (file["image"] != null) {
      final path = file["image"]!.toLowerCase();
      if (path.contains('.mp4') || path.contains('.mov') || path.contains('.avi')) {
        return "${AppText(context).video} ${index + 1}";
      }
      return "${AppText(context).image} ${index + 1}";
    } else if (file["file"] != null) {
      return "${AppText(context).file} ${index + 1}";
    }
    
    return "${AppText(context).file} ${index + 1}";
  }

  Widget _getFileIconForEditTicket(Map<String, dynamic> file) {
    // Check audio files first
    if (file["audio"] != null) {
      return SvgPicture.asset("assets/icon/mp4.svg", width: 40);
    }

    // Check video files
    final filePath = file["file"] ?? file["image"];
    if (filePath != null && _isVideoFileForEditTicket(filePath)) {
      return SvgPicture.asset("assets/icon/vid.svg", width: 40);
    }

    // Check image files
    if (filePath != null && _isImageFileForEditTicket(filePath)) {
      return SvgPicture.asset("assets/icon/imge.svg", width: 40);
    }

    // Default to file icon for other types
    return SvgPicture.asset("assets/icon/file.svg", width: 40);
  }

  Future<void> _openFilePreviewForEditTicket(BuildContext context, Map<String, dynamic> file, String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid file path'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Check if it's a local file path (not starting with http/https)
      final isLocalFile = !path.startsWith('http://') && !path.startsWith('https://');
      
      // Check if it's a video file - show in-app player
      if (_isVideoFileForEditTicket(path)) {
        _showVideoPlayerForEditTicket(context, path, !isLocalFile);
        return;
      }
      
      if (_isAudioFileForEditTicket(path) || file["audio"] != null) {
        _showAudioPlayerForEditTicket(context, path, !isLocalFile);
        return;
      }
      
      // For images, show in preview dialog
      if (_isImageFileForEditTicket(path) || file["image"] != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppText(context).preview),
            content: SizedBox(
              width: double.maxFinite,
              child: isLocalFile
                  ? Image.file(File(path))
                  : CachedNetworkImage(
                      imageUrl: path,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.contain,
                    ),
            ),
            actions: [
              TextButton(
                child: Text(AppText(context).close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
      
      // For other file types, open with system default app
      if (isLocalFile) {
        final result = await OpenFile.open(path);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // For remote URLs, download first then open
        await _downloadAndOpenFileForEditTicket(context, path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVideoPlayerForEditTicket(BuildContext context, String filePath, bool isUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Video Player', style: TextStyle(color: Colors.white)),
            ),
            Flexible(
              child: isUrl ? _VideoPlayerNetworkWidget(url: filePath) : _VideoPlayerFileWidget(filePath: filePath),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioPlayerForEditTicket(BuildContext context, String filePath, bool isUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Audio Player', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isUrl ? _AudioPlayerNetworkWidget(url: filePath) : _AudioPlayerFileWidget(filePath: filePath),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadAndOpenFileForEditTicket(BuildContext context, String url) async {
    try {
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Downloading file...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to download file: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get temporary directory
      final tempDir = Directory.systemTemp;
      
      // Extract file name from URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.isNotEmpty 
          ? pathSegments.last 
          : 'file_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create temporary file path
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      
      // Write downloaded bytes to file
      await file.writeAsBytes(response.bodyBytes);
      
      // Hide loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Open the file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper function to detect file type
}

// Video Player Widget for local files
class _VideoPlayerFileWidget extends StatefulWidget {
  final String filePath;
  const _VideoPlayerFileWidget({required this.filePath});

  @override
  State<_VideoPlayerFileWidget> createState() => _VideoPlayerFileWidgetState();
}

class _VideoPlayerFileWidgetState extends State<_VideoPlayerFileWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    
    _controller = VideoPlayerController.file(File(widget.filePath));
    
    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted && !_isDisposed) {
        print('VideoPlayer initialization error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || _isDisposed) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              if (_isDisposed || _controller == null) return;
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Store reference and clear immediately
    final controller = _controller;
    _controller = null;
    
    // Dispose asynchronously to avoid blocking
    if (controller != null) {
      Future.microtask(() async {
        try {
          // Wait a bit for any pending operations
          await Future.delayed(const Duration(milliseconds: 50));
          
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          
          controller.dispose();
        } catch (e) {
          // Silently catch disposal errors
        }
      });
    }
    
    super.dispose();
  }
}

// Video Player Widget for network URLs
class _VideoPlayerNetworkWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerNetworkWidget({required this.url});

  @override
  State<_VideoPlayerNetworkWidget> createState() => _VideoPlayerNetworkWidgetState();
}

class _VideoPlayerNetworkWidgetState extends State<_VideoPlayerNetworkWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    
    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted && !_isDisposed) {
        print('VideoPlayer initialization error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || _isDisposed) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              if (_isDisposed || _controller == null) return;
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Store reference and clear immediately
    final controller = _controller;
    _controller = null;
    
    // Dispose asynchronously to avoid blocking
    if (controller != null) {
      Future.microtask(() async {
        try {
          // Wait a bit for any pending operations
          await Future.delayed(const Duration(milliseconds: 50));
          
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          
          controller.dispose();
        } catch (e) {
          // Silently catch disposal errors
        }
      });
    }
    
    super.dispose();
  }
}

// Audio Player Widget for local files
class _AudioPlayerFileWidget extends StatefulWidget {
  final String filePath;
  const _AudioPlayerFileWidget({required this.filePath});

  @override
  State<_AudioPlayerFileWidget> createState() => _AudioPlayerFileWidgetState();
}

class _AudioPlayerFileWidgetState extends State<_AudioPlayerFileWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(DeviceFileSource(widget.filePath));
            }
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Audio Player Widget for network URLs
class _AudioPlayerNetworkWidget extends StatefulWidget {
  final String url;
  const _AudioPlayerNetworkWidget({required this.url});

  @override
  State<_AudioPlayerNetworkWidget> createState() => _AudioPlayerNetworkWidgetState();
}

class _AudioPlayerNetworkWidgetState extends State<_AudioPlayerNetworkWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
          onPressed: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              await _audioPlayer.play(UrlSource(widget.url));
            }
            setState(() {
              _isPlaying = !_isPlaying;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
