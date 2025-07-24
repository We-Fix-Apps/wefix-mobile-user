import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/Address/address_api.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';

import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';

import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class AddShippingAddress extends StatefulWidget {
  final bool? isFromEdit;

  const AddShippingAddress({super.key, this.isFromEdit});

  @override
  State<AddShippingAddress> createState() => _AddShippingAddressState();
}

class _AddShippingAddressState extends State<AddShippingAddress> {
  bool loading = false;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
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

  String? latitude;
  String? longitude;
  String? phoneNumber;
  bool? isDefault = false;

  RegExp regExp2 = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  int? id;
  var key = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  @override
  void initState() {
    // TODO: implement initState
    // latitude = widget.address?.latitude ?? "";
    // longitude = widget.address?.longitude ?? "";

    // setState(() {
    //   firstName.text = widget.address?.firstName ?? "";
    //   lastName.text = widget.address?.lastName ?? "";
    //   email.text = widget.address?.email ?? "";
    //   phone.text = widget.address?.phone?.replaceAll("+962", "") ?? "";
    //   id = widget.address?.customerAddressId;
    //   addressType.text = widget.address?.addressType ?? "";
    //   houseNumber.text = widget.address?.houseNumber ?? "";
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider =
        // ignore: use_build_context_synchronously
        Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: [
          LanguageButton(),
        ],
        title: Text("${AppText(context).addnewaddress}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  WidgewtGoogleMaps(
                    isHaveRadius: false,
                    placemarks: placemarks,
                    height: AppSize(context).height * .65,
                    lat: double.tryParse(latitude ?? ""),
                    loang: double.tryParse(longitude ?? ""),
                  ),
                  SvgPicture.asset(
                    "assets/icon/pin.svg",
                    height: 40,
                    width: 40,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WidgetTextField(
                  "",
                  controller: appProvider.ad,
                  readOnly: true,
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: WidgetTextField(
              //     "Detaisl",
              //     controller: address,
              //     maxLines: 3,
              //   ),
              // ),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     AddressTypeWidget(icon: Icons.home, label: 'Home'),
              //     AddressTypeWidget(icon: Icons.work, label: 'Work'),
              //     AddressTypeWidget(icon: Icons.star, label: 'Saved'),
              //   ],
              // ),
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
                  editAddress().then((value) {
                    appProvider.places?.clear();
                    pop(context);
                  });
                } else {
                  addAddress().then((value) {
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

  Future addAddress() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    Map data = {
      "IsDefault": isDefault ?? false,
      "Address": "${appProvider.ad.text}",
      "Latitude": "${appProvider.position?.latitude}",
      "Longitude": "${appProvider.position?.longitude}",
      "AddressType": addressType.text
    };

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await AddressApi.addAdress(
      token: '${appProvider.userModel?.token}',
      data: data,
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

  Future editAddress() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    Map data = {
      "customerAddressId": id,
      "FirstName": firstName.text,
      "LastName": lastName.text,
      "Email": email.text,
      "Address": appProvider.places![0].subLocality,
      "Latitude": appProvider.position?.latitude,
      "Longitude": appProvider.position?.longitude,
      "Street": appProvider.places![0].street,
      "City": appProvider.places![0].locality,
      "Zipcode": "",
      "Country": appProvider.places![0].country,
      "State": appProvider.places![0].subLocality,
      "HouseNumber": houseNumber.text,
      "AddressType": addressType.text,
    };

    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    await AddressApi.editAdress(
      token: '${appProvider.userModel?.token}',
      data: data,
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
