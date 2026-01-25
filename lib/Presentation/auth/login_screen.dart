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

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Functions/permissions_helper.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Data/services/device_info_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';
import 'package:wefix/Presentation/auth/Screens/forget_password_screen.dart';
import 'package:wefix/Presentation/auth/Screens/otp_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
  bool hasValidCachedUserData = false;
  bool isCachedUserB2B = false;
  bool isgood = false;
  bool isauth = false;
  final String? user = CacheHelper.getData(key: CacheHelper.userData);
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String authrized = "not Auth";
  String? lastLoginType; // Store last login type: 'Business Services' or 'My Services'

  LoginModel? loginModel;
  
  // Store the PhoneNumber object to get the full international format when needed
  PhoneNumber? currentPhoneNumber;
  
  bool _hasInitialized = false; // Track if initial setup is done to prevent resetting user selection

  @override
  void initState() {
    super.initState();
    _checkCachedUserData();
    isBiometricAuthAvailable();
    // Don't request notification permission here - it's already requested in main()
    // iOS only shows the native dialog ONCE per app installation
    // If user denied it on launch, they must go to Settings to enable it
    checkBiometrics();
    
    // Add listener to remove leading zero for Jordanian numbers
    phone.addListener(() {
      if (currentPhoneNumber?.isoCode == 'JO' && phone.text.isNotEmpty && phone.text.startsWith('0')) {
        // Remove leading zero
        String textWithoutZero = phone.text.substring(1);
        phone.value = TextEditingValue(
          text: textWithoutZero,
          selection: TextSelection.collapsed(offset: textWithoutZero.length),
        );
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check cached user data when screen becomes visible (e.g., after logout)
    // This ensures fingerprint button appears if user data exists
    // Only reset isCompanyPersonnel on first initialization, not on subsequent calls
    _checkCachedUserData();
  }
  
  void _checkCachedUserData() {
    final String? userData = CacheHelper.getData(key: CacheHelper.userData);
    final String? storedLoginType = CacheHelper.getData(key: CacheHelper.lastLoginType);
    
    // Check if userData is a valid JSON string (not null, not 'null', not 'CLEAR_USER_DATA')
    bool isValid = false;
    bool isB2B = false;
    if (userData != null && 
        userData != 'null' && 
        userData != CacheHelper.clearUserData &&
        userData.trim().isNotEmpty) {
      // Try to parse as JSON to ensure it's valid user data
      try {
        final decoded = json.decode(userData);
        // Valid JSON and not null
        if (decoded != null && decoded is Map) {
          isValid = true;
          // Check if cached user is B2B (roleId: 18, 20, 21, 22)
          final customer = decoded['customer'];
          if (customer != null && customer is Map) {
            final roleId = customer['roleId'];
            int? roleIdInt;
            if (roleId is int) {
              roleIdInt = roleId;
            } else if (roleId is String) {
              roleIdInt = int.tryParse(roleId);
            } else if (roleId != null) {
              roleIdInt = int.tryParse(roleId.toString());
            }
            isB2B = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22);
          }
        }
      } catch (_) {
        // Invalid JSON, not valid user data
      }
    }
    setState(() {
      hasValidCachedUserData = isValid;
      isCachedUserB2B = isB2B;
      lastLoginType = storedLoginType;
      // Only reset to My Services (isCompanyPersonnel = false) on first initialization
      // Preserve user's selection on subsequent calls (e.g., when focusing on input field)
      if (!_hasInitialized) {
        isCompanyPersonnel = false;
        _hasInitialized = true;
      }
      // Don't change isCompanyPersonnel if user has already made a selection
    });
  }
  
  @override
  void dispose() {
    phone.dispose();
    password.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      
                      // * Login Type Toggle - ALWAYS VISIBLE: Both buttons must always be shown
                      // These buttons allow users to switch between "My Services" and "Business Services"
                      // They are never conditionally hidden and should always be visible
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                log('My Services button tapped');
                                setState(() {
                                  isCompanyPersonnel = false;
                                });
                                log('isCompanyPersonnel set to: $isCompanyPersonnel');
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
                                log('Business Services button tapped');
                                setState(() {
                                  isCompanyPersonnel = true;
                                });
                                log('isCompanyPersonnel set to: $isCompanyPersonnel');
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
                          phoneController: phone,
                          message:
                              phone.text.isEmpty ? "required" : "invalidPhone",
                          onSubmit: () {
                            log('Enter pressed in phone field - My Services (B2C)');
                            // Explicitly prevent any state change when Enter is pressed
                            FocusScope.of(context).unfocus(); // Just dismiss keyboard
                          },
                          onCountryChanged: (value) {
                            // Store the PhoneNumber object to get full international format when needed
                            setState(() {
                              currentPhoneNumber = value;
                            });
                            
                            // Remove leading zero for Jordanian numbers (JO)
                            if (value.isoCode == 'JO' && phone.text.isNotEmpty && phone.text.startsWith('0')) {
                              // Remove leading zero
                              String textWithoutZero = phone.text.substring(1);
                              phone.value = TextEditingValue(
                                text: textWithoutZero,
                                selection: TextSelection.collapsed(offset: textWithoutZero.length),
                              );
                            }
                          },
                        ),
                      ] else ...[
                        // * Phone Number Field (Business Services - now uses OTP)
                        // Same phone field as My Services, but for Business Services login
                        WidgetPhoneField(
                          phoneController: phone,
                          message:
                              phone.text.isEmpty ? "required" : "invalidPhone",
                          onSubmit: () {
                            log('Enter pressed in phone field - Business Services (B2B)');
                            // Explicitly prevent any state change when Enter is pressed
                            FocusScope.of(context).unfocus(); // Just dismiss keyboard
                          },
                          onCountryChanged: (value) {
                            // Store the PhoneNumber object to get full international format when needed
                            setState(() {
                              currentPhoneNumber = value;
                            });
                            
                            // Remove leading zero for Jordanian numbers (JO)
                            if (value.isoCode == 'JO' && phone.text.isNotEmpty && phone.text.startsWith('0')) {
                              // Remove leading zero
                              String textWithoutZero = phone.text.substring(1);
                              phone.value = TextEditingValue(
                                text: textWithoutZero,
                                selection: TextSelection.collapsed(offset: textWithoutZero.length),
                              );
                            }
                          },
                        ),
                      ],
                      SizedBox(height: AppSize(context).height * .01),
                      // * Forget Password (only show for My Services, not Business Services)
                      if (!isCompanyPersonnel)
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
                                log('===== LOGIN BUTTON TAPPED =====');
                                log('isCompanyPersonnel: $isCompanyPersonnel');
                                if (isCompanyPersonnel) {
                                  log('Branch: Business Services (B2B)');
                                  // Business Services: Validate phone and use OTP flow
                                  if (phone.text.trim().isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WidgetDialog(
                                        title: AppText(context, isFunction: true).warning,
                                        desc: AppLocalizations.of(context)!.invalidPhone,
                                        isError: true,
                                      ),
                                    );
                                    return;
                                  }
                                  // Validate phone number length (digits only, excluding country code formatting)
                                  String phoneDigits = phone.text.replaceAll(RegExp(r'[^\d]'), '');
                                  if (phoneDigits.length < 9 || phoneDigits.length > 15) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WidgetDialog(
                                        title: AppText(context, isFunction: true).warning,
                                        desc: AppLocalizations.of(context)!.invalidPhone,
                                        isError: true,
                                      ),
                                    );
                                    return;
                                  }
                                  log('Calling mmsRequestOTP() for Business Services (B2B)');
                                  await mmsRequestOTP();
                                } else {
                                  log('Branch: My Services (B2C)');
                                  // My Services: Validate phone before login
                                  if (phone.text.trim().isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WidgetDialog(
                                        title: AppText(context, isFunction: true).warning,
                                        desc: AppLocalizations.of(context)!.invalidPhone,
                                        isError: true,
                                      ),
                                    );
                                    return;
                                  }
                                  // Validate phone number length (digits only, excluding country code formatting)
                                  String phoneDigits = phone.text.replaceAll(RegExp(r'[^\d]'), '');
                                  if (phoneDigits.length < 9 || phoneDigits.length > 15) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => WidgetDialog(
                                        title: AppText(context, isFunction: true).warning,
                                        desc: AppLocalizations.of(context)!.invalidPhone,
                                        isError: true,
                                      ),
                                    );
                                    return;
                                  }
                                  // My Services: Use existing phone OTP flow
                                  log('Calling login() for My Services (B2C)');
                                  login();
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Builder(
                            builder: (context) {
                              // Show fingerprint button if:
                              // 1. Biometric is supported and enabled
                              // 2. Valid cached user data exists
                              // 3. Last login type matches currently selected login type
                              final bool shouldShowFingerprint = issupport &&
                                  isFaceIdEnabled &&
                                  hasValidCachedUserData &&
                                  ((lastLoginType == 'Business Services' && isCompanyPersonnel) ||
                                   (lastLoginType == 'My Services' && !isCompanyPersonnel) ||
                                   lastLoginType == null); // Show if no previous login type
                              
                              return shouldShowFingerprint
                                  ? InkWell(
                                      onTap: () => authenticate(),
                                      child: Container(
                                        width: AppSize(context).width * .12,
                                        height: AppSize(context).height * .06,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppColors.greyColorback,
                                            )),
                                        child: Center(
                                          child: SvgPicture.asset(
                                              "assets/icon/finger.svg"),
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ],
                      ),

                      // Only show Guest login and Create Account for regular users (My Services)
                      if (!isCompanyPersonnel) ...[
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
                      ],
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
          userData != CacheHelper.clearUserData) {
        try {
          final body = json.decode(userData);
          user = UserModel.fromJson(body);
          
          if (mounted) {
            // Restore user in AppProvider
            final appProvider = Provider.of<AppProvider>(context, listen: false);
            appProvider.addUser(user: user);
            // Load tokens from cache (access token, refresh token, etc.)
            appProvider.loadTokensFromCache();
          }
        } catch (e) {
          user = null;
        }
        
        setState(() {
          isLoadingFace = false;
        });
      } else {
        setState(() {
          isLoadingFace = false;
        });
      }
    } on PlatformException {
      setState(() {
        isLoadingFace = false;
      });
    }

    if (!mounted) return;

    setState(() {
      authrized = authenticated ? "succsess" : "failed";

      if (authenticated && user != null) {
        Navigator.pushAndRemoveUntil(
            context, downToTop(const HomeLayout()), (route) => false);
      } else if (authenticated && user == null) {
        setState(() {
          isLoadingFace = false;
        });
      }
    });
    
    if (!authenticated || user == null) {
      setState(() {
        isLoadingFace = false;
      });
    }
  }

  Future<void> checkBiometrics() async {
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();
      final bool faceIdEnabled = availableBiometrics.contains(BiometricType.weak) ||
          availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.fingerprint);
      setState(() {
        isFaceIdEnabled = faceIdEnabled;
      });
      log("checkBiometrics: canCheckBiometrics=$canCheckBiometrics, isFaceIdEnabled=$isFaceIdEnabled, availableBiometrics=$availableBiometrics");
    } else {
      log("checkBiometrics: canCheckBiometrics=false");
    }
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    // Use PermissionsHelper for consistent permission handling
    await PermissionsHelper.requestNotificationPermission(context);
  }

  Future login() async {
    log('login() called - isCompanyPersonnel: $isCompanyPersonnel');
    if (isCompanyPersonnel) {
      // Business Services: Use phone number OTP flow
      log('login() -> Calling mmsRequestOTP() for Business Services (B2B)');
      await mmsRequestOTP();
    } else {
      // My Services: Regular phone-based login
      log('login() -> Calling regularLogin() for My Services (B2C)');
      await regularLogin();
    }
  }

  Future regularLogin() async {
    try {
      setState(() {
        loading = true;
      });
      // Get the full international phone number from stored PhoneNumber object
      String phoneNumberToSend = currentPhoneNumber?.phoneNumber ?? phone.text;
      // If phoneNumber doesn't start with +, use the stored PhoneNumber's international format
      if (!phoneNumberToSend.startsWith('+') && currentPhoneNumber != null) {
        phoneNumberToSend = currentPhoneNumber!.phoneNumber ?? phone.text;
      }
      
      await Authantication.login(user: {
        'Mobile': phoneNumberToSend,
      }).then((value) {
        if (value?.status != false) {
          setState(() {
            loginModel = value;
          });
          // appProvider.addUser(user: value);
          // Get the full international phone number from stored PhoneNumber object
          String phoneNumberForOTP = currentPhoneNumber?.phoneNumber ?? phone.text;
          if (!phoneNumberForOTP.startsWith('+') && currentPhoneNumber != null) {
            phoneNumberForOTP = currentPhoneNumber!.phoneNumber ?? phone.text;
          }
          
          Navigator.push(
            context,
            downToTop(VerifyCodeScreen(
              otp: loginModel?.otp.toString() ?? "",
              phone: phoneNumberForOTP,
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

  // Request OTP for Business Services login
  Future mmsRequestOTP() async {
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

      // Get device ID with full metadata (model, brand, manufacturer, etc.)
      final deviceMetadata = await DeviceInfoService.getDeviceMetadata();
      final deviceId = jsonEncode(deviceMetadata); // Send as JSON string with all metadata

      // Get the full international phone number from stored PhoneNumber object
      String phoneNumber = currentPhoneNumber?.phoneNumber ?? phone.text.trim();
      // Ensure it starts with + (the PhoneNumber object should provide this)
      if (!phoneNumber.startsWith('+')) {
        // If phone doesn't start with +, try to construct it from PhoneNumber object
        if (currentPhoneNumber != null) {
          phoneNumber = currentPhoneNumber!.phoneNumber ?? phone.text.trim();
        } else {
          // Fallback: add + if missing
          phoneNumber = phoneNumber.startsWith('00') 
              ? '+' + phoneNumber.substring(2)
              : (phoneNumber.startsWith('962') ? '+$phoneNumber' : phoneNumber);
        }
      }

      final otpResult = await Authantication.mmsRequestOTP(
        mobile: phoneNumber,
        deviceId: deviceId,
        fcmToken: fcmToken ?? 'device-token-placeholder',
      );

      setState(() {
        loading = false;
      });

      if (!otpResult['success']) {
        if (mounted) {
          // Get localized error message from backend response or use default
          final lang = Localizations.localeOf(context).languageCode;
          String errorMessage = (lang == 'ar' && otpResult['messageAr'] != null)
              ? otpResult['messageAr']
              : (otpResult['message'] ?? 'Failed to send OTP');
          
          // Check if this is an account does not exist error
          final errorLower = errorMessage.toLowerCase();
          if (errorLower.contains('does not exist') || 
              errorLower.contains('account does not exist') ||
              errorLower.contains('not exist with this phone') ||
              errorLower.contains('الحساب غير موجود')) {
            final localized = AppText(context, isFunction: true).accountDoesNotExist;
            if (localized.isNotEmpty) {
              errorMessage = localized;
            } else {
              // Fallback if translation not found in API
              errorMessage = lang == 'ar' ? 'الحساب غير موجود بهذا الرقم' : 'Account does not exist with this phone number';
            }
          }
          // Check if this is an account inactive error
          else if (errorLower.contains('inactive') || 
                   errorLower.contains('account is inactive') ||
                   errorLower.contains('حسابك غير نشط') ||
                   errorLower.contains('غير نشط')) {
            final localized = AppText(context, isFunction: true).accountInactive;
            if (localized.isNotEmpty) {
              errorMessage = localized;
            } else {
              // Fallback if translation not found in API
              errorMessage = lang == 'ar' ? 'حسابك غير نشط. يرجى التواصل مع المسؤول لتفعيل حسابك.' : 'Your account is inactive. Please contact your administrator to activate your account.';
            }
          }
          // Check if this is a rate limit error (wait/seconds/rate)
          else if (errorMessage.toLowerCase().contains('wait') || 
              errorMessage.toLowerCase().contains('rate') ||
              errorMessage.toLowerCase().contains('60 seconds') ||
              errorMessage.toLowerCase().contains('seconds before')) {
            // Extract seconds from message if available
            final secondsMatch = RegExp(r'(\d+)\s*seconds?').firstMatch(errorMessage);
            final seconds = secondsMatch?.group(1) ?? '60';
            
            // Use localized message with seconds
            if (lang == 'ar') {
              errorMessage = 'يرجى الانتظار $seconds ثانية قبل طلب رمز جديد';
            } else {
              errorMessage = 'Please wait $seconds seconds before requesting a new OTP';
            }
          }
          
          // Check if this is a technician restriction error
          final isTechnicianError = errorMessage.toLowerCase().contains('technician') || 
                                   errorMessage.toLowerCase().contains('not allowed');
          
          showDialog(
            context: context,
            builder: (context) => WidgetDialog(
              title: AppText(context, isFunction: true).warning,
              desc: isTechnicianError 
                  ? (errorMessage.toLowerCase().contains('sub-technician')
                      ? AppLocalizations.of(context)!.subTechnicianNotAllowed
                      : AppLocalizations.of(context)!.technicianNotAllowed)
                  : errorMessage,
              isError: true,
            ),
          );
        }
        return;
      }

      // Navigate to OTP verification screen
      // Store the phone number used for OTP request so we can use the same format for verification
      if (mounted) {
        Navigator.push(
          context,
          rightToLeft(
            VerifyCodeScreen(
              phone: phoneNumber, // Use the same normalized phone number format
              otp: otpResult['otp'], // For development/testing
              isBusinessServices: true, // Flag to indicate Business Services login
            ),
          ),
        );
      }
    } catch (e) {
      log('mmsRequestOTP() [ ERROR ] -> $e');
      setState(() {
        loading = false;
      });
      if (mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        final errorMessage = lang == 'ar' 
            ? 'الخدمة غير متوفرة حاليا'
            : 'Service is currently unavailable';
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).someThingError,
            desc: errorMessage,
            isError: true,
          ),
        );
      }
    }
  }

}
