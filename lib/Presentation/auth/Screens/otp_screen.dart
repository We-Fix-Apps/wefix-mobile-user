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

import '../../../Data/Helper/cache_helper.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? verificationId;
  final String? otp;
  final String? phone;
  final List? signUp;

  const VerifyCodeScreen({
    super.key,
    this.verificationId,
    this.phone,
    this.signUp,
    this.otp,
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

                    /// ✅ Pin Code with Autofill
                    PinCodeTextField(
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
    if (widget.otp == textEditingController.text) {
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
    } catch (e) {
      log('Login Is Error');
      setState(() => loading = false);
    }
  }
}
