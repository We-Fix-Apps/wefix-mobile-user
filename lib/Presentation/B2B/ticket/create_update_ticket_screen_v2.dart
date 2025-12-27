import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/B2B/ticket/components/draggable_card_bottom_sheet.dart';
import 'package:wefix/Presentation/B2B/ticket/components/dropdown_card_item.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/SubCategory/Components/add_attachment_widget.dart' show UploadOptionsScreen;
import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/l10n/app_localizations.dart';

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
      if (isEmergency) {
        return fromTimeInMinutes <= maxMinutes && fromTimeInMinutes < toTimeInMinutes;
      }

      // For corrective/preventive tickets: show all future slots (no 120-minute restriction)
      return fromTimeInMinutes < toTimeInMinutes;
    }).toList();
  }

  // Attachments
  List<Map<String, String?>> uploadedFiles = [];

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
      }
    });
  }

  Future<void> _loadInitialData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    // Load all data in parallel (zones will be loaded when branch is selected)
    final results = await Future.wait([
      BookingApi.getCompanyContracts(token: token, context: context),
      BookingApi.getCompanyBranches(token: token, context: context),
      // Zones will be loaded when branch is selected, so we don't load them here
      Future.value(null), // Placeholder for zones
      BookingApi.getMainServices(token: token, context: context),
      BookingApi.getSubServices(token: token, context: context),
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
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['contractReference'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['contractTitle'] as String?,
                  icon: Icons.description,
                  data: item,
                ))
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
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['name'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                  icon: Icons.build,
                  data: item,
                ))
            .toList();
      }

      // Sub Services
      final subServicesData = results[4];
      if (subServicesData is List<Map<String, dynamic>> && subServicesData.isNotEmpty) {
        subServices = subServicesData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['name'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                  icon: Icons.settings,
                  data: item,
                ))
            .toList();
      }

      // Team Leaders
      final teamLeadersData = results[5];
      if (teamLeadersData is List<Map<String, dynamic>> && teamLeadersData.isNotEmpty) {
        teamLeaders = teamLeadersData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['fullName'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['userNumber'] as String? ?? item['email'] as String?,
                  icon: Icons.person_outline,
                  data: item,
                ))
            .toList();
      }

      // Technicians
      final techniciansData = results[6];
      if (techniciansData is List<Map<String, dynamic>> && techniciansData.isNotEmpty) {
        technicians = techniciansData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['fullName'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['userNumber'] as String? ?? item['email'] as String?,
                  icon: Icons.engineering,
                  data: item,
                ))
            .toList();
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

      // Auto-select first items
      if (contracts.isNotEmpty) selectedContract = contracts.first;
      if (branches.isNotEmpty) {
        selectedBranch = branches.first;
        // Load zones for the first branch
        _loadZonesForBranch(branches.first.id);
      }
      if (mainServices.isNotEmpty) {
        selectedMainService = mainServices.first;
        // Load sub services for the first main service
        _loadSubServices(mainServices.first.id);
      }
      if (subServices.isNotEmpty) selectedSubService = subServices.first;

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

      // If user is Team Leader (found in list OR roleId == 20), hide Team Leader dropdown and auto-select themselves
      // Team Leaders CANNOT create tickets for another Team Leader - they can only assign to themselves
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
      } else if (teamLeaders.isNotEmpty) {
        // Admin or other role: Show dropdown, auto-select first
        // Admins CAN create tickets for any Team Leader
        setState(() {
          isTeamLeaderVisible = true;
        });
        selectedTeamLeader = teamLeaders.first;
      }

      // Auto-select first technician
      if (technicians.isNotEmpty) {
        selectedTechnician = technicians.first;
      }

      // Set default date
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
          }
        } catch (e) {
          log('Could not find matching contract: $e');
        }
      }

      // Populate branch and load zones
      if (data['branch'] != null && branches.isNotEmpty) {
        try {
          final branchId = data['branch']['id'] as int?;
          if (branchId != null) {
            selectedBranch = branches.firstWhere(
              (branch) => branch.id == branchId,
            );
            // Load zones for the selected branch
            _loadZonesForBranch(branchId).then((_) {
              // After zones are loaded, select the zone from ticket data
              if (data['zone'] != null && zones.isNotEmpty) {
                try {
                  final zoneId = data['zone']['id'] as int?;
                  if (zoneId != null) {
                    setState(() {
                      selectedZone = zones.firstWhere(
                        (zone) => zone.id == zoneId,
                      );
                    });
                  }
                } catch (e) {
                  // Zone not found
                }
              }
            });
          }
        } catch (e) {
          // Branch not found
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
          // Default to first status if available
          if (ticketStatuses.isNotEmpty) {
            selectedTicketStatus = ticketStatuses.first;
          }
        }
      } else if (ticketStatuses.isNotEmpty) {
        // If no status in ticket data, default to first status
        selectedTicketStatus = ticketStatuses.first;
      }
      // TODO: Map other fields when APIs are available
    });
  }

  Future<void> _loadSubServices(int mainServiceId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    final subServicesData = await BookingApi.getSubServices(
      token: token,
      parentServiceId: mainServiceId,
      context: context,
    );

    if (!mounted) return;

    setState(() {
      if (subServicesData != null) {
        subServices = subServicesData
            .map((item) => DropdownCardItem(
                  id: item['id'] as int,
                  title: item['title'] as String? ?? item['name'] as String? ?? '',
                  subtitle: item['subtitle'] as String? ?? item['nameArabic'] as String?,
                  icon: Icons.settings,
                  data: item,
                ))
            .toList();
        // Auto-select first sub service if available
        if (subServices.isNotEmpty) {
          selectedSubService = subServices.first;
        }
      }
    });
  }

  Future<void> _loadZonesForBranch(int branchId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';

    if (token.isEmpty) {
      return;
    }

    final zonesData = await BookingApi.getCompanyZones(
      token: token,
      branchId: branchId,
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
        // Auto-select first zone if available
        if (zones.isNotEmpty) {
          selectedZone = zones.first;
        } else {
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

  // Helper function to convert time string (HH:mm:ss) to minutes from midnight
  int _timeStringToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  // Validate that selected times are within 120 minutes from current time
  // Both selectedTimeFrom and selectedTimeTo must be from current time to 120 minutes after current time
  bool _validateTimeRange(String? timeFrom, String? timeTo) {
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
        fieldErrors['ticketTitle'] = 'Ticket Title Required';
        isValid = false;
      } else if (ticketTitle.text.trim().length > 100) {
        fieldErrors['ticketTitle'] = 'Ticket Title must not exceed 100 characters';
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
        fieldErrors['time'] = '${localizations.timeFrom} - ${localizations.timeTo} ${localizations.required}';
        isValid = false;
      } else if (isEmergency && selectedTimeFrom != null && selectedTimeTo != null) {
        // For emergency tickets only: validate time range must be within 120 minutes from current time
        if (!_validateTimeRange(selectedTimeFrom, selectedTimeTo)) {
          fieldErrors['time'] = 'Time must be from current time to 120 minutes later';
          isValid = false;
        }
      }
      // Note: Emergency tickets will have time auto-generated in _submit() if not selected
      // Note: Corrective and Preventive tickets can select any available time slot (no 120-minute restriction)
      if (isTeamLeaderVisible && selectedTeamLeader == null) {
        fieldErrors['teamLeader'] = '${localizations.teamLeaderId} ${localizations.required}';
        isValid = false;
      }
      if (selectedTechnician == null) {
        fieldErrors['technician'] = '${localizations.technicianId} ${localizations.required}';
        isValid = false;
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
      // Service Description is required
      if (serviceDescription.text.trim().isEmpty) {
        fieldErrors['serviceDescription'] = '${localizations.serviceDescription} ${localizations.required}';
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
          content: Text(errorMessages.length == 1 ? errorMessages.first : '${localizations.required}: ${errorMessages.join(', ')}'),
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
            return '${localizations.timeFrom} - ${localizations.timeTo}';
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

        // For emergency tickets, if time is not selected, generate default time (current time to +120 minutes)
        String? timeFromStr = selectedTimeFrom;
        String? timeToStr = selectedTimeTo;

        if (isEmergency && (selectedTimeFrom == null || selectedTimeTo == null)) {
          final now = DateTime.now();
          final currentMinutes = now.hour * 60 + now.minute;
          final endMinutes = currentMinutes + 120; // 120 minutes from now

          final fromHour = (currentMinutes ~/ 60).toString().padLeft(2, '0');
          final fromMinute = (currentMinutes % 60).toString().padLeft(2, '0');
          final toHour = (endMinutes ~/ 60).toString().padLeft(2, '0');
          final toMinute = (endMinutes % 60).toString().padLeft(2, '0');

          timeFromStr = '$fromHour:$fromMinute:00';
          timeToStr = '$toHour:$toMinute:00';

          log('Emergency ticket: Generated default time slots from $timeFromStr to $timeToStr');
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
              content: Text('Ticket Title must not exceed 100 characters'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (selectedTicketDate == null) missingFields.add(localizations.date);
        // Time fields are now required for all tickets (backend requirement)
        if (timeFromStr == null || timeToStr == null) {
          missingFields.add('${localizations.timeFrom} - ${localizations.timeTo}');
        }
        if (isTeamLeaderVisible && selectedTeamLeader == null) {
          missingFields.add(localizations.teamLeaderId);
        }
        if (selectedTechnician == null) missingFields.add(localizations.technicianId);
        if (selectedMainService == null) missingFields.add(localizations.mainService);
        if (selectedSubService == null) missingFields.add(localizations.subService);
        if (serviceDescription.text.trim().isEmpty) missingFields.add(localizations.serviceDescription);

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

        int teamLeaderId;
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
          'assignToTeamLeaderId': teamLeaderId, // Use validated team leader ID
          'assignToTechnicianId': selectedTechnician!.id,
          'ticketDescription': ticketDescription.text.trim(),
          'havingFemaleEngineer': false,
          'withMaterial': false,
          'mainServiceId': selectedMainService!.id,
          if (selectedSubService != null) 'subServiceId': selectedSubService!.id,
          if (serviceDescription.text.trim().isNotEmpty) 'serviceDescription': serviceDescription.text.trim(),
          // Note: fileIds will be sent separately after uploading files
          // Note: customerName, tools can be added later
        });

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
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Tab(text: localizations.serviceDetails),
                      Tab(text: localizations.ticketSummary),
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

          // 5. Team Leader Dropdown (hidden for Team Leaders, visible for Admins)
          if (isTeamLeaderVisible) ...[
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
                onSelected: (item) {
                  setState(() {
                    selectedContract = item;
                    fieldErrors.remove('contract');
                  });
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
                      "${localizations.serviceDescription} *",
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
                  // Load sub services based on selected main service
                  await _loadSubServices(item.id);
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


          // 8. Team Leader
          if (selectedTeamLeader != null && selectedTeamLeader!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.teamLeaderId,
              value: selectedTeamLeader!.title,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
          ],

          // 9. Technician
          if (selectedTechnician != null && selectedTechnician!.title.isNotEmpty) ...[
            _buildSummaryRow(
              label: localizations.technicianId,
              value: selectedTechnician!.title,
              icon: Icons.engineering,
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
                            '${localizations.timeFrom} - ${localizations.timeTo}',
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

  Widget _buildLocationMapPicker(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.locationMap,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showLocationMapBottomSheet(localizations);
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.greyColorback,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: selectedLocation != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: WidgewtGoogleMaps(
                      lat: selectedLocation!.latitude,
                      loang: selectedLocation!.longitude,
                      isFromCheckOut: true,
                      height: 200,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.selectDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showLocationMapBottomSheet(AppLocalizations localizations) {
    LatLng? tempLocation = selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.locationMap,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Map
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Stack(
                      children: [
                        WidgewtGoogleMaps(
                          lat: tempLocation?.latitude,
                          loang: tempLocation?.longitude,
                          isFromCheckOut: false,
                        ),
                        // Confirm button at bottom
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: CustomBotton(
                            title: 'Confirm Location',
                            onTap: () {
                              // Get location from AppProvider
                              final appProvider = Provider.of<AppProvider>(context, listen: false);
                              if (appProvider.position != null) {
                                final location = LatLng(
                                  appProvider.position!.latitude,
                                  appProvider.position!.longitude,
                                );
                                Navigator.pop(context);
                                setState(() {
                                  selectedLocation = location;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a location on the map')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(AppLocalizations localizations) {
    // Check if Emergency ticket type is selected
    final isEmergency = selectedTicketType?.title.toLowerCase() == 'emergency' || selectedTicketType?.data?['name']?.toString().toLowerCase() == 'emergency';

    return Column(
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
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedTicketDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedTicketDate != null ? DateFormat('yyyy-MM-dd').format(selectedTicketDate!) : localizations.selectDate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selectedTicketDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ),
                  if (!isEmergency)
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
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
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedTicketDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    '${localizations.timeFrom} - ${localizations.timeTo} *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      if (selectedTicketDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a date first'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      
                      if (availableSlots.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No available time slots for selected date. Please select a different date.'),
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
                        title: '${localizations.timeFrom} - ${localizations.timeTo}',
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

  Widget _buildTimeSlotDropdown(AppLocalizations localizations) {
    // Get display text for selected time slot
    String getDisplayText() {
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

    final availableSlots = getAvailableTimeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.timeFrom} - ${localizations.timeTo} *',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // Always allow tapping - show available slots or message
            if (availableSlots.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No available time slots for selected date. Please select a different date.'),
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
              title: '${localizations.timeFrom} - ${localizations.timeTo}',
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
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    getDisplayText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selectedTimeFrom != null && selectedTimeTo != null ? Colors.black87 : Colors.grey,
                    ),
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
        // Show error message if validation failed
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

  Widget _buildResponseTimeDisplay(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.responseTime,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '90 - 120 ${localizations.minutes}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                final returnedFiles = result['uploadedFiles'] as List<Map<String, String?>>?;
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
        // Display uploaded files count
        if (uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: uploadedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              final fileName = file['filename'] ?? file['image']?.split('/').last ?? file['file']?.split('/').last ?? file['audio']?.split('/').last ?? 'File ${index + 1}';
              final filePath = file['file'] ?? file['image'] ?? file['audio'];

              return InkWell(
                onTap: filePath != null
                    ? () {
                        _viewFile(filePath, file);
                      }
                    : null,
                child: Chip(
                  avatar: Icon(
                    file['file'] != null
                        ? Icons.insert_drive_file
                        : file['image'] != null
                            ? Icons.image
                            : Icons.audiotrack,
                    size: 18,
                  ),
                  label: Text(
                    fileName,
                    style: TextStyle(
                      color: filePath != null ? Colors.blue : Colors.grey,
                      decoration: filePath != null ? TextDecoration.underline : null,
                    ),
                  ),
                  onDeleted: () {
                    setState(() {
                      uploadedFiles.removeAt(index);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // Helper function to detect file type
  String _getFileType(String filePath, Map<String, String?> file) {
    // Check file map first
    if (file['image'] != null) {
      final path = file['image']!;
      if (path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov') || path.toLowerCase().endsWith('.avi') || path.toLowerCase().endsWith('.mkv')) {
        return 'video';
      }
      return 'image';
    }
    if (file['audio'] != null) return 'audio';
    if (file['file'] != null) {
      final path = file['file']!.toLowerCase();
      if (path.endsWith('.pdf') || path.endsWith('.doc') || path.endsWith('.docx') || path.endsWith('.xls') || path.endsWith('.xlsx') || path.endsWith('.txt')) {
        return 'document';
      }
      if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi') || path.endsWith('.mkv')) {
        return 'video';
      }
      if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a') || path.endsWith('.aac') || path.endsWith('.ogg')) {
        return 'audio';
      }
      if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.gif') || path.endsWith('.webp') || path.endsWith('.bmp')) {
        return 'image';
      }
    }

    // Fallback: check file extension from path
    final path = filePath.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi') || path.endsWith('.mkv')) {
      return 'video';
    }
    if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a') || path.endsWith('.aac') || path.endsWith('.ogg')) {
      return 'audio';
    }
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.gif') || path.endsWith('.webp') || path.endsWith('.bmp')) {
      return 'image';
    }
    if (path.endsWith('.pdf') || path.endsWith('.doc') || path.endsWith('.docx') || path.endsWith('.xls') || path.endsWith('.xlsx') || path.endsWith('.txt')) {
      return 'document';
    }

    return 'unknown';
  }

  // View file in appropriate viewer
  void _viewFile(String filePath, Map<String, String?> file) {
    final fileType = _getFileType(filePath, file);
    final isUrl = filePath.startsWith('http://') || filePath.startsWith('https://');

    if (fileType == 'image') {
      _showImageViewer(filePath, isUrl);
    } else if (fileType == 'video') {
      _showVideoPlayer(filePath, isUrl);
    } else if (fileType == 'audio') {
      _showAudioPlayer(filePath, isUrl);
    } else {
      // For documents and unknown files, use open_file or url_launcher
      if (isUrl) {
        _openUrlInBrowser(filePath);
      } else {
        _openFile(filePath);
      }
    }
  }

  // Show image viewer
  void _showImageViewer(String filePath, bool isUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isUrl
                    ? CachedNetworkImage(
                        imageUrl: filePath,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                    : Image.file(
                        File(filePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show video player
  void _showVideoPlayer(String filePath, bool isUrl) {
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

  // Show audio player
  void _showAudioPlayer(String filePath, bool isUrl) {
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

  // Open URL in browser (for documents)
  Future<void> _openUrlInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open file URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Open local file
  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Video Player Widget for local files
class _VideoPlayerFileWidget extends StatefulWidget {
  final String filePath;
  const _VideoPlayerFileWidget({required this.filePath});

  @override
  State<_VideoPlayerFileWidget> createState() => _VideoPlayerFileWidgetState();
}

class _VideoPlayerFileWidgetState extends State<_VideoPlayerFileWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
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
    _controller.dispose();
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
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
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
    _controller.dispose();
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
