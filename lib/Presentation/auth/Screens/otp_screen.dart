import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart'; // ✅ Added
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/layout_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wefix/Data/services/device_info_service.dart';
import 'package:wefix/Data/model/mms_user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/l10n/app_localizations.dart';

import '../../../Data/Helper/cache_helper.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? verificationId;
  final String? otp;
  final String? phone;
  final List? signUp;
  final bool? isBusinessServices; // Flag to indicate Business Services login

  const VerifyCodeScreen({
    super.key,
    this.verificationId,
    this.phone,
    this.signUp,
    this.otp,
    this.isBusinessServices = false,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> with CodeAutoFill {
  final key = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  bool loading = false;
  bool loading2 = false;
  bool loadingResend = false;
  String currentText = "";
  UserModel? userModel;
  LoginModel? loginModel;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();

    /// ✅ Start listening for incoming OTP SMS
    listenForCode();
  }

  @override
  void codeUpdated() {
    setState(() {
      currentText = code ?? "";
      textEditingController.text = currentText; // auto-fill into field
    });
  }

  @override
  void dispose() {
    errorController?.close();
    cancel(); // ✅ stop listening to SMS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: buildBottom(),
    );
  }

  Scaffold _buildBody() {
    return Scaffold(
      appBar: AppBar(
        actions: [LanguageButton()],
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(AppText(context).verify),
      ),
      body: Stack(
        children: [
          SvgPicture.asset("assets/icon/background.svg"),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppSize(context).appPadding,
              child: Form(
                key: key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText(context).verify,
                      style: TextStyle(
                        fontSize: AppSize(context).largText2,
                        color: AppColors(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSize(context).height * 0.01),
                    Text(
                      AppText(context).verifyYourMobailNumber,
                      style: TextStyle(
                        fontSize: AppSize(context).mediumText2,
                        color: AppColors.blackColor1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSize(context).height * 0.01),
                    Text(
                      '${AppText(context).wesentcodetothenumber} ${widget.phone}',
                      style: TextStyle(
                        fontSize: AppSize(context).smallText2,
                        color: AppColors.greyColor3,
                      ),
                    ),
                    SizedBox(height: AppSize(context).height * 0.1),

                    /// ✅ Pin Code with Autofill (Force LTR direction)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                      appContext: context,
                      controller: textEditingController,
                      length: 4,
                      enablePinAutofill: true, // ✅ system autofill
                      textStyle: TextStyle(
                        fontSize: AppSize(context).mediumText3,
                        color: AppColors.whiteColor1,
                      ),
                      pastedTextStyle: const TextStyle(
                        color: AppColors.whiteColor1,
                        fontWeight: FontWeight.bold,
                      ),
                      animationType: AnimationType.fade,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 55,
                        fieldWidth: 60,
                        selectedColor: AppColors(context).primaryColor,
                        inactiveFillColor: AppColors.greyColorback,
                        selectedFillColor: AppColors.whiteColor1,
                        inactiveColor: AppColors.whiteColor1,
                        activeColor: AppColors.whiteColor1,
                        activeFillColor: AppColors(context).primaryColor,
                      ),
                      cursorColor: Colors.black,
                      useExternalAutoFillGroup: true,

                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      keyboardType: TextInputType.number,
                      boxShadows: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        debugPrint("Completed: $v");
                        checkOtp();
                      },
                      onChanged: (value) {
                        setState(() => currentText = value);
                      },
                      ),
                    ),
                    SizedBox(height: AppSize(context).height * 0.01),
                    Center(
                      child: loadingResend
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${AppText(context).dontreceivecode}',
                                  style: TextStyle(
                                    fontSize: AppSize(context).smallText2,
                                    color: AppColors.blackColor1,
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            )
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: '${AppText(context).dontreceivecode} ? ',
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText2,
                                  color: AppColors.blackColor1,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: AppText(context).resend,
                                    style: TextStyle(
                                      fontSize: AppSize(context).smallText1,
                                      color: AppColors(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        login().then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            backgroundColor:
                                                AppColors.greenColor,
                                            content: Text(AppText(context,
                                                    isFunction: true)
                                                .successfully),
                                          ));
                                        });
                                      },
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildBottom() {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSize(context).width * 0.04,
        left: AppSize(context).width * 0.04,
        bottom: AppSize(context).height * 0.03,
        top: AppSize(context).height * 0.02,
      ),
      child: CustomBotton(
        title: AppText(context).confirm,
        loading: loading,
        onTap: () async => checkOtp(),
      ),
    );
  }

  checkOtp() {
    // For Business Services, always verify with backend (widget.otp is only for dev/testing)
    // For My Services, widget.otp might be used for quick validation, but still verify with backend
    if (widget.isBusinessServices == true) {
      // Business Services: Always verify with backend API
      // Skip the widget.otp check since it's only for development/testing
      checkOtpFun();
    } else {
      // My Services: If widget.otp is provided (for development/testing), do a quick check
      // But still verify with backend in checkOtpFun()
      if (widget.otp != null && widget.otp!.isNotEmpty) {
        // Quick validation for development (optional)
        if (widget.otp == textEditingController.text.trim()) {
          checkOtpFun();
        } else {
          showDialog(
            context: context,
            builder: (context) => WidgetDialog(
              title: AppText(context, isFunction: true).warning,
              desc: AppText(context, isFunction: true).otpWrong,
              isError: true,
            ),
          );
        }
      } else {
        // No widget.otp provided, verify directly with backend
        checkOtpFun();
      }
    }
  }

  Future login() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      setState(() => loading2 = true);
      await Authantication.login(user: {
        'Mobile': widget.phone,
      }).then((value) {
        if (value?.status != false) {
          setState(() => loginModel = value);
        }
        setState(() => loading2 = false);
      });
    } catch (e) {
      log('Login Is Error');
      setState(() => loading2 = false);
    }
  }

  Future checkOtpFun() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      setState(() => loading = true);
      
      // Check if this is Business Services login
      if (widget.isBusinessServices == true) {
        // Use Business Services OTP verification
        try {
          // Get FCM token
          String? fcmToken;
          try {
            fcmToken = await FirebaseMessaging.instance.getToken();
          } catch (e) {
            log('Error getting FCM token: $e');
            fcmToken = 'device-token-placeholder';
          }

          // Get device ID with full metadata
          final deviceMetadata = await DeviceInfoService.getDeviceMetadata();
          final deviceId = jsonEncode(deviceMetadata);

          // Trim OTP to remove any whitespace
          final trimmedOTP = textEditingController.text.trim();
          
          // Validate OTP is not empty
          if (trimmedOTP.isEmpty || trimmedOTP.length < 4) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => WidgetDialog(
                  title: AppText(context, isFunction: true).warning,
                  desc: AppLocalizations.of(context)!.otpRequired,
                  isError: true,
                ),
              );
            }
            setState(() => loading = false);
            return;
          }
          
          final loginResult = await Authantication.mmsVerifyOTP(
            mobile: widget.phone ?? '',
            otp: trimmedOTP,
            deviceId: deviceId,
            fcmToken: fcmToken ?? 'device-token-placeholder',
          );

          if (!loginResult['success']) {
            if (mounted) {
              // Get localized error message from backend response or use default
              final lang = Localizations.localeOf(context).languageCode;
              String errorMessage = (lang == 'ar' && loginResult['messageAr'] != null)
                  ? loginResult['messageAr']
                  : (loginResult['message'] ?? AppLocalizations.of(context)!.invalidCredentials);
              
              // Check if this is a rate limit error (wait/seconds/rate)
              if (errorMessage.toLowerCase().contains('wait') || 
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
              
              showDialog(
                context: context,
                builder: (context) => WidgetDialog(
                  title: AppText(context, isFunction: true).warning,
                  desc: errorMessage,
                  isError: true,
                ),
              );
            }
            setState(() => loading = false);
            return;
          }

          final mmsUser = loginResult['data'] as MmsUserModel?;
          if (mmsUser != null && mmsUser.success && mmsUser.user != null) {
            // Technician check is now done at OTP request stage, not here
            // If we reach here, the user is allowed to login
            
            final userRoleId = mmsUser.user!.userRoleId;
            final userModel = UserModel(
              status: true,
              token: mmsUser.token?.accessToken ?? '',
              message: mmsUser.message,
              qrCodePath: null,
              wallet: 0,
              customer: Customer(
                id: mmsUser.user!.id,
                roleId: userRoleId,
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

            appProvider.addUser(user: userModel);
            
            if (mmsUser.token != null) {
              appProvider.setTokens(
                access: mmsUser.token!.accessToken,
                refresh: mmsUser.token!.refreshToken,
                type: mmsUser.token!.tokenType,
                expires: mmsUser.token!.expiresIn,
              );
            }

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                downToTop(const HomeLayout()),
                (route) => false,
              );
            }
          } else {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => WidgetDialog(
                  title: AppText(context, isFunction: true).someThingError,
                  desc: AppLocalizations.of(context)!.invalidCredentials,
                  isError: true,
                ),
              );
            }
          }
          setState(() => loading = false);
        } catch (e) {
          log('Business Services OTP verification error: $e');
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
          setState(() => loading = false);
        }
      } else {
        // Use My Services OTP verification (existing flow)
        await Authantication.checkOtp(
          otp: textEditingController.text,
          fcmToken: appProvider.fcmToken ?? "",
          phone: widget.phone.toString(),
        ).then((value) {
          setState(() => userModel = value);
          if (value?.status == true) {
            appProvider.addUser(user: value);
            log(appProvider.userModel?.token.toString() ?? "");
            Map? showTour = CacheHelper.getData(key: CacheHelper.showTour) == null
                ? null
                : json.decode(CacheHelper.getData(key: CacheHelper.showTour));
            if (showTour == null) {
              CacheHelper.saveData(
                  key: CacheHelper.showTour,
                  value: json.encode({
                    "home": true,
                    "subCategory": true,
                    "addAttachment": true,
                    "appointmentDetails": true,
                    "checkout": true,
                  }));
            }

            Navigator.pushAndRemoveUntil(
              context,
              downToTop(const HomeLayout()),
              (route) => false,
            );
          } else {
            showDialog(
              context: context,
              builder: (context) => WidgetDialog(
                title: AppText(context, isFunction: true).warning,
                desc: AppText(context, isFunction: true).otpWrong,
                isError: true,
              ),
            );
          }
          setState(() => loading = false);
        });
      }
    } catch (e) {
      log('checkOtpFun() [ ERROR ] -> $e');
      setState(() => loading = false);
    }
  }
}
