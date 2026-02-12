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
  LatLng _currentLocation = const LatLng(31.915079, 35.883758);
  List<Placemark>? placemarks = [];
  
  // Initialize with safe default values
  CameraPosition get initialCameraPosition {
    final defaultLat = 31.915079;
    final defaultLng = 35.883758;
    final targetLat = (widget.lat != null && !widget.lat!.isNaN && widget.lat != 0.0) ? widget.lat! : defaultLat;
    final targetLng = (widget.loang != null && !widget.loang!.isNaN && widget.loang != 0.0) ? widget.loang! : defaultLng;
    
    return CameraPosition(
      target: LatLng(targetLat, targetLng),
      zoom: 14.4746,
    );
  }
  
  @override
  void initState() {
    super.initState();
    placemarks = widget.placemarks;
    // Initialize the current location with passed lat/long or default
    _currentLocation = LatLng(widget.lat ?? 31.915079, widget.loang ?? 35.883758);
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
                        setState(() => _currentLocation = target);
                        appProvider.saveCusrrentLocation(target);
                        appProvider.addLatAndLong(pos: target);
                        try {
                          List<Placemark> placemarks3 = await placemarkFromCoordinates(target.latitude, target.longitude);
                          appProvider.addAddress(placemarks: placemarks3);
                        } catch (e) {
                          log('Geocoding failed: $e');
                        }
                      });
                    },
              onTap: widget.isFromCheckOut == true
                  ? (_) {}
                  : (pos) async {
                      List<Placemark> placemarks2 = await placemarkFromCoordinates(_currentLocation.latitude, _currentLocation.longitude);
                      Marker m = Marker(markerId: MarkerId(pos.toString()), icon: BitmapDescriptor.defaultMarker, position: pos);
                      setState(() {
                        markers.add(m);
                        placemarks = placemarks2;
                      });
                      appProvider.addAddress(placemarks: placemarks2);
                      appProvider.addLatAndLong(pos: pos);
                    },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          if (widget.isConntactUs == false && widget.isFromCheckOut == false)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors(context).primaryColor,
                child: IconButton(
                  onPressed: _searchPlaces,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
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
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    Position myLocation = await Geolocator.getCurrentPosition();
    
    if (widget.lat != null && widget.loang != null) {
      _currentLocation = LatLng(widget.lat!, widget.loang!);
    } else {
      _currentLocation = LatLng(myLocation.latitude, myLocation.longitude);
    }
    
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 15));
    
    // Add initial marker
    _setMarker(_currentLocation);
    
    try {
      List<Placemark> placemarksCurrent = await placemarkFromCoordinates(_currentLocation.latitude, _currentLocation.longitude);
      appProvider.addAddress(placemarks: placemarksCurrent);
    } catch (e) {
      log('Geocoding failed: $e');
    }
  }
  
  void _searchPlaces() async {
    var p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0",
      language: "ar",
      mode: Mode.overlay,
      components: [],
      overlayBorderRadius: BorderRadius.circular(20),
      strictbounds: false,
    );
    
    if (p != null) {
      _getLocationFromPlaceId(p.placeId!);
    }
  }
  
  Future<void> _getLocationFromPlaceId(String placeId) async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: "YOUR_API_KEY");
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);
      
      if (detail.status == "OK") {
        final lat = detail.result.geometry?.location.lat;
        final lng = detail.result.geometry?.location.lng;
        
        if (lat != null && lng != null) {
          LatLng selectedLocation = LatLng(lat, lng);
          
          // Update current location
          setState(() {
            _currentLocation = selectedLocation;
            markers.clear();
          });
          
          // Move camera to selected location
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation, 15));
          
          // Add marker
          _setMarker(selectedLocation);
          
          // Get address details
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
          appProvider.addAddress(placemarks: placemarks);
          appProvider.addLatAndLong(pos: selectedLocation);
          appProvider.saveCusrrentLocation(selectedLocation);
        }
      }
    } catch (e) {
      log('Error getting place details: $e');
    }
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