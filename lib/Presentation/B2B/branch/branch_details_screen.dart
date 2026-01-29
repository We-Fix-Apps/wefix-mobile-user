import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/branch_model.dart';
import 'package:wefix/l10n/app_localizations.dart';

class BranchDetailsScreen extends StatefulWidget {
  final Branch branch;

  const BranchDetailsScreen({
    super.key,
    required this.branch,
  });

  @override
  State<BranchDetailsScreen> createState() => _BranchDetailsScreenState();
}

class _BranchDetailsScreenState extends State<BranchDetailsScreen> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  String? _formattedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _reverseGeocodeLocation();
  }
  
  Future<void> _reverseGeocodeLocation() async {
    if (!_hasValidCoordinates()) {
      return;
    }
    
    setState(() {
      _isLoadingAddress = true;
    });
    
    try {
      final lat = double.tryParse(widget.branch.latitude);
      final lng = double.tryParse(widget.branch.longitude);
      
      if (lat != null && lng != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks[0];
          // Format: City, State, Country
          List<String> addressParts = [];
          
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }
          
          setState(() {
            _formattedAddress = addressParts.isNotEmpty ? addressParts.join(', ') : null;
            _isLoadingAddress = false;
          });
        } else {
          setState(() {
            _isLoadingAddress = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      log('Reverse geocoding error: $e');
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _initializeMarkers() {
    final lat = double.tryParse(widget.branch.latitude);
    final lng = double.tryParse(widget.branch.longitude);
    
    if (lat != null && lng != null && 
        !lat.isNaN && !lng.isNaN &&
        lat != 0.0 && lng != 0.0 &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180) {
      _markers.add(
        Marker(
          markerId: const MarkerId('branch_location'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: widget.branch.name.isNotEmpty ? widget.branch.name : "Branch Location",
            snippet: widget.branch.address.isNotEmpty 
                ? widget.branch.address 
                : widget.branch.city.isNotEmpty 
                    ? widget.branch.city 
                    : AppLocalizations.of(context)!.branches,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.branch.name.isNotEmpty ? widget.branch.name : AppLocalizations.of(context)!.branchDetails,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch Header Card
            _buildHeaderCard(context),
            const SizedBox(height: 20),
            
            // Branch Information Section
            _buildSectionTitle(AppLocalizations.of(context)!.branchInformation),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              _buildInfoRow(
                icon: Icons.business,
                label: AppLocalizations.of(context)!.branchNameEnglish,
                value: widget.branch.name.isNotEmpty ? widget.branch.name : AppLocalizations.of(context)!.na,
              ),
              if (widget.branch.nameAr.isNotEmpty) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  icon: Icons.translate,
                  label: AppLocalizations.of(context)!.branchNameArabic,
                  value: widget.branch.nameAr,
                ),
              ],
            ]),
            
            // Team Leader Information Section
            if (widget.branch.teamLeaderName != null && widget.branch.teamLeaderName!.isNotEmpty ||
                widget.branch.teamLeaderLookupId != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle(AppLocalizations.of(context)!.teamLeader),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (widget.branch.teamLeaderName != null && widget.branch.teamLeaderName!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: AppLocalizations.of(context)!.teamLeaderName,
                    value: widget.branch.teamLeaderName!,
                  ),
                  if (widget.branch.teamLeaderNameArabic != null && widget.branch.teamLeaderNameArabic!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.translate,
                      label: AppLocalizations.of(context)!.teamLeaderNameArabic,
                      value: widget.branch.teamLeaderNameArabic!,
                    ),
                  ],
                  if (widget.branch.teamLeaderCode != null && widget.branch.teamLeaderCode!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.code,
                      label: AppLocalizations.of(context)!.code,
                      value: widget.branch.teamLeaderCode!,
                    ),
                  ],
                  if (widget.branch.teamLeaderDescription != null && widget.branch.teamLeaderDescription!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.description,
                      label: AppLocalizations.of(context)!.description,
                      value: widget.branch.teamLeaderDescription!,
                    ),
                  ],
                ],
              ]),
            ],
            
            // Company Information Section
            if (widget.branch.companyName != null && widget.branch.companyName!.isNotEmpty ||
                widget.branch.companyId != null && widget.branch.companyId!.isNotEmpty ||
                widget.branch.companyTitle != null && widget.branch.companyTitle!.isNotEmpty ||
                widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionTitle(AppLocalizations.of(context)!.companyInformation),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (widget.branch.companyName != null && widget.branch.companyName!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.corporate_fare,
                    label: AppLocalizations.of(context)!.companyName,
                    value: widget.branch.companyName!,
                  ),
                  if (widget.branch.companyNameArabic != null && widget.branch.companyNameArabic!.isNotEmpty ||
                      widget.branch.companyId != null && widget.branch.companyId!.isNotEmpty ||
                      widget.branch.companyTitle != null && widget.branch.companyTitle!.isNotEmpty ||
                      widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty)
                    const Divider(height: 24),
                ],
                if (widget.branch.companyNameArabic != null && widget.branch.companyNameArabic!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.translate,
                    label: AppLocalizations.of(context)!.companyNameArabic,
                    value: widget.branch.companyNameArabic!,
                  ),
                  if (widget.branch.companyId != null && widget.branch.companyId!.isNotEmpty ||
                      widget.branch.companyTitle != null && widget.branch.companyTitle!.isNotEmpty ||
                      widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty)
                    const Divider(height: 24),
                ],
                if (widget.branch.companyTitle != null && widget.branch.companyTitle!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.title,
                    label: AppLocalizations.of(context)!.companyTitle,
                    value: widget.branch.companyTitle!,
                  ),
                  if (widget.branch.companyId != null && widget.branch.companyId!.isNotEmpty ||
                      widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty)
                    const Divider(height: 24),
                ],
                if (widget.branch.companyId != null && widget.branch.companyId!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.tag,
                    label: AppLocalizations.of(context)!.companyId,
                    value: widget.branch.companyId!,
                  ),
                  if (widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty ||
                      widget.branch.customerId > 0)
                    const Divider(height: 24),
                ],
                if (widget.branch.companyHoAddress != null && widget.branch.companyHoAddress!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.home,
                    label: AppLocalizations.of(context)!.headOfficeAddress,
                    value: widget.branch.companyHoAddress!,
                  ),
                ],
              ]),
            ],
            
            const SizedBox(height: 20),
            
            // Representative Information Section
            if (widget.branch.representativeName != null && widget.branch.representativeName!.isNotEmpty ||
                widget.branch.phone.isNotEmpty ||
                widget.branch.representativeEmail != null && widget.branch.representativeEmail!.isNotEmpty) ...[
              _buildSectionTitle(AppLocalizations.of(context)!.representativeInformation),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (widget.branch.representativeName != null && widget.branch.representativeName!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.person,
                    label: AppLocalizations.of(context)!.representativeName,
                    value: widget.branch.representativeName!,
                  ),
                  if (widget.branch.phone.isNotEmpty || 
                      (widget.branch.representativeEmail != null && widget.branch.representativeEmail!.isNotEmpty))
                    const Divider(height: 24),
                ],
                if (widget.branch.phone.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: AppLocalizations.of(context)!.representativeMobileNumber,
                    value: widget.branch.phone,
                    onTap: () => _makePhoneCall(context, widget.branch.phone),
                  ),
                  if (widget.branch.representativeEmail != null && widget.branch.representativeEmail!.isNotEmpty)
                    const Divider(height: 24),
                ],
                if (widget.branch.representativeEmail != null && widget.branch.representativeEmail!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.email,
                    label: AppLocalizations.of(context)!.emailAddress,
                    value: widget.branch.representativeEmail!,
                    onTap: () => _sendEmail(context, widget.branch.representativeEmail!),
                  ),
              ]),
              const SizedBox(height: 20),
            ],
            
            // Location Information Section
            if (_formattedAddress != null && _formattedAddress!.isNotEmpty ||
                widget.branch.address.isNotEmpty ||
                _isLoadingAddress) ...[
              _buildSectionTitle(AppLocalizations.of(context)!.location),
              const SizedBox(height: 12),
              _buildInfoCard(context, [
                if (_formattedAddress != null && _formattedAddress!.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: AppLocalizations.of(context)!.address,
                    value: _formattedAddress!,
                  ),
                ] else if (widget.branch.address.isNotEmpty) ...[
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: AppLocalizations.of(context)!.address,
                    value: widget.branch.address,
                  ),
                ] else if (_isLoadingAddress) ...[
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: AppLocalizations.of(context)!.address,
                    value: AppLocalizations.of(context)!.loadingAddress,
                  ),
                ],
              ]),
              const SizedBox(height: 20),
            ],
            
            // Map Section - Always show map section
            _buildSectionTitle(AppLocalizations.of(context)!.locationOnMap),
            const SizedBox(height: 12),
            _buildMapWidget(context),
          ],
        ),
      ),
    );
  }

  bool _hasValidCoordinates() {
    // Check if latitude and longitude strings are not empty and not "0"
    if (widget.branch.latitude.isEmpty || widget.branch.longitude.isEmpty) {
      return false;
    }
    if (widget.branch.latitude.trim() == '0' || widget.branch.longitude.trim() == '0') {
      return false;
    }
    if (widget.branch.latitude.toLowerCase() == 'null' || widget.branch.longitude.toLowerCase() == 'null') {
      return false;
    }
    
    final lat = double.tryParse(widget.branch.latitude.trim());
    final lng = double.tryParse(widget.branch.longitude.trim());
    
    if (lat == null || lng == null) {
      return false;
    }
    
    return !lat.isNaN && !lng.isNaN &&
        lat != 0.0 && lng != 0.0 &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180;
  }

  LatLng _getBranchLocation() {
    // Default to Amman, Jordan if coordinates are invalid
    final defaultLat = 31.915079;
    final defaultLng = 35.883758;
    
    final lat = double.tryParse(widget.branch.latitude.trim());
    final lng = double.tryParse(widget.branch.longitude.trim());
    
    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      return LatLng(defaultLat, defaultLng);
    }
    
    return LatLng(lat, lng);
  }

  Widget _buildMapWidget(BuildContext context) {
    final location = _getBranchLocation();
    final hasValidCoords = _hasValidCoordinates();
    
    // Always show map, but log if using default coordinates
    if (!hasValidCoords) {
      log('Branch ${widget.branch.id}: Invalid coordinates (lat: ${widget.branch.latitude}, lng: ${widget.branch.longitude}), using default location');
    }
    
    return Container(
      height: AppSize(context).height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: location,
                zoom: hasValidCoords ? 15.0 : 12.0,
              ),
              markers: hasValidCoords ? _markers : {},
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                  // Animate to location after map is created
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _animateToLocation(location);
                    }
                  });
                }
              },
            ),
          ),
          // Show warning banner if coordinates are invalid
          if (!hasValidCoords)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.locationCoordinatesNotAvailable,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Button to open in Google Maps
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.extended(
              onPressed: () => _openInGoogleMaps(location),
              backgroundColor: AppColors(context).primaryColor,
              icon: const Icon(Icons.map, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.openInMaps,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _animateToLocation(LatLng location) async {
    try {
      if (!_mapController.isCompleted) return;
      
      final GoogleMapController controller = await _mapController.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('Timeout waiting for map controller');
          throw TimeoutException('Map controller timeout');
        },
      );
      
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      log('Error animating to location: $e');
    }
  }

  Future<void> _openInGoogleMaps(LatLng location) async {
    try {
      // Use the most compatible Google Maps URL format
      final url = 'https://maps.google.com/?q=${location.latitude},${location.longitude}';
      final uri = Uri.parse(url);
      
      // Try to launch directly - launchUrl handles errors gracefully
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps. Please make sure you have a browser or Google Maps app installed.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.branch.name.isNotEmpty ? widget.branch.name : AppLocalizations.of(context)!.branches,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (widget.branch.nameAr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.branch.nameAr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final isTappable = onTap != null;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.secoundryColor,
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
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      decoration: isTappable ? TextDecoration.underline : null,
                      decorationColor: AppColors.secoundryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isTappable)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make call to $phoneNumber'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot send email to $email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

