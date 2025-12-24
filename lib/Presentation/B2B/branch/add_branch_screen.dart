import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/B2b/b2b_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/l10n/app_localizations.dart';

class AddBranchScreen extends StatefulWidget {
  const AddBranchScreen({super.key});

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  final TextEditingController branchName = TextEditingController();
  final TextEditingController branchNameAr = TextEditingController();

  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();

  bool isLoading = false;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _selectedLocation = const LatLng(31.915079, 35.883758); // Default to Amman
        });
        _updateMapLocation(_selectedLocation!);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _selectedLocation = const LatLng(31.915079, 35.883758);
          });
          _updateMapLocation(_selectedLocation!);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _selectedLocation = const LatLng(31.915079, 35.883758);
        });
        _updateMapLocation(_selectedLocation!);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = location;
        _isLoadingLocation = false;
      });
      
      _updateMapLocation(location);
      _performReverseGeocoding(location);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _selectedLocation = const LatLng(31.915079, 35.883758);
      });
      _updateMapLocation(_selectedLocation!);
    }
  }

  Future<void> _updateMapLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          icon: BitmapDescriptor.defaultMarker,
        ),
      };
    });

    try {
      final GoogleMapController controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      // Controller might not be ready yet
    }
  }

  Future<void> _performReverseGeocoding(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks[0];
        
        // Build a clean address without Plus Codes or unwanted data
        List<String> addressParts = [];
        
        // Filter out Plus Codes (format: XX+X+XX where X is alphanumeric)
        bool isValidAddressPart(String? part) {
          if (part == null || part.trim().isEmpty) return false;
          // Check if it's a Plus Code pattern (e.g., WV3Q+5G8)
          if (RegExp(r'^[A-Z0-9]{2,}\+[A-Z0-9]+$').hasMatch(part.trim())) return false;
          // Check if it's just punctuation or commas
          if (RegExp(r'^[،,.\s]+$').hasMatch(part.trim())) return false;
          return true;
        }
        
        // Add street name if available and valid
        if (isValidAddressPart(place.street)) {
          addressParts.add(place.street!.trim());
        }
        
        // Add thoroughfare if different from street and valid
        if (isValidAddressPart(place.thoroughfare) && 
            (place.street == null || place.thoroughfare != place.street)) {
          if (!addressParts.contains(place.thoroughfare!.trim())) {
            addressParts.add(place.thoroughfare!.trim());
          }
        }
        
        // Add subThoroughfare (building number) if available
        if (isValidAddressPart(place.subThoroughfare)) {
          addressParts.add(place.subThoroughfare!.trim());
        }
        
        // Add subLocality (neighborhood/district) if available and valid
        if (isValidAddressPart(place.subLocality)) {
          addressParts.add(place.subLocality!.trim());
        }
        
        // Build the full address string, filtering out empty parts
        List<String> cleanParts = addressParts.where((part) => part.isNotEmpty).toList();
        String formattedAddress = cleanParts.join(', ');
        
        // Update address field only if it's empty
        if (formattedAddress.isNotEmpty && address.text.isEmpty) {
          setState(() {
            address.text = formattedAddress;
          });
        }
        
        // Update city field - prioritize locality, then subAdministrativeArea, then administrativeArea
        if (city.text.isEmpty) {
          if (isValidAddressPart(place.locality)) {
            setState(() {
              city.text = place.locality!.trim();
            });
          } else if (isValidAddressPart(place.subAdministrativeArea)) {
            setState(() {
              city.text = place.subAdministrativeArea!.trim();
            });
          } else if (isValidAddressPart(place.administrativeArea)) {
            setState(() {
              city.text = place.administrativeArea!.trim();
            });
          }
        }
      }
    } catch (e) {
      // Geocoding failed, continue without updating fields
    }
  }

  Future<void> _searchPlaces() async {
    try {
      final p = await PlacesAutocomplete.show(
        context: context,
        apiKey: "AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0",
        language: "en",
        mode: Mode.overlay,
        region: "jo",
        types: [],
        overlayBorderRadius: BorderRadius.circular(20),
        components: [],
        strictbounds: false,
      );

      if (p != null && p.placeId != null) {
        _getLocationFromPlaceId(p.placeId!);
      }
    } catch (e) {
      // Search cancelled or failed
    }
  }

  Future<void> _getLocationFromPlaceId(String placeId) async {
    try {
      GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: "AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0",
      );

      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);

      if (detail.result.geometry?.location != null) {
        final location = LatLng(
          detail.result.geometry!.location.lat,
          detail.result.geometry!.location.lng,
        );

        _updateMapLocation(location);
        _performReverseGeocoding(location);

        // Update address field with the formatted address from Google Places (more accurate)
        if (detail.result.formattedAddress != null && detail.result.formattedAddress!.isNotEmpty) {
          if (mounted) {
            // Clean the formatted address - remove Plus Codes if present
            String cleanAddress = detail.result.formattedAddress!;
            // Remove Plus Code patterns (e.g., WV3Q+5G8) from the address
            cleanAddress = cleanAddress.replaceAll(RegExp(r'\s*[A-Z0-9]{2,}\+[A-Z0-9]+\s*,?\s*'), '');
            // Remove multiple commas
            cleanAddress = cleanAddress.replaceAll(RegExp(r',{2,}'), ',');
            // Remove leading/trailing commas and spaces
            cleanAddress = cleanAddress.trim().replaceAll(RegExp(r'^,\s*|\s*,$'), '');
            
            setState(() {
              // Use Google Places formatted address as it's more accurate
              address.text = cleanAddress;
            });
          }
          
          // Extract city from address components if available
          if (detail.result.addressComponents.isNotEmpty) {
            for (var component in detail.result.addressComponents) {
              if (component.types.isNotEmpty &&
                  (component.types.contains('locality') || 
                   component.types.contains('administrative_area_level_2'))) {
                if (city.text.isEmpty && component.longName.isNotEmpty) {
                  setState(() {
                    city.text = component.longName;
                  });
                  break;
                }
              }
            }
          }
        } else {
          // Fallback to reverse geocoding if formatted address not available
          _performReverseGeocoding(location);
        }
      }
    } catch (e) {
      // Handle error - could show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error finding location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addBranch),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------------- TextFields ----------------
              WidgetTextField(
                AppLocalizations.of(context)!.branchName,
                keyboardType: TextInputType.name,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: branchName,
                validator: (p0) {
                  if (branchName.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppLocalizations.of(context)!.branchNameAr,
                keyboardType: TextInputType.name,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: branchNameAr,
                validator: (p0) {
                  if (branchNameAr.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).email,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                keyboardType: TextInputType.emailAddress,
                controller: email,
                validator: (p0) {
                  if (email.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).phone,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                keyboardType: TextInputType.phone,
                controller: phone,
                validator: (p0) {
                  if (phone.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).city,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: city,
                validator: (p0) {
                  if (city.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).address,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: address,
                validator: (p0) {
                  if (address.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),
              
              // Map Picker Section
              Text(
                AppLocalizations.of(context)!.locationMap,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _searchPlaces,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.search,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: AppSize(context).height * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      _selectedLocation == null
                          ? Center(
                              child: _isLoadingLocation
                                  ? const CircularProgressIndicator()
                                  : const Text('Loading map...'),
                            )
                          : GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: _selectedLocation!,
                                zoom: 15.0,
                              ),
                              markers: _markers,
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
                                }
                              },
                              onTap: (LatLng location) {
                                _updateMapLocation(location);
                                _performReverseGeocoding(location);
                              },
                              onCameraMove: (CameraPosition position) {
                                // Update marker as user drags map
                                setState(() {
                                  _selectedLocation = position.target;
                                  _markers = {
                                    Marker(
                                      markerId: const MarkerId('selected_location'),
                                      position: position.target,
                                      icon: BitmapDescriptor.defaultMarker,
                                    ),
                                  };
                                });
                              },
                              onCameraIdle: () {
                                // Perform reverse geocoding when user stops moving map
                                if (_selectedLocation != null) {
                                  _performReverseGeocoding(_selectedLocation!);
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.youneedtoplacethemarkeronthemap,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),

              // ---------------- Submit Button ----------------
              CustomBotton(
                  title: AppLocalizations.of(context)!.addBranch,
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      createBranch();
                    }
                  },
                  loading: isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Future createBranch() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => isLoading = true);
    
    // Use accessToken for MMS API calls (B2B users)
    final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
    
    await B2bApi.createBranch(
      context: context,
      token: token,
      name: branchName.text,
      nameAr: branchNameAr.text,
      phone: phone.text,
      city: city.text,
      address: address.text,
      latitude: _selectedLocation != null ? _selectedLocation!.latitude.toString() : "",
      longitude: _selectedLocation != null ? _selectedLocation!.longitude.toString() : "",
    ).then((value) async {
      setState(() => isLoading = false);
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors(context).primaryColor,
            content: Text("${AppLocalizations.of(context)!.branchAddedSuccessfully} ✅"),
          ),
        );
        Navigator.pop(context, true); // Return true to refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors(context).primaryColor,
            content: Text(AppLocalizations.of(context)!.failedToAddBranch),
          ),
        );
      }
    }).catchError((error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors(context).primaryColor,
          content: Text("Error: ${error.toString()}"),
        ),
      );
    });
  }
}
