import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class WidgewtGoogleMaps extends StatefulWidget {
  final List<Placemark>? placemarks;
  final double? lat;
  final double? loang;
  final double? height;
  final bool? isHaveRadius;
  final bool? isConntactUs;
  final bool? isFromCheckOut;

  const WidgewtGoogleMaps({
    super.key,
    this.placemarks,
    this.lat,
    this.loang,
    this.height,
    this.isHaveRadius = false,
    this.isConntactUs = false,
    this.isFromCheckOut = false,
  });

  @override
  State<WidgewtGoogleMaps> createState() => _WidgewtGoogleMapsState();
}

class _WidgewtGoogleMapsState extends State<WidgewtGoogleMaps> with AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  Timer? _debounce;
  BitmapDescriptor? customIcon;
  late LatLng currentLocation;
  late CameraPosition initialCameraPosition;
  List<Placemark>? placemarks = [];
  @override
  void initState() {
    super.initState();
    placemarks = widget.placemarks;
    // Initialize the current location with passed lat/long or default
    currentLocation = LatLng(widget.lat ?? 31.915079, widget.loang ?? 35.883758);
    initialCameraPosition = CameraPosition(target: currentLocation, zoom: 14.4746);

    // Get device location and animate camera if lat/long are not passed
    _determinePosition().then((pos) => _getMyLocation());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    return Container(
      decoration: widget.isFromCheckOut == true
          ? null
          : BoxDecoration(
              border: Border.all(color: widget.isHaveRadius == true ? AppColors.greyColor1 : AppColors.whiteColor1),
              borderRadius: BorderRadius.circular(10),
            ),
      height: widget.height ?? 200,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          ClipRRect(
            borderRadius: widget.isHaveRadius == true ? BorderRadius.circular(10) : BorderRadius.zero,
            child: GoogleMap(
              mapToolbarEnabled: true,
              myLocationButtonEnabled: widget.isConntactUs == true ? false : true,
              scrollGesturesEnabled: widget.isFromCheckOut == true ? false : true,
              myLocationEnabled: widget.isFromCheckOut == true ? false : true,
              indoorViewEnabled: widget.isFromCheckOut == true ? false : true,
              zoomGesturesEnabled: widget.isFromCheckOut == true ? false : true,
              zoomControlsEnabled: widget.isFromCheckOut == true ? false : true,
              buildingsEnabled: widget.isFromCheckOut == false ? false : true,
              compassEnabled: widget.isFromCheckOut == false ? false : true,
              markers: markers,
              initialCameraPosition: initialCameraPosition,
              onCameraMove: widget.isFromCheckOut == true
                  ? (_) {}
                  : (position) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 200), () async {
                        final target = position.target;
                        setState(() => currentLocation = target);

                        _debounce = Timer(const Duration(seconds: 0), () async {
                          try {
                            // Safely access position.target with null check
                          final target = position.target;
                            
                            // Validate target coordinates
                            if (target.latitude.isNaN || target.longitude.isNaN ||
                                target.latitude == 0.0 && target.longitude == 0.0) {
                              log('Invalid target position: lat=${target.latitude}, lng=${target.longitude}');
                              return;
                            }

                          setState(() {
                              _currentLocation = target;
                            appProvider.saveCusrrentLocation(target);
                            appProvider.addLatAndLong(pos: target);
                          });

                            log(_currentLocation.toString());

                          try {
                            List<Placemark> placemarks3 =
                                await placemarkFromCoordinates(
                              target.latitude,
                              target.longitude,
                            );
                            appProvider.addAddress(placemarks: placemarks3);
                          } catch (e) {
                            log('Geocoding failed: $e');
                            }
                          } catch (e) {
                            log('Error accessing camera position target: $e');
                            // Don't crash, just log the error
                          }
                        });
                      },
                markers: markers,
                onTap: widget.isFromCheckOut == true
                    ? (p) {}
                    : (pos) async {
                        try {
                        List<Placemark> placemarks2 =
                            await placemarkFromCoordinates(
                                  _currentLocation.latitude,
                                  _currentLocation.longitude);
                        Marker m = Marker(
                            markerId: const MarkerId('1'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: pos);
                        setState(() {
                          widget.placemarks = placemarks2;
                          log(placemarks2.toString());
                          markers.add(m);
                        });

                        AppProvider appProvider =
                            // ignore: use_build_context_synchronously
                            Provider.of<AppProvider>(context, listen: false);

                        appProvider.addAddress(placemarks: placemarks2);
                        appProvider.addLatAndLong(pos: pos);

                          log(appProvider.position?.latitude.toString() ?? 'No position');
                        } catch (e) {
                          log('Error in onTap: $e');
                        }
                      },
                onMapCreated: (GoogleMapController controller) async {
                  try {
                  _controller.complete(controller);
                    try {
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                          _currentLocation.latitude, _currentLocation.longitude);
                  setState(() {
                    appProvider
                        .addAddress(placemarks: placemarks)
                        .then((value) {
                      setState(() {});
                    });
                  });
                    } catch (e) {
                      log('Geocoding failed in onMapCreated: $e');
                      // Continue even if geocoding fails
                    }
                  } catch (e) {
                    log('Error in onMapCreated: $e');
                  }
                },
                initialCameraPosition: initialCameraPosition),
          ),
          if (widget.isConntactUs == false && widget.isFromCheckOut == false)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors(context).primaryColor,
                child: IconButton(
                  onPressed: searchPlaces,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  final Completer<GoogleMapController> _controller = Completer();
  
  // Initialize with safe default values
  CameraPosition get initialCameraPosition {
    final defaultLat = 31.915079;
    final defaultLng = 35.883758;
    final targetLat = (lat != null && !lat!.isNaN && lat != 0.0) ? lat! : defaultLat;
    final targetLng = (loang != null && !loang!.isNaN && loang != 0.0) ? loang! : defaultLng;
    
    return CameraPosition(
      target: LatLng(targetLat, targetLng),
    zoom: 14.4746,
  );
  }
  
  LatLng get currentLocation {
    try {
      return initialCameraPosition.target;
    } catch (e) {
      log('Error getting current location from initialCameraPosition: $e');
      return const LatLng(31.915079, 35.883758);
    }
  }
  
  LatLng _currentLocation = const LatLng(31.915079, 35.883758);
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getMyLocation() async {
    try {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    if (lat != null && loang != null) {
        // Validate provided coordinates
        if (!lat!.isNaN && !loang!.isNaN && 
            !(lat == 0.0 && loang == 0.0)) {
      appProvider.saveCusrrentLocation(LatLng(lat!, loang!));
      _animateCamera(LatLng(lat!, loang!));
    } else {
          log('Invalid provided coordinates, using current location');
          _getCurrentLocationAndAnimate();
        }
      } else {
        _getCurrentLocationAndAnimate();
      }
    } catch (e) {
      log('Error in _getMyLocation: $e');
      // Fallback to default location
      _animateCamera(LatLng(31.915079, 35.883758));
    }
  }

  Future<void> _getCurrentLocationAndAnimate() async {
    try {
      Position myLocation = await Geolocator.getCurrentPosition();
      _animateCamera(LatLng(myLocation.latitude, myLocation.longitude));
    } catch (e) {
      log('Error getting current location: $e');
      // Fallback to default location
      _animateCamera(LatLng(31.915079, 35.883758));
    }
  }

  Future<void> _animateCamera(LatLng location) async {
    try {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
      
      // Validate location coordinates before proceeding
      if (location.latitude.isNaN || location.longitude.isNaN ||
          (location.latitude == 0.0 && location.longitude == 0.0)) {
        log('Invalid location coordinates: lat=${location.latitude}, lng=${location.longitude}');
        return;
      }

    final GoogleMapController controller = await _controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 15.00,
    );
    log("animating camera to (lat: ${location.latitude}, long: ${location.longitude}");
    appProvider
        .saveCusrrentLocation(LatLng(location.latitude, location.longitude));
      
      try {
    List<Placemark> placemarksCurrent =
        await placemarkFromCoordinates(location.latitude, location.longitude);
        appProvider.addAddress(placemarks: placemarksCurrent);
      } catch (e) {
        log('Geocoding failed in _animateCamera: $e');
        // Continue even if geocoding fails
      }

    controller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition))
        .then((value) {
      _setMarker(location);
      }).catchError((error) {
        log('Error animating camera: $error');
    });
    } catch (e) {
      log('Error in _animateCamera: $e');
    }
  }

  Future<void> _getLocationFromPlaceId(String placeId) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: "YOUR_API_KEY",
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);

    LatLng pos = LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));

    _setMarker(pos);
  }

  void _setMarker(LatLng location) {
    Marker newMarker = Marker(
      markerId: MarkerId(location.toString()),
      icon: customIcon ?? BitmapDescriptor.defaultMarker,
      position: location,
      infoWindow: const InfoWindow(snippet: ""),
    );

    setState(() {
      markers.add(newMarker);
    });
  }
}
