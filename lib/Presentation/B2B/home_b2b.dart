import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/model/subsicripe_model.dart';
import 'package:wefix/Data/model/ticket_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/bookings_screen.dart';
import 'package:wefix/Presentation/B2B/ticket/create_update_ticket_screen_v2.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/model/profile_model.dart';
import 'package:wefix/Business/end_points.dart';

import '../../l10n/app_localizations.dart';

class B2BHome extends StatefulWidget {
  final SubsicripeModel? subsicripeModel;

  const B2BHome({super.key, this.subsicripeModel});

  @override
  State<B2BHome> createState() => _B2BHomeState();
}

class _B2BHomeState extends State<B2BHome> with SingleTickerProviderStateMixin {
  bool? loading = false;
  TicketModel? ticketModel;
  Map<String, dynamic>? ticketStatistics;
  late AnimationController _loadingAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));
    
    getCompanyTickets();
    getTicketStatistics();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get bottom navigation bar height to add proper padding
    const bottomNavBarHeight = 32.0; // ConvexAppBar height from layout_screen
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loading == true
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors(context).primaryColor,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom:  bottomNavBarHeight + safeAreaBottom, // Extra padding for bottom nav
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const _HeaderSection(),
                    const SizedBox(height: 4),
                    _TicketSummarySection(
                      subsicripeModel: widget.subsicripeModel,
                      ticketStatistics: ticketStatistics,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _LastTicketsSection(
                        ticketModel: ticketModel,
                      ),
                    ),
                    const SizedBox(height: 12),
              // Hide "Add Ticket" button for Technicians and restricted roles
              // Only Admin (18), Team Leader (20), and Super User (26) can create tickets
              Builder(
                builder: (context) {
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  final currentUserRoleId = appProvider.userModel?.customer.roleId;
                  
                  // Parse roleId to integer
                  int? roleIdInt;
                  if (currentUserRoleId is int) {
                    roleIdInt = currentUserRoleId;
                  } else if (currentUserRoleId is String) {
                    roleIdInt = int.tryParse(currentUserRoleId);
                  } else if (currentUserRoleId != null) {
                    roleIdInt = int.tryParse(currentUserRoleId.toString());
                  }
                  
                  // Hide button for Technicians (21, 22) and restricted role (23)
                  // Only Admin (18), Team Leader (20), and Super User (26) can create new tickets
                  final canCreateTicket = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 26);
                  
                  if (!canCreateTicket) {
                    return const SizedBox.shrink(); // Hide button
                  }
                  
                  return SizedBox(
                height: 60,
                width: double.infinity,
                child: CustomBotton(
                  title: AppLocalizations.of(context)!.addTicket,
                      textSize: 16, // Ensure text size is appropriate
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateUpdateTicketScreenV2(),
                      ),
                    ).then((success) {
                      // Refresh tickets list if ticket was created/updated successfully
                      if (success == true) {
                        getCompanyTickets();
                      }
                    });
                  },
                ),
                  );
                },
              ),
                  ],
                ),
              ),
      ),
    );
  }

  Future getCompanyTickets() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    // Reset and start loading animation
    _loadingAnimationController.reset();
    _loadingAnimationController.forward();
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Use accessToken for MMS APIs, not userModel.token
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
      final ticketsData = await BookingApi.getCompanyTicketsFromMMS(
        token: token,
      );

      if (!mounted) return;

      if (ticketsData != null) {
        // Convert MMS tickets format to TicketModel format
        final allTickets = ticketsData['all']?['tickets'] ?? [];
        
        // Sort tickets by updatedAt (most recent first) and take only last 15
        final sortedTickets = List<Map<String, dynamic>>.from(allTickets);
        sortedTickets.sort((a, b) {
          final aUpdated = a['updatedAt'] ?? a['createdAt'] ?? '';
          final bUpdated = b['updatedAt'] ?? b['createdAt'] ?? '';
          return bUpdated.toString().compareTo(aUpdated.toString());
        });
        final last15Tickets = sortedTickets.take(15).toList();
        
        final tickets = last15Tickets.map<Ticket>((ticket) {
          final ticketDate = ticket['ticketDate'] != null ? DateTime.parse(ticket['ticketDate']) : DateTime.now();

          return Ticket(
            id: ticket['id'] ?? 0,
            customerId: 0, // Not available from MMS
            statusAr: ticket['ticketStatus']?['nameArabic'] ?? 'قيد الانتظار',
            ticketTypeId: ticket['ticketType']?['id'] ?? 0,
            rating: null,
            icon: ticket['mainService']?['image'] ?? ticket['mainService']?['icon'] ?? null, // Main service image
            mainServiceTitle: ticket['mainService']?['name'] ?? ticket['mainService']?['title'] ?? null,
            ticketCodeId: ticket['ticketCodeId']?.toString() ?? null,
            cancelButton: null,
            isRated: null,
            type: ticket['ticketType']?['name'],
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
            totalPrice: 0.0,
            serviceprovide: ticket['technician']?['name'] ?? null,
            serviceprovideImage: ticket['technician']?['profileImage'] ?? null,
            description: ticket['ticketDescription'] ?? '',
            descriptionAr: ticket['ticketDescription'] ?? '',
          );
        }).toList();

        if (!mounted) return;
        setState(() {
          ticketModel = TicketModel(tickets: tickets);
          loading = false;
        });
        // Reverse loading animation
        _loadingAnimationController.reverse();
      } else {
        if (!mounted) return;
        setState(() {
          ticketModel = TicketModel(tickets: []);
          loading = false;
        });
        // Reverse loading animation
        _loadingAnimationController.reverse();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      // Reverse loading animation
      _loadingAnimationController.reverse();
    }
  }

  Future getTicketStatistics() async {
    if (!mounted) return;
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Use accessToken for MMS APIs, not userModel.token
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
      final stats = await BookingApi.getTicketStatisticsFromMMS(
        token: token,
      );

      if (!mounted) return;

      if (stats != null) {
        setState(() {
          ticketStatistics = stats;
        });
      }
    } catch (e) {
      // Silently handle errors
    }
  }
}

// ---------------- Header ----------------
class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  ProfileModel? profileModel;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? "";
      if (token.isNotEmpty) {
        // Check if user is company personnel (roles: 18, 20, 21, 22, 26)
        final roleId = appProvider.userModel?.customer.roleId;
        final roleIdInt = roleId is int ? roleId : (roleId is String ? int.tryParse(roleId.toString()) : null);
        final bool isCompany = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22 || roleIdInt == 26);
        
        final profile = await ProfileApis.getProfileData(token: token, isCompany: isCompany);
        if (mounted) {
          setState(() {
            profileModel = profile;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    // Try to get profile image from profileModel
    final profileImage = profileModel?.profile?.profileImage;
    final userName = appProvider.userModel?.customer.name ?? "";

    // Helper function to check if image URL is valid (primary check)
    bool isValidImageUrl(String? imageUrl) {
      if (imageUrl == null || imageUrl.isEmpty) return false;
      if (imageUrl.toLowerCase() == "null") return false;
      if (imageUrl.trim().isEmpty) return false;
      return true;
    }

    // Helper function to build full URL for profile image from backend-mms
    // Mobile-user always connects to backend-mms
    // Backend-mms serves files from /uploads route (files stored in public/WeFixFiles/)
    String buildImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return "";
      
      // If already a full URL (http/https), return as is
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return imagePath;
      }
      
      // Build base URL from backend-mms
      // mmsBaseUrl format: https://wefix-backend-mms.ngrok.app/api/v1/
      String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
      
      // Normalize path - backend-mms now stores images in /WeFixFiles/Images/ to match backend-oms
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

    return Row(
      children: [
        // Primary: Profile Image, Secondary: Initials (fallback)
        isValidImageUrl(profileImage)
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: buildImageUrl(profileImage),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    radius: 24,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _getInitials(userName),
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    radius: 24,
                    child: Text(
                      _getInitials(userName),
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                radius: 24,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _getInitials(userName),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.hello} $userName",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.notifications_none_rounded, color: Colors.grey[600]),
      ],
    );
  }
}

// ---------------- Ticket Summary ----------------
class _TicketSummarySection extends StatefulWidget {
  final SubsicripeModel? subsicripeModel;
  final Map<String, dynamic>? ticketStatistics;

  const _TicketSummarySection({
    this.subsicripeModel,
    this.ticketStatistics,
  });

  @override
  State<_TicketSummarySection> createState() => _TicketSummarySectionState();
}

class _TicketSummarySectionState extends State<_TicketSummarySection> {
  @override
  Widget build(BuildContext context) {
    // Get ticket counts from MMS statistics
    // New format: {corrective: {total: X, completed: Y}, ...}
    // Old format (fallback): {corrective: X, ...}
    final correctiveData = widget.ticketStatistics?['byType']?['corrective'];
    final correctiveCompleted = (correctiveData is Map) ? (correctiveData['completed'] ?? 0).toString() : (correctiveData?.toString() ?? "0");
    final correctiveTotal =
        (correctiveData is Map) ? (correctiveData['total'] ?? 0).toString() : (correctiveData?.toString() ?? widget.subsicripeModel?.objSubscribe?.onDemandVisit.toString() ?? "0");

    final emergencyData = widget.ticketStatistics?['byType']?['emergency'];
    final emergencyCompleted = (emergencyData is Map) ? (emergencyData['completed'] ?? 0).toString() : (emergencyData?.toString() ?? "0");
    final emergencyTotal =
        (emergencyData is Map) ? (emergencyData['total'] ?? 0).toString() : (emergencyData?.toString() ?? widget.subsicripeModel?.objSubscribe?.emeregencyVisit.toString() ?? "0");

    return Column(
      children: [
                const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _SmallTicketCard(
            title: AppLocalizations.of(context)!.emergencyTickets,
            imagePath: 'assets/icon/image.png',
            used: emergencyCompleted,
            total: emergencyTotal,
          ),
        ),
        const SizedBox(height: 12),
        _CorrectiveTicketCard(
          used: correctiveCompleted,
          total: correctiveTotal,
        ),
      ],
    );
  }
}

class _CorrectiveTicketCard extends StatefulWidget {
  final String? used;
  final String? total;

  const _CorrectiveTicketCard({this.used, this.total});

  @override
  State<_CorrectiveTicketCard> createState() => _CorrectiveTicketCardState();
}

class _CorrectiveTicketCardState extends State<_CorrectiveTicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/icon/image copy.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.correctiveTickets,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 6,
                  percent: (() {
                    final used = double.tryParse(widget.used ?? "0") ?? 0;
                    final total = double.tryParse(widget.total ?? "1") ?? 1;
                    if (total == 0) return 0.0; // avoid division by zero
                    final ratio = used / total;
                    return ratio.clamp(0.0, 1.0); // ensure between 0 and 1
                  })(),
                  animation: true,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.4),
                  barRadius: const Radius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.used} / ${widget.total ?? 0}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _SmallTicketCard extends StatefulWidget {
  final String title;

  final String? used;
  final String? total;
  final String imagePath;

  const _SmallTicketCard({required this.title, required this.imagePath, this.used, this.total});

  @override
  State<_SmallTicketCard> createState() => _SmallTicketCardState();
}

class _SmallTicketCardState extends State<_SmallTicketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 6,
                  percent: (() {
                    final used = double.tryParse(widget.used ?? "0") ?? 0;
                    final total = double.tryParse(widget.total ?? "1") ?? 1;
                    if (total == 0) return 0.0; // avoid division by zero
                    final ratio = used / total;
                    return ratio.clamp(0.0, 1.0); // ensure between 0 and 1
                  })(),
                  animation: true,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.4),
                  barRadius: const Radius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.used} / ${widget.total ?? 0}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ---------------- Last Tickets ----------------
class _LastTicketsSection extends StatefulWidget {
  final TicketModel? ticketModel;
  const _LastTicketsSection({this.ticketModel});

  @override
  State<_LastTicketsSection> createState() => _LastTicketsSectionState();
}

class _LastTicketsSectionState extends State<_LastTicketsSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "T";
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Helper function to check if image URL is valid (primary check)
  bool _isValidImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    if (imageUrl.toLowerCase() == "null") return false;
    if (imageUrl.trim().isEmpty) return false;
    return true;
  }

  // Helper function to build full URL for technician image from backend-mms
  // Mobile-user always connects to backend-mms
  // Backend-mms serves files from /uploads route (files stored in public/WeFixFiles/)
    String _buildImageUrl(String? imagePath) {
      if (imagePath == null || imagePath.isEmpty) return "";
      
      // If already a full URL (http/https), return as is
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return imagePath;
      }
      
      // Build base URL from backend-mms
      // mmsBaseUrl format: https://wefix-backend-mms.ngrok.app/api/v1/
      String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
      
      // Normalize path - backend-mms now stores images in /WeFixFiles/Images/ to match backend-oms
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.lastTickets, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            const Spacer(),
            // Ticket count in green circle (current page / total)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  () {
                    final totalTickets = widget.ticketModel?.tickets.length ?? 0;
                    final ticketsPerPage = 3;
                    final startIndex = _currentPage * ticketsPerPage;
                    final endIndex = (startIndex + ticketsPerPage).clamp(0, totalTickets);
                    final currentCount = endIndex;
                    return "$currentCount / $totalTickets";
                  }(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  rightToLeft(BookingScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)!.viewAll, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: (widget.ticketModel?.tickets.length ?? 0) > 0 
                ? ((widget.ticketModel!.tickets.length / 3).ceil()) 
                : 0,
            itemBuilder: (context, pageIndex) {
              int startIndex = pageIndex * 3;
              int endIndex = (startIndex + 3).clamp(0, widget.ticketModel?.tickets.length ?? 0);
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 4),
                  itemCount: endIndex - startIndex,
                itemBuilder: (context, index) {
                  int ticketIndex = startIndex + index;
                  
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailsScreen(
                            id: widget.ticketModel?.tickets[ticketIndex].id.toString() ?? "",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar on the left with fixed width
                            SizedBox(
                              width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _isValidImage(widget.ticketModel?.tickets[ticketIndex].serviceprovideImage)
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: _buildImageUrl(widget.ticketModel?.tickets[ticketIndex].serviceprovideImage),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => CircleAvatar(
                                              backgroundColor: Colors.orange.shade100,
                                              radius: 22,
                                              child: const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => CircleAvatar(
                                              backgroundColor: Colors.orange.shade100,
                                              radius: 22,
                                              child: Text(
                                                _getInitials(widget.ticketModel?.tickets[ticketIndex].serviceprovide ?? ""),
                                                style: TextStyle(
                                                  color: Colors.orange.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.orange.shade100,
                                          radius: 22,
                                          child: Text(
                                            _getInitials(widget.ticketModel?.tickets[ticketIndex].serviceprovide ?? ""),
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(height: 5),
                                  // Ticket Code below avatar with text wrapping
                                  Text(
                                    widget.ticketModel?.tickets[ticketIndex].ticketCodeId != null
                                        ? widget.ticketModel!.tickets[ticketIndex].ticketCodeId!
                                        : "#${widget.ticketModel?.tickets[ticketIndex].id}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors(context).primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Ticket details (Title, Date, Assignee)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ticket Title
                                  Text(
                                    widget.ticketModel?.tickets[ticketIndex].location?.isNotEmpty == true
                                        ? widget.ticketModel!.tickets[ticketIndex].location!
                                        : widget.ticketModel?.tickets[ticketIndex].description?.isNotEmpty == true
                                            ? widget.ticketModel!.tickets[ticketIndex].description!
                                            : AppLocalizations.of(context)!.preventivevisits,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                  // Date
                                  Builder(
                                    builder: (context) {
                                      final locale = Localizations.localeOf(context);
                                      final dateFormat = DateFormat('d MMMM, yyyy', locale.languageCode);
                                      return Text(
                                        dateFormat.format(
                                          widget.ticketModel?.tickets[ticketIndex].selectedDate ?? DateTime.now(),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                  // Time (format without seconds: HH:mm:ss -> HH:mm)
                                  Builder(
                                    builder: (context) {
                                      // Helper function to format time without seconds
                                      String formatTimeWithoutSeconds(String? time) {
                                        if (time == null || time.isEmpty) return '';
                                        // Remove seconds if present (format: HH:mm:ss or HH:mm:ss.SSS)
                                        if (time.contains(':')) {
                                          final parts = time.split(':');
                                          if (parts.length >= 2) {
                                            return '${parts[0]}:${parts[1]}';
                                          }
                                        }
                                        return time;
                                      }
                                      
                                      final ticket = widget.ticketModel?.tickets[ticketIndex];
                                      String timeText = '';
                                      
                                      if (ticket?.timeFrom != null || ticket?.timeTo != null) {
                                        final timeFrom = formatTimeWithoutSeconds(ticket?.timeFrom?.toString());
                                        final timeTo = formatTimeWithoutSeconds(ticket?.timeTo?.toString());
                                        if (timeFrom.isNotEmpty && timeTo.isNotEmpty) {
                                          timeText = "$timeFrom - $timeTo";
                                        } else if (timeFrom.isNotEmpty) {
                                          timeText = timeFrom;
                                        } else if (timeTo.isNotEmpty) {
                                          timeText = timeTo;
                                        }
                                      } else if (ticket?.selectedDateTime != null) {
                                        // Format selectedDateTime (remove seconds if present)
                                        timeText = formatTimeWithoutSeconds(ticket!.selectedDateTime);
                                      }
                                      
                                      if (timeText.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 3),
                                          Text(
                                            timeText,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (widget.ticketModel?.tickets[ticketIndex].serviceprovide != null) ...[
                                    const SizedBox(height: 3),
                                    // Assignee/Technician name
                                    Text(
                                      widget.ticketModel!.tickets[ticketIndex].serviceprovide!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Main Service Info and Status badge (right column)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Main Service Icon (always show, with default if icon is missing)
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isValidImage(widget.ticketModel?.tickets[ticketIndex].icon)
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: _buildImageUrl(widget.ticketModel!.tickets[ticketIndex].icon),
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Icon(
                                              Icons.build,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.build,
                                              color: Colors.grey.shade400,
                                              size: 20,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.build,
                                          color: Colors.grey.shade400,
                                          size: 20,
                                        ),
                                ),
                                const SizedBox(height: 4),
                                // Main Service Title
                                if (widget.ticketModel?.tickets[ticketIndex].mainServiceTitle != null) ...[
                                  Text(
                                    widget.ticketModel!.tickets[ticketIndex].mainServiceTitle!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                ],
                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: widget.ticketModel?.tickets[ticketIndex].status == "Pending"
                                        ? Colors.orange.withOpacity(.15)
                                        : widget.ticketModel?.tickets[ticketIndex].status == "Cancelled"
                                            ? Colors.red.withOpacity(.15)
                                            : widget.ticketModel?.tickets[ticketIndex].status == "Completed"
                                                ? Colors.green.withOpacity(.15)
                                                : Colors.pink.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    widget.ticketModel?.tickets[ticketIndex].statusAr ?? 
                                    widget.ticketModel?.tickets[ticketIndex].status ?? "",
                                    style: TextStyle(
                                      color: widget.ticketModel?.tickets[ticketIndex].status == "Pending"
                                          ? Colors.orange.shade700
                                          : widget.ticketModel?.tickets[ticketIndex].status == "Cancelled"
                                              ? Colors.red.shade700
                                              : widget.ticketModel?.tickets[ticketIndex].status == "Completed"
                                                  ? Colors.green.shade700
                                                  : Colors.pink.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                ),
              );
            },
          ),
        ),
        // Pagination dots indicator
        Builder(
          builder: (context) {
            final totalPages = (widget.ticketModel?.tickets.length ?? 0) > 0 
                ? ((widget.ticketModel!.tickets.length / 3).ceil()) 
                : 0;
            if (totalPages <= 1) return const SizedBox.shrink();
            
            return Column(
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalPages,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index
                            ? AppColors(context).primaryColor
                            : AppColors(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
