import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/Address/address_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/address_model.dart';
import 'package:wefix/Presentation/Address/Components/address_card_widget.dart';
import 'package:wefix/Presentation/Address/Screens/add_address_screen.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';

import '../../../Business/AppProvider/app_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List isSelected = [true, false, false, false, false, false, false];
  bool loading = false;
  List<CustomerAddress>? address = [];

  @override
  void initState() {
    // TODO: implement initState
    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).address),
        centerTitle: true,
        actions: const [
          LanguageButton(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomBotton(
            title: AppText(context).addAddress,
            onTap: () async {
              if (appProvider.userModel == null) {
                showDialog(
                    context: context,
                    builder: (context) => WidgetDialog(
                          title: AppText(context, isFunction: true).warning,
                          desc: AppText(context, isFunction: true)
                              .pleaselogintocontinue,
                          isError: true,
                          bottonText: AppText(context, isFunction: true).login,
                          onTap: () => Navigator.push(
                            context,
                            downToTop(
                              const LoginScreen(),
                            ),
                          ),
                        ));
              } else {
                final a = await Navigator.push(
                    context, rightToLeft(const AddShippingAddress()));

                if (a == true) {
                  getAddress();
                }
              }
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            loading == true
                ? LinearProgressIndicator(
                    color: AppColors(context).primaryColor,
                    backgroundColor: AppColors.secoundryColor,
                  )
                : address?.isEmpty ?? true
                    ? const EmptyScreen(
                        image: "assets/icon/address_empty.svg",
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: address?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  appProvider.saveCusrrentLocation(LatLng(
                                      double.tryParse(
                                              address?[index].latitude ??
                                                  "0") ??
                                          0,
                                      double.tryParse(
                                              address?[index].longitude ??
                                                  "0") ??
                                          0));
                                });
                                Navigator.pop(context, true);
                              },
                              child: AddressCardWidget(
                                address: address?[index],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Future getAddress() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
        });
      }
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await AddressApi.getAddress(token: appProvider.userModel?.token ?? '')
          .then(
        (value) {
          if (mounted) {
            setState(() {
              address = value;
              loading = false;
            });
          }
        },
      );
    } catch (e) {
      log('Category Error -> $e');
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }
}
