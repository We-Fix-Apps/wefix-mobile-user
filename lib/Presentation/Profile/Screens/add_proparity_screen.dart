import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';

import '../../Components/custom_botton_widget.dart';

class AddRealStateScreen extends StatefulWidget {
  final String? title;
  final String? area;
  final String? apartmentNo;
  final String? address;
  final String? latitude;
  final String? longitude;
  final int? id;

  final bool? isFromEdit;

  const AddRealStateScreen(
      {super.key,
      this.isFromEdit,
      this.title,
      this.area,
      this.apartmentNo,
      this.address,
      this.latitude,
      this.longitude,
      this.id});

  @override
  State<AddRealStateScreen> createState() => _AddRealStateScreenState();
}

class _AddRealStateScreenState extends State<AddRealStateScreen> {
  bool loading = false;
  TextEditingController title = TextEditingController();
  TextEditingController apartmentNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController lat = TextEditingController();
  TextEditingController long = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController zipcode = TextEditingController();
  TextEditingController houseNumber = TextEditingController();
  TextEditingController addressType = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController distanceFromCenter = TextEditingController();

  String? latitude;
  String? longitude;
  String? phoneNumber;

  RegExp regExp2 = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  int? id;
  var key = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      if (widget.isFromEdit ?? false) {
        address.text = widget.address ?? "";
        title.text = widget.title ?? "";
        apartmentNo.text = widget.apartmentNo ?? "";
        latitude = widget.latitude ?? "";
        longitude = widget.longitude ?? "";
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFromEdit == true
            ? AppText(context).edit
            : AppText(context).addProperty),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              WidgetTextField(
                AppText(context).title,
                validator: (p0) {
                  if (title.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                controller: title,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                radius: 5,
              ),
              WidgetTextField(
                AppText(context).appartmentno,
                keyboardType: TextInputType.number,
                validator: (p0) {
                  if (apartmentNo.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                controller: apartmentNo,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                radius: 5,
              ),

              WidgetTextField(
                AppText(context).distanceFromCenter,
                keyboardType: TextInputType.number,
                validator: (p0) {
                  if (distanceFromCenter.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                controller: distanceFromCenter,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                radius: 5,
              ),
              // WidgetTextField(
              //   AppText(context).email,
              //   keyboardType: TextInputType.emailAddress,
              //   validator: (p0) {
              //     if (email.text.isEmpty) {
              //       return AppText(context, isFunction: true).required;
              //     } else if (!regExp2.hasMatch(email.text)) {
              //       return AppText(context, isFunction: true).invalidEmail;
              //     }
              //     return null;
              //   },
              //   controller: email,
              //   fillColor: AppColors.greyColorback,
              //   haveBorder: false,
              //   radius: 5,
              // ),
              // WidgetPhoneField(
              //   onCountryChanged: (p0) {
              //     setState(() {
              //       phoneNumber = p0.phoneNumber;
              //     });
              //   },
              //   phoneController: phone,
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              WidgewtGoogleMaps(
                placemarks: placemarks,
                lat: double.tryParse(latitude ?? ""),
                loang: double.tryParse(longitude ?? ""),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          right: AppSize(context).width * 0.04,
          left: AppSize(context).width * 0.04,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          top: AppSize(context).height * 0.02,
        ),
        child: CustomBotton(
          title: widget.isFromEdit ?? false
              ? AppText(context).editAddress
              : AppText(context).addAddress,
          loading: loading,
          onTap: () {
            AppProvider appProvider = Provider.of(context, listen: false);

            if (key.currentState!.validate()) {
              if (appProvider.places?.isNotEmpty ?? false) {
                if (widget.isFromEdit ?? false) {
                  editRealState().then((value) {
                    appProvider.places?.clear();
                    Navigator.pop(context, true);
                  });
                } else {
                  addRealState().then((value) {
                    appProvider.places?.clear();

                    Navigator.pop(context, true);
                  });
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return WidgetDialog(
                        title: AppText(context).warning,
                        desc: AppText(context).youneedtoplacethemarkeronthemap,
                        isError: true);
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future addRealState() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.createRealeState(
      token: '${appProvider.userModel?.token}',
      address:
          "${appProvider.places![0].country} ,${appProvider.places![0].locality}, ${appProvider.places![0].name}, ${appProvider.places![0].subAdministrativeArea} ,${appProvider.places![0].subLocality}",
      apartmentNo: apartmentNo.text,
      area: distanceFromCenter.text,
      title: title.text,
      latitude: appProvider.position?.latitude.toString(),
      longitude: appProvider.position?.longitude.toString(),
    ).then((value) {
      if (value == false) {
        setState(() {
          loading = false;
        });
      } else {
        setState(() {});
        loading = false;
      }
    });
  }

  Future editRealState() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await ProfileApis.editRealState(
      id: widget.id ?? 0,
      token: '${appProvider.userModel?.token}',
      address:
          "${appProvider.places![0].country} ,${appProvider.places![0].locality}, ${appProvider.places![0].name}, ${appProvider.places![0].subAdministrativeArea} ,${appProvider.places![0].subLocality}",
      apartmentNo: apartmentNo.text,
      area: distanceFromCenter.text,
      title: title.text,
      latitude: appProvider.position?.latitude.toString(),
      longitude: appProvider.position?.longitude.toString(),
    ).then((value) {
      if (value == false) {
        setState(() {
          loading = false;
        });
      } else {
        setState(() {});
        loading = false;
      }
    });
  }
}
