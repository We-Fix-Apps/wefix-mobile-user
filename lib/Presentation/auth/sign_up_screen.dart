import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/buissness_type_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';
import 'package:wefix/Presentation/Profile/Screens/content_screen.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String? phone;

  const SignUpScreen({super.key, this.phone});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isVisiable = false;
  bool isVisiable2 = false;
  bool isChecked = false;
  bool? isLoading;
  bool? loading2;

  bool facebookStatus = false;
  String locationName = 'Loading...';

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirm = TextEditingController();
  TextEditingController phone = TextEditingController();

  // Role and Company fields
  int selectedRole = 1; // 1 for User, 2 for Company

  final List<Map<String, dynamic>> roles = [
    {"id": 1, "name": "User"},
    {"id": 2, "name": "Company"},
  ];

  TextEditingController companyName = TextEditingController();
  TextEditingController businessType = TextEditingController();
  TextEditingController area = TextEditingController();
  TextEditingController ownerName = TextEditingController();
  TextEditingController businessAddress = TextEditingController();
  TextEditingController businessEmail = TextEditingController();
  TextEditingController businessPhone = TextEditingController();
  TextEditingController website = TextEditingController();

  BusinessTypesModel? businessTypesModel;

  int? selectedBusinessTypeId;
  BusinessType? selectedBusinessType;

  RegExp regExp2 = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final GoogleAuthProvider googleProvider = GoogleAuthProvider();
  bool loading = false;
  double? latitude;
  double? longitude;
  String? phoneNumber;
  String? phoneNumberBusiness;

  var formKey = GlobalKey<FormState>();

  Future<bool> isUserFromJordanGPS() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String? countryCode = placemarks.first.isoCountryCode;
        log("Country Code: $countryCode");
        return countryCode?.toUpperCase() == 'JO';
      }
    } catch (e) {
      print("Error detecting location: $e");
    }
    return false;
  }

  @override
  void initState() {
    phone.text = widget.phone ?? "";
    _getLocationName();
    getBusinessType();
    isUserFromJordanGPS();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider langProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: const [LanguageButton()],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 50),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText(context).createAccount,
                    style: TextStyle(
                      fontSize: AppSize(context).largText1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSize(context).height * .05),

                  // Role dropdown
                  DropdownButtonFormField<int>(
                    initialValue: selectedRole,
                    hint: const Text("Select Role *"),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.greyColorback,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: roles
                        .map((role) => DropdownMenuItem<int>(
                              value: role["id"],
                              child: Text(role["name"]),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // User fields
                  selectedRole == 2
                      ? const SizedBox()
                      : WidgetTextField(
                          AppText(context, isFunction: true).firstName,
                          fillColor: AppColors.greyColorback,
                          haveBorder: false,
                          controller: firstName,
                          validator: (p0) {
                            if (firstName.text.isEmpty) {
                              return AppText(context, isFunction: true)
                                  .required;
                            }
                            return null;
                          },
                          radius: 5,
                        ),
                  selectedRole == 2
                      ? const SizedBox()
                      : const SizedBox(height: 5),
                  selectedRole == 2
                      ? const SizedBox()
                      : WidgetTextField(
                          AppText(context, isFunction: true).lastName,
                          fillColor: AppColors.greyColorback,
                          haveBorder: false,
                          controller: lastName,
                          validator: (p0) {
                            if (lastName.text.isEmpty) {
                              return AppText(context, isFunction: true)
                                  .required;
                            }
                            return null;
                          },
                          radius: 5,
                        ),
                  selectedRole == 2
                      ? const SizedBox()
                      : const SizedBox(height: 5),
                  selectedRole == 2
                      ? const SizedBox()
                      : WidgetTextField(
                          AppText(context, isFunction: true).email,
                          fillColor: AppColors.greyColorback,
                          haveBorder: false,
                          radius: 5,
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (p0) {
                            if (email.text.isEmpty) {
                            } else if (!regExp2.hasMatch(email.text)) {
                              return AppText(context, isFunction: true)
                                  .invalidEmail;
                            }
                            return null;
                          },
                        ),
                  selectedRole == 2
                      ? const SizedBox()
                      : const SizedBox(height: 5),
                  selectedRole == 2
                      ? const SizedBox()
                      : WidgetPhoneField(
                          validator: (p0) {
                            if (phone.text.isEmpty) {
                              return AppText(context, isFunction: true)
                                  .required;
                            } else {
                              return null;
                            }
                          },
                          onCountryChanged: (p0) {
                            setState(() {
                              phoneNumber = p0.phoneNumber;
                            });
                          },
                          phoneController: phone,
                        ),
                  selectedRole == 2
                      ? const SizedBox()
                      : const SizedBox(height: 10),
                  selectedRole == 2
                      ? const SizedBox()
                      : WidgetTextField(
                          "Location",
                          fillColor: AppColors.greyColorback,
                          haveBorder: false,
                          radius: 5,
                          controller: location,
                          validator: (p0) {
                            if (location.text.isEmpty) {
                              return AppText(context, isFunction: true)
                                  .required;
                            }
                            return null;
                          },
                        ),
                  const SizedBox(height: 10),

                  // Company fields (conditionally visible)
                  if (selectedRole == 2) ...[
                    const Divider(thickness: 1),
                    Text(
                      "Company Information",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize(context).mediumText1),
                    ),
                    const SizedBox(height: 8),
                    WidgetTextField(
                      "Company Name *",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: companyName,
                      validator: (p0) =>
                          companyName.text.isEmpty ? "Required" : null,
                      radius: 5,
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<BusinessType>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.greyColorback,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Business Type *",
                      ),
                      initialValue: selectedBusinessType,
                      items: (businessTypesModel?.businessTypes ?? [])
                          .map((type) => DropdownMenuItem<BusinessType>(
                                value: type,
                                child: Text(langProvider.lang == "en"
                                    ? type.titleEn
                                    : type.titleAr),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedBusinessType = value;
                            selectedBusinessTypeId =
                                value.id; // 👈 store id here
                            businessType.text = langProvider.lang == "en"
                                ? value.titleEn
                                : value.titleAr; // optional: update text field
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? "Please select business type" : null,
                    ),
                    const SizedBox(height: 5),
                    WidgetTextField(
                      "Area (m²)",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: area,
                      keyboardType: TextInputType.number,
                      radius: 5,
                    ),
                    const SizedBox(height: 5),
                    WidgetTextField(
                      "Owner / Representative *",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: ownerName,
                      validator: (p0) =>
                          ownerName.text.isEmpty ? "Required" : null,
                      radius: 5,
                    ),
                    const SizedBox(height: 5),
                    WidgetTextField(
                      "Business Address *",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: businessAddress,
                      validator: (p0) =>
                          businessAddress.text.isEmpty ? "Required" : null,
                      radius: 5,
                    ),
                    const SizedBox(height: 5),
                    WidgetTextField(
                      "Business Email",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: businessEmail,
                      keyboardType: TextInputType.emailAddress,
                      validator: (p0) {
                        if (businessEmail.text.isNotEmpty &&
                            !regExp2.hasMatch(businessEmail.text)) {
                          return "Invalid email";
                        }
                        return null;
                      },
                      radius: 5,
                    ),
                    const SizedBox(height: 5),
                    WidgetPhoneField(
                      validator: (p0) {
                        if (businessPhone.text.isEmpty) {
                          return AppText(context, isFunction: true).required;
                        } else {
                          return null;
                        }
                      },
                      onCountryChanged: (p0) {
                        setState(() {
                          phoneNumberBusiness = p0.phoneNumber;
                        });
                      },
                      phoneController: phone,
                    ),
                    const SizedBox(height: 5),
                    WidgetTextField(
                      "Website",
                      fillColor: AppColors.greyColorback,
                      haveBorder: false,
                      controller: website,
                      radius: 5,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Terms and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isChecked,
                        activeColor: AppColors(context).primaryColor,
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
                          Navigator.push(context,
                              rightToLeft(const ContentScreen(isTerms: true)));
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
                              rightToLeft(
                                  const ContentScreen(isPrivacy: true)));
                        },
                        child: Text(" ${AppText(context).privacyPolicy}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSize(context).smallText4,
                                color: AppColors(context).primaryColor)),
                      )
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
                          signUp();
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold))
                        ])),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getLocationName() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationName = 'Location services are disabled.';
      });
      return;
    }

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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    log("Current Position: ${position.latitude}, ${position.longitude}");

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      location.text =
          '${place.locality}, ${place.country}, ${place.subLocality}';
    });
  }

  Future getBusinessType() async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      Authantication.getBusinessType(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          businessTypesModel = value;
          loading2 = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading2 = false;
      });
    }
  }

  Future signUp() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => isLoading = true);
    await Authantication.signUp(
      phone: selectedRole == 2 ? phoneNumberBusiness ?? "" : phoneNumber ?? "",
      name: selectedRole == 2 ? companyName.text : firstName.text,
      lastname: lastName.text,
      address: selectedRole == 2 ? businessAddress.text : location.text,
      email: selectedRole == 2 ? businessEmail.text : email.text,
      password: password.text,
      lat: latitude ?? 0,
      long: longitude ?? 0,
      type: selectedRole,
      BusinessTypeId: selectedRole == 2 ? selectedBusinessTypeId ?? 0 : 0,
      area: selectedRole == 2 ? area.text : null,
      owner: selectedRole == 2 ? ownerName.text : null,
      website: selectedRole == 2 ? website.text : null,
      context: context,
    ).then((value) async {
      setState(() => isLoading = false);
      if (value?.status ?? false) {
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
      }
    });
  }
}
