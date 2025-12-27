import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';
import 'package:wefix/Presentation/auth/Screens/forget_password_screen.dart';
import 'package:wefix/Presentation/auth/Screens/otp_screen.dart';
import 'package:wefix/Presentation/auth/sign_up_screen.dart';
import 'package:wefix/layout_screen.dart';

import 'package:local_auth/local_auth.dart';

import '../../l10n/app_localizations.dart';

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
  TextEditingController email = TextEditingController();

  bool isVisiable = false;
  bool loading = false;
  bool isCompanyPersonnel = false; // Toggle for company personnel login
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
    requestNotificationPermission(context);
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
                      
                      // * Login Type Toggle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCompanyPersonnel = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isCompanyPersonnel
                                      ? AppColors(context).primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors(context).primaryColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.regularUser,
                                    style: TextStyle(
                                      color: !isCompanyPersonnel
                                          ? Colors.white
                                          : AppColors(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCompanyPersonnel = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isCompanyPersonnel
                                      ? AppColors(context).primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors(context).primaryColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.companyPersonnel,
                                    style: TextStyle(
                                      color: isCompanyPersonnel
                                          ? Colors.white
                                          : AppColors(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize(context).height * 0.02),
                      
                      // * Conditional Fields: Phone or Email/Password
                      if (!isCompanyPersonnel) ...[
                        // * Phone Number (Regular User)
                        WidgetPhoneField(
                        // validator: (p0) {
                        //   if (phone.text.isEmpty) {
                        //     return "Requierd";
                        //   } else {
                        //     return null;
                        //   }
                        // },
                        message:
                            phone.text.isEmpty ? "required" : "invalidPhone",
                          onCountryChanged: (value) {
                            phone.text = value.phoneNumber.toString();
                          },
                        ),
                      ] else ...[
                        // * Email Field (Company Personnel)
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            fillColor: AppColors.greyColorback,
                            filled: true,
                            hintText: AppText(context).email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors(context).primaryColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors.backgroundColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors(context).primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.emailRequired;
                            }
                            if (!value.contains('@')) {
                              return AppText(context).invalidEmail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSize(context).height * 0.01),
                        // * Password Field (Company Personnel)
                        TextFormField(
                          controller: password,
                          obscureText: !isVisiable,
                          decoration: InputDecoration(
                            fillColor: AppColors.greyColorback,
                            filled: true,
                            hintText: AppText(context).password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isVisiable
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isVisiable = !isVisiable;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors(context).primaryColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors.backgroundColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide(
                                color: AppColors(context).primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.passwordRequired;
                            }
                            return null;
                          },
                        ),
                      ],
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
        log(user.token);
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

  Future<void> requestNotificationPermission(BuildContext context) async {
    // Check the current permission status
    var status = await Permission.notification.status;

    if (status.isDenied) {
      // Ask user for permission
      var result = await Permission.notification.request();

      if (result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications enabled!')),
        );
      } else if (result.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications denied.')),
        );
      } else if (result.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Notifications permanently denied. Please enable in settings.')),
        );
      }
    } else if (status.isGranted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Notifications already enabled.')),
      // );
    }
  }

  Future login() async {
    if (isCompanyPersonnel) {
      // MMS login for company personnel
      await mmsLogin();
    } else {
      // Regular phone-based login
      await regularLogin();
    }
  }

  Future regularLogin() async {
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
              bottonText: "${AppText(context, isFunction: true).createAccount}",
              onTap: () {
                Navigator.push(
                    context,
                    downToTop(SignUpScreen(
                      phone: phone.text.substring(4, 13),
                    )));
              },
              isError: true,
            ),
          );
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      log('Login Is Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future mmsLogin() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      setState(() {
        loading = true;
      });

      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        log('Error getting FCM token: $e');
        fcmToken = 'device-token-placeholder';
      }

      // Generate a simple device ID (you may want to use device_info_plus package)
      String deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';

      final mmsUser = await Authantication.mmsLogin(
        email: email.text.trim(),
        password: password.text,
        deviceId: deviceId,
        fcmToken: fcmToken ?? 'device-token-placeholder',
      );

      if (mmsUser != null && mmsUser.success && mmsUser.user != null) {
        // Convert MmsUserModel to UserModel format
        // Use userRoleId from MMS response (from COMPANY_ROLE lookup table)
        // This can be: 18 (Admin), 20 (Team Leader), 21 (Technician), 22 (Sub-Technician)
        final userRoleId = mmsUser.user!.userRoleId;
        
        // Prevent technicians and sub-technicians from logging in
        if (userRoleId == 21 || userRoleId == 22) {
          setState(() {
            loading = false;
          });
          if (mounted) {
            final localizations = AppLocalizations.of(context)!;
            String errorMessage;
            if (userRoleId == 21) {
              errorMessage = localizations.technicianNotAllowed;
            } else {
              errorMessage = localizations.subTechnicianNotAllowed;
            }
            showDialog(
              context: context,
              builder: (context) => WidgetDialog(
                title: AppText(context, isFunction: true).warning,
                desc: errorMessage,
                isError: true,
              ),
            );
          }
          return;
        }
        final userModel = UserModel(
          status: true,
          token: mmsUser.token?.accessToken ?? '',
          message: mmsUser.message,
          qrCodePath: null,
          wallet: 0,
          customer: Customer(
            id: mmsUser.user!.id,
            roleId: userRoleId, // Use userRoleId from MMS response (from COMPANY_ROLE lookup table)
            name: mmsUser.user!.fullName,
            mobile: mmsUser.user!.mobileNumber ?? '',
            email: mmsUser.user!.email ?? '',
            createdDate: mmsUser.user!.createdAt,
            password: null,
            oldPassword: null,
            otp: 0,
            address: '',
            providerId: 0,
          ),
        );

        // Update AppProvider with user data
        appProvider.addUser(user: userModel);
        
        // Save both access token and refresh token in AppProvider
        if (mmsUser.token != null) {
          appProvider.setTokens(
            access: mmsUser.token!.accessToken,
            refresh: mmsUser.token!.refreshToken,
            type: mmsUser.token!.tokenType,
            expires: mmsUser.token!.expiresIn,
        );
        }

        // Navigate to home - HomeScreen will automatically show B2BHome for company personnel (roleId == 18)
        Navigator.pushAndRemoveUntil(
          context,
          downToTop(const HomeLayout()),
          (route) => false,
        );

        setState(() {
          loading = false;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).someThingError,
            desc: AppLocalizations.of(context)!.invalidCredentials,
            bottonText: AppText(context, isFunction: true).ok,
            onTap: () {
              Navigator.pop(context);
            },
            isError: true,
          ),
        );
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      log('MMS Login Error: $e');
      showDialog(
        context: context,
        builder: (context) => WidgetDialog(
          title: AppText(context, isFunction: true).someThingError,
          desc: AppLocalizations.of(context)!.loginFailed,
          bottonText: AppText(context, isFunction: true).ok,
          onTap: () {
            Navigator.pop(context);
          },
          isError: true,
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }
}
