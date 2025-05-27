import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Business/Facebook/facebook_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';
import 'package:wefix/Presentation/Auth/components/circular_login_widget.dart';
import 'package:wefix/Presentation/Profile/Screens/content_screen.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/layout_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isVisiable = false;
  bool isVisiable2 = false;
  bool isChecked = false;
  bool? isLoading;
  bool facebookStatus = false;
  String locationName = 'Loading...';

  TextEditingController firstName = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirm = TextEditingController();
  RegExp regExp2 = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  TextEditingController phone = TextEditingController();
  final GoogleAuthProvider googleProvider = GoogleAuthProvider();

  bool loading = false;

  String? phoneNumber;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _getLocationName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [LanguageButton()],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 50),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText(context).createAccount,
                  style: TextStyle(
                    fontSize: AppSize(context).largText1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: AppSize(context).height * .05,
                ),
                WidgetTextField(
                  AppText(context, isFunction: true).firstName,
                  fillColor: AppColors.greyColorback,
                  haveBorder: false,
                  controller: firstName,
                  validator: (p0) {
                    if (firstName.text.isEmpty) {
                      return AppText(context, isFunction: true).required;
                    }
                    return null;
                  },
                  radius: 5,
                ),
                const SizedBox(
                  height: 5,
                ),
                WidgetTextField(
                  AppText(context, isFunction: true).email,
                  fillColor: AppColors.greyColorback,
                  haveBorder: false,
                  radius: 5,
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 5,
                ),
                WidgetPhoneField(
                  validator: (p0) {
                    if (phone.text.isEmpty) {
                      return AppText(context, isFunction: true).required;
                    } else
                      return null;
                  },
                  onCountryChanged: (p0) {
                    setState(() {
                      phoneNumber = p0.phoneNumber;
                    });
                  },
                  phoneController: phone,
                ),
                SizedBox(
                  height: 10,
                ),
                WidgetTextField(
                  "Location",
                  fillColor: AppColors.greyColorback,
                  haveBorder: false,
                  radius: 5,
                  controller: location,
                  validator: (p0) {
                    if (location.text.isEmpty) {
                      return AppText(context, isFunction: true).required;
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                // WidgetTextField(
                //   AppText(context, isFunction: true).password,
                //   fillColor: AppColors.greyColorback,
                //   haveBorder: false,
                //   controller: password,
                //   validator: (p0) {
                //     if (password.text.isEmpty) {
                //       return AppText(context, isFunction: true).required;
                //     } else if (p0.toString().length < 8) {
                //       return AppText(context, isFunction: true)
                //           .mustbecontainatleast8characters;
                //     }
                //     return null;
                //   },
                //   obscureText: !isVisiable,
                //   radius: 5,
                //   suffixIcon: isVisiable
                //       ? InkWell(
                //           onTap: () {
                //             setState(() {
                //               isVisiable = !isVisiable;
                //             });
                //           },
                //           child: const Icon(
                //             Icons.visibility_off,
                //             color: AppColors.greyColor3,
                //           ))
                //       : InkWell(
                //           onTap: () {
                //             setState(() {
                //               isVisiable = !isVisiable;
                //             });
                //           },
                //           child: const Icon(
                //             Icons.visibility,
                //             color: AppColors.greyColor3,
                //           )),
                // ),
                // const SizedBox(
                //   height: 5,
                // ),
                // WidgetTextField(
                //   AppText(context, isFunction: true).confirmPassword,
                //   fillColor: AppColors.greyColorback,
                //   haveBorder: false,
                //   controller: passwordConfirm,
                //   validator: (p0) {
                //     if (passwordConfirm.text.isEmpty) {
                //       return AppText(context, isFunction: true).required;
                //     } else if (password.text.isNotEmpty &&
                //         password.text != passwordConfirm.text) {
                //       return AppText(context, isFunction: true)
                //           .passworddoesnotmatch;
                //     } else if (p0.toString().length < 8) {
                //       return AppText(context, isFunction: true)
                //           .mustbecontainatleast8characters;
                //     }

                //     return null;
                //   },
                //   obscureText: !isVisiable2,
                //   radius: 5,
                //   suffixIcon: isVisiable2
                //       ? InkWell(
                //           onTap: () {
                //             setState(() {
                //               isVisiable2 = !isVisiable2;
                //             });
                //           },
                //           child: const Icon(
                //             Icons.visibility_off,
                //             color: AppColors.greyColor3,
                //           ))
                //       : InkWell(
                //           onTap: () {
                //             setState(() {
                //               isVisiable2 = !isVisiable2;
                //             });
                //           },
                //           child: const Icon(
                //             Icons.visibility,
                //             color: AppColors.greyColor3,
                //           )),
                // ),
                // SizedBox(height: AppSize(context).height * .01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors(context).primaryColor,
                      // fillColor: MaterialStatePropertyAll(AppColors(context).primaryColor),
                      onChanged: (value) {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                    ),

                    Text(
                      "${AppText(context).iAgreetothe} ",
                      style: TextStyle(fontSize: AppSize(context).smallText4),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            rightToLeft(const ContentScreen(
                              isTerms: true,
                            )));
                      },
                      child: Text("${AppText(context).termsAndConditions} ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize(context).smallText4,
                              color: AppColors(context).primaryColor)),
                    ),
                    Text(
                      "${AppText(context).and} ",
                      style: TextStyle(fontSize: AppSize(context).smallText4),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            rightToLeft(const ContentScreen(
                              isPrivacy: true,
                            )));
                      },
                      child: Text(" ${AppText(context).privacyPolicy}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize(context).smallText4,
                              color: AppColors(context).primaryColor)),
                    )
                    // Text.rich(
                    //   TextSpan(
                    //       text: "${AppText(context).iAgreetothe} ",
                    //       children: [
                    //         TextSpan(
                    //             text: "${AppText(context).termsAndConditions} ",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: AppColors(context).primaryColor)),
                    //         TextSpan(text: "${AppText(context).and} "),
                    //         TextSpan(
                    //             text: " ${AppText(context).privacyPolicy}",
                    //             style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: AppColors(context).primaryColor))
                    //       ]),
                    //   style: TextStyle(fontSize: AppSize(context).smallText4),
                    // )
                  ],
                ),
                SizedBox(height: AppSize(context).height * .04),
                CustomBotton(
                  title: AppText(context, isFunction: true).signIn,
                  radius: 30,
                  loading: isLoading,
                  height: AppSize(context).height * .07,
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      if (isChecked) {
                        signUp().then((value) {});
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => WidgetDialog(
                            title: AppText(context, isFunction: true).warning,
                            desc: AppText(context, isFunction: true)
                                .youhavetoaccepttermsandconditions,
                            isError: true,
                          ),
                        );
                      }
                    }
                  },
                ),
                SizedBox(height: AppSize(context).height * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        pop(context);
                      },
                      child: Text.rich(
                          TextSpan(text: AppText(context).already, children: [
                        TextSpan(
                            text: "  ${AppText(context).signIn}",
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ])),
                    )
                  ],
                ),
                SizedBox(height: AppSize(context).height * .04),
                facebookStatus == false
                    ? const SizedBox()
                    : Row(children: <Widget>[
                        const Expanded(
                            child: Divider(
                          indent: 20,
                          color: AppColors.greyColor,
                        )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(AppText(context).or),
                        ),
                        const Expanded(
                            child: Divider(
                          endIndent: 20,
                          color: AppColors.greyColor,
                        )),
                      ]),
              ],
            ),
          ),
        )),
      ),
    );
  }

  // Function to get the current location and convert it to an address
  Future<void> _getLocationName() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationName = 'Location services are disabled.';
      });
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationName = 'Location permission denied.';
        });
        return;
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Convert coordinates to address using geocoding
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    // Update the location name
    setState(() {
      location.text =
          '${place.locality}, ${place.country} , ${place.subLocality}';
    });
  }

  Future signUp() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => isLoading = true);
    await Authantication.signUp(
      phone: phoneNumber ?? "",
      name: firstName.text,
      address: location.text,
      email: email.text,
      password: password.text,
      context: context,
    ).then((value) async {
      if (value?.status ?? false) {
        setState(() => isLoading = false);

        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).successfully,
            desc: AppText(context, isFunction: true).signUpSuccessfully,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context, downToTop(const LoginScreen()), (route) => false);
            },
            isError: false,
          ),
        );

        // log("${appProvider.userModel?.userInfo?.fullName.toString()}");
      } else {
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).warning,
            desc: AppText(context, isFunction: true)
                .thephoneyouentereisalreadyinusePleasetradifferentphone,
            isError: true,
          ),
        );
        setState(() => isLoading = false);
      }
    });
  }
}
