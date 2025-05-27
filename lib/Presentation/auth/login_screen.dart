import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Business/Facebook/facebook_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';
import 'package:wefix/Presentation/Auth/sign_up_screen.dart';
import 'package:wefix/Presentation/auth/Screens/forget_password_screen.dart';
import 'package:wefix/Presentation/auth/Screens/otp_screen.dart';
import 'package:wefix/layout_screen.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';

List<String> scopes = const <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final key = GlobalKey<FormState>();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isVisiable = false;
  bool loading = false;
  bool facebookStatus = false;

  final GoogleAuthProvider googleProvider = GoogleAuthProvider();


  final LocalAuthentication authFingerPrint = LocalAuthentication();
  bool isLoadingFace = false;
  bool issupport = false;
  bool isFaceIdEnabled = false;
  bool isgood = false;
  bool isauth = false;
  final String? user = CacheHelper.getData(key: CacheHelper.userData);
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String authrized = "not Auth";

  LoginModel? loginModel;

  @override
  void initState() {
    isBiometricAuthAvailable();
    checkBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [LanguageButton()],
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(
          children: [
            SvgPicture.asset("assets/icon/background.svg"),
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 50),
              child: SafeArea(
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: SvgPicture.asset("assets/icon/logowe.svg")),

                      SizedBox(
                        height: AppSize(context).height * .1,
                      ),
                      Text(
                        "${AppText(context).loginnow} ",
                        style: TextStyle(
                          fontSize: AppSize(context).mediumText1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSize(context).height * 0.02),
                      // * Phone Number
                      WidgetPhoneField(
                        validator: (p0) {
                          if (phone.text.isEmpty) {
                            return "Requierd";
                          } else {
                            return null;
                          }
                        },
                        message:
                            phone.text.isEmpty ? "required" : "invalidPhone",
                        onCountryChanged: (value) {
                          phone.text = value.phoneNumber.toString();
                        },
                      ),
                      SizedBox(height: AppSize(context).height * 0.01),
                      // * Password

                      SizedBox(height: AppSize(context).height * .01),
                      // * Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  rightToLeft(const ForgetPasswordScreen()));
                            },
                            child: Text.rich(
                              TextSpan(
                                text: AppText(context).forgetPassword,
                                children: [
                                  TextSpan(
                                      text: " ${AppText(context).reset}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize(context).height * .04),
                      // * Login
                      Row(
                        children: [
                          Expanded(
                            child: CustomBotton(
                              title: AppText(context).login,
                              radius: 10,
                              loading: loading,
                              height: AppSize(context).height * .06,
                              onTap: () async {
                                if (key.currentState!.validate()) {
                                  login();
                                }
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => VerifyCodeScreen(),
                                //   ),
                                // );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          issupport
                              ? isFaceIdEnabled
                                  ? appProvider.userModel == null
                                      ? SizedBox()
                                      : InkWell(
                                          onTap: () => authenticate(),
                                          child: Container(
                                            width: AppSize(context).width * .12,
                                            height:
                                                AppSize(context).height * .06,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color:
                                                      AppColors.greyColorback,
                                                )),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                  "assets/icon/finger.svg"),
                                            ),
                                          ),
                                        )
                                  : const SizedBox()
                              : const SizedBox(),
                        ],
                      ),

                      const Divider(
                        color: AppColors.greyColorback,
                      ),

                      Center(
                          child: TextButton(
                              onPressed: () {
                                navigateToAndRemoveUntil(
                                    context, const HomeLayout());
                              },
                              child: Text(
                                AppText(context).loginAsG,
                                style: TextStyle(
                                  color: AppColors(context).primaryColor,
                                ),
                              ))),
                      SizedBox(height: AppSize(context).height * .02),

                      // * Create Acounts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context, rightToLeft(const SignUpScreen()));
                            },
                            child: Text.rich(TextSpan(
                                text: "${AppText(context).dontHavAccount} ? ",
                                children: [
                                  TextSpan(
                                      text: " ${AppText(context).createOne}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))
                                ])),
                          )
                        ],
                      ),
                      SizedBox(height: AppSize(context).height * .04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> isBiometricAuthAvailable() async {
    final localAuth = LocalAuthentication();
    bool isAvailable = await localAuth.canCheckBiometrics;
    setState(() {
      issupport = isAvailable;
    });
    log("is bio support ? $issupport");
    return issupport;
  }

  Future<void> authenticate() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      isLoadingFace = true;
    });

    bool authenticated = false;
    UserModel? user;

    try {
      authenticated = await LocalAuthentication().authenticate(
          localizedReason: "Scan yore finger to authentecate",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: false,
          ));
      final String? userData = CacheHelper.getData(key: CacheHelper.userData);
      if (userData != null &&
          userData != 'null' &&
          userData != 'USER_DATA_Clear') {
        final body = json.decode(userData);
        user = UserModel.fromJson(body);
        log(user.token ?? '');
        if (mounted) {
          // setState(() => appProvider.addUserData(user!));
          setState(() {
            isLoadingFace = false;
          });
        }
      } else {
        setState(() {
          isLoadingFace = false;
        });
      }
    } on PlatformException catch (e) {
      log(e.toString());
      setState(() {
        isLoadingFace = false;
      });
    }

    if (!mounted) return;

    setState(() {
      authrized = authenticated ? "succsess" : "failed";

      log(authrized);

      if (authenticated) {
        Navigator.pushAndRemoveUntil(
            context, downToTop(const HomeLayout()), (route) => false);
      }
    });
    setState(() {
      isLoadingFace = false;
    });
  }

  Future<void> checkBiometrics() async {
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
      setState(() {
        isFaceIdEnabled = availableBiometrics.contains(BiometricType.weak) ||
            availableBiometrics.contains(BiometricType.face) ||
            availableBiometrics.contains(BiometricType.fingerprint);
      });
    }
  }

  Future getFacebook() async {
    try {
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await FacebookApi.getFacebookStatus(
              token: appProvider.userModel?.token ?? '')
          .then(
        (value) {
          if (value) {
            if (mounted) {
              setState(() {
                facebookStatus = value;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                // loadingCategory = false;
              });
            }
          }
        },
      );
    } catch (e) {
      log('Category Error -> $e');
      if (mounted) {
        setState(() {
          // loadingCategory = false;
        });
      }
    }
  }

  Future login() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      setState(() {
        loading = true;
      });
      await Authantication.login(user: {
        'Mobile': phone.text,
      }).then((value) {
        if (value?.status != false) {
          setState(() {
            loginModel = value;
          });
          // appProvider.addUser(user: value);
          Navigator.push(
            context,
            downToTop(VerifyCodeScreen(
              otp: loginModel?.otp.toString() ?? "",
              phone: phone.text,
            )),
          );
          setState(() {
            loading = false;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => WidgetDialog(
              title: AppText(context, isFunction: true).warning,
              desc: AppText(context, isFunction: true).theUsername,
              isError: true,
            ),
          );
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      log('Login Is Error');
      setState(() {
        loading = false;
      });
    }
  }
}
