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
  List<Placemark>? placemarks;
  final double? lat;
  final double? loang;
  final double? height;
  final bool? isHaveRadius;

  final bool? isFromCheckOut;

  WidgewtGoogleMaps(
      {super.key,
      this.placemarks,
      this.lat,
      this.loang,
      this.isFromCheckOut,
      this.height,
      this.isHaveRadius});

  @override
  State<WidgewtGoogleMaps> createState() => _WidgewtGoogleMapsState();
}

double? lat;
double? loang;

class _WidgewtGoogleMapsState extends State<WidgewtGoogleMaps> {
  Set<Marker> markers = {};

  BitmapDescriptor? customIcon;

  @override
  void initState() {
    if (mounted) {
      setState(() {
        lat = widget.lat;
        loang = widget.loang;
      });
    }

    super.initState();

    _determinePosition().then((value) {
      // _createMarkerImageFromAsset();
      _getMyLocation().then((value) {});

      log(customIcon.toString());
      // _setMarker(LatLng(lat!, loang!));
    });
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider =
        // ignore: use_build_context_synchronously
        Provider.of<AppProvider>(context, listen: false);
    return Container(
      decoration: widget.isFromCheckOut == true
          ? null
          : BoxDecoration(
              border: Border.all(
                color: widget.isHaveRadius == true
                    ? AppColors.greyColor1
                    : AppColors.whiteColor1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
      height: widget.height ?? 200,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: widget.isHaveRadius == true
                ? BorderRadius.circular(10)
                : BorderRadius.circular(0),
            child: GoogleMap(
                mapToolbarEnabled: widget.isFromCheckOut == true ? false : true,
                scrollGesturesEnabled:
                    widget.isFromCheckOut == true ? false : true,
                myLocationEnabled: widget.isFromCheckOut == true ? false : true,
                indoorViewEnabled: widget.isFromCheckOut == true ? false : true,
                zoomGesturesEnabled:
                    widget.isFromCheckOut == true ? false : true,
                zoomControlsEnabled:
                    widget.isFromCheckOut == true ? false : true,
                buildingsEnabled: widget.isFromCheckOut == false ? false : true,
                compassEnabled: widget.isFromCheckOut == false ? false : true,
                onCameraMove: widget.isFromCheckOut == true
                    ? (p) async {}
                    : (position) async {
                        setState(() {
                          appProvider.saveCusrrentLocation(position.target);
                          currentLocation = position.target;
                          appProvider.addLatAndLong(pos: position.target);
                        });
                        log(currentLocation.toString());
                        List<Placemark> placemarks3 =
                            await placemarkFromCoordinates(
                                currentLocation.latitude,
                                currentLocation.longitude);

                        appProvider.addAddress(placemarks: placemarks3);

                        log(placemarks3.toString());
                      },
                markers: markers,
                onTap: widget.isFromCheckOut == true
                    ? (p) {}
                    : (pos) async {
                        List<Placemark> placemarks2 =
                            await placemarkFromCoordinates(
                                currentLocation.latitude,
                                currentLocation.longitude);
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

                        log(appProvider.position!.latitude.toString());
                      },
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                      currentLocation.latitude, currentLocation.longitude);
                  setState(() {
                    appProvider
                        .addAddress(placemarks: placemarks)
                        .then((value) {
                      setState(() {});
                    });
                  });
                },
                initialCameraPosition: initialCameraPosition),
          ),
          widget.isFromCheckOut == true
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors(context).primaryColor,
                    child: IconButton(
                      onPressed: () {
                        searchPlaces();
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  final Completer<GoogleMapController> _controller = Completer();
  static CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(lat ?? 31.915079, loang ?? 35.883758),
    zoom: 14.4746,
  );
  LatLng currentLocation = initialCameraPosition.target;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getMyLocation() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    Position myLocation = await Geolocator.getCurrentPosition();

    if (lat != null && loang != null) {
      appProvider.saveCusrrentLocation(LatLng(lat!, loang!));
      _animateCamera(LatLng(lat!, loang!));
    } else {
      _animateCamera(LatLng(myLocation.latitude, myLocation.longitude));
    }
  }

  Future<void> _animateCamera(LatLng location) async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    final GoogleMapController controller = await _controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 15.00,
    );
    log("animating camera to (lat: ${location.latitude}, long: ${location.longitude}");
    appProvider
        .saveCusrrentLocation(LatLng(location.latitude, location.longitude));
    List<Placemark> placemarksCurrent =
        await placemarkFromCoordinates(location.latitude, location.longitude);

    appProvider.addAddress(placemarks: placemarksCurrent);
    controller
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition))
        .then((value) {
      _setMarker(location);
    });
  }

  Future<void> _getLocationFromPlaceId(String placeId) async {
    print("############");

    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: "AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0",
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);
    print("############");
    // final GoogleMapController controller55 = await _controller.future;

    // controller55.animateCamera(CameraUpdate.newCameraPosition(
    //     LatLng(32.2746515, 35.8960765) as CameraPosition));

    _animateCamera(LatLng(detail.result.geometry!.location.lat,
        detail.result.geometry!.location.lng));
    print("############");

    print(
        "${detail.result.geometry!.location.lat} ,${detail.result.geometry!.location.lng}");
  }

  Future<void> searchPlaces() async {
    var p = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0",
      language: "ar",
      mode: Mode.overlay,
      region: "en",
      types: [""],
      // startText: "$country",
      // decoration: InputDecoration(
      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      overlayBorderRadius: BorderRadius.circular(20),
      components: [],
      strictbounds: false,
    );

    _getLocationFromPlaceId(p!.placeId!);
  }

  Future<void> _setMarker(LatLng location) async {
    Marker newMarker = Marker(
        markerId: MarkerId(
          location.toString(),
        ),
        icon: customIcon ?? BitmapDescriptor.defaultMarker,
        position: LatLng(location.latitude, location.longitude),
        infoWindow: const InfoWindow(snippet: ""));

    setState(() {
      markers.add(newMarker);
    });
  }
}
